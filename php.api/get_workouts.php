<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

include "condb.php";

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

    $userId = (int)($_GET["user_id"] ?? 0);
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode(["message" => "user_id is required"]);
        exit;
    }

    $stmt = $conn->prepare("
        SELECT id, user_id, type, duration, frequency_per_week, date
        FROM workouts
        WHERE user_id = :user_id
        ORDER BY date DESC
    ");
    $stmt->execute([":user_id" => $userId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["data" => $rows], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error", "error" => $e->getMessage()]);
}

