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
        CREATE TABLE IF NOT EXISTS workouts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            type VARCHAR(100) NOT NULL,
            duration INT NOT NULL,
            frequency_per_week INT NOT NULL,
            date DATETIME NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ");

    $input = readInput();
    $userId = (int)($input["user_id"] ?? 0);
    $type = trim((string)($input["type"] ?? ""));
    $duration = (int)($input["duration"] ?? 0);
    $frequency = (int)($input["frequency_per_week"] ?? 0);
    date("Y-m-d H:i:s", strtotime($date))

    if ($userId <= 0 || $type === "" || $duration <= 0 || $frequency <= 0 || $date === "") {
        http_response_code(400);
        echo json_encode(["message" => "Invalid workout payload"]);
        exit;
    }

    $stmt = $conn->prepare("
        INSERT INTO workouts (user_id, type, duration, frequency_per_week, date)
        VALUES (:user_id, :type, :duration, :frequency_per_week, :date)
    ");
    $stmt->execute([
        ":user_id" => $userId,
        ":type" => $type,
        ":duration" => $duration,
        ":frequency_per_week" => $frequency,
        ":date" => str_replace("T", " ", substr($date, 0, 19))
    ]);

    echo json_encode([
        "message" => "Workout created",
        "id" => (int)$conn->lastInsertId()
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
  "message" => "Server error",
  "error" => $e->getMessage()
]);
}

