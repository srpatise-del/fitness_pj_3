<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

include "condb.php";

function readInput(): array
{
    $raw = json_decode(file_get_contents("php://input"), true);
    if (is_array($raw)) {
        return $raw;
    }
    return $_POST ?? [];
}

try {
    // Ensure app table exists for Flutter auth flow
    $conn->exec("
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(100) NOT NULL,
            email VARCHAR(150) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            role VARCHAR(20) NOT NULL DEFAULT 'user',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ");

    $input = readInput();
    $email = trim((string)($input["email"] ?? ""));
    $password = (string)($input["password"] ?? "");

    if ($email === "" || $password === "") {
        http_response_code(400);
        echo json_encode(["message" => "Email and password are required"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT id, username, email, password, role FROM users WHERE email = :email LIMIT 1");
    $stmt->execute([":email" => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        http_response_code(401);
        echo json_encode(["message" => "Invalid email or password"]);
        exit;
    }

    $isValid = password_verify($password, $user["password"]) || $password === $user["password"];
    if (!$isValid) {
        http_response_code(401);
        echo json_encode(["message" => "Invalid email or password"]);
        exit;
    }

    $token = base64_encode($user["id"] . "|" . $user["email"] . "|" . time());

    echo json_encode([
        "token" => $token,
        "user" => [
            "id" => (int)$user["id"],
            "username" => $user["username"],
            "email" => $user["email"],
            "role" => $user["role"] ?: "user"
        ]
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error", "error" => $e->getMessage()]);
}

