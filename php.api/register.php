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
    $username = trim((string)($input["username"] ?? ""));
    $email = trim((string)($input["email"] ?? ""));
    $password = (string)($input["password"] ?? "");

    if ($username === "" || $email === "" || $password === "") {
        http_response_code(400);
        echo json_encode(["message" => "Username, email and password are required"]);
        exit;
    }

    $check = $conn->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
    $check->execute([":email" => $email]);
    if ($check->fetch(PDO::FETCH_ASSOC)) {
        http_response_code(409);
        echo json_encode(["message" => "Email already exists"]);
        exit;
    }

    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $role = str_contains(strtolower($email), "admin") ? "admin" : "user";

    $insert = $conn->prepare("
        INSERT INTO users (username, email, password, role)
        VALUES (:username, :email, :password, :role)
    ");
    $insert->execute([
        ":username" => $username,
        ":email" => $email,
        ":password" => $hashedPassword,
        ":role" => $role
    ]);

    $id = (int)$conn->lastInsertId();
    $token = base64_encode($id . "|" . $email . "|" . time());

    echo json_encode([
        "token" => $token,
        "user" => [
            "id" => $id,
            "username" => $username,
            "email" => $email,
            "role" => $role
        ]
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error", "error" => $e->getMessage()]);
}

