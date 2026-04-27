<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, POST, OPTIONS");
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
    $workoutId = (int)($_GET["id"] ?? 0);
    if ($workoutId <= 0) {
        http_response_code(400);
        echo json_encode(["message" => "id is required"]);
        exit;
    }

    $input = readInput();
    $type = trim((string)($input["type"] ?? ""));
    $duration = (int)($input["duration"] ?? 0);
    $frequency = (int)($input["frequency_per_week"] ?? 0);
    $date = trim((string)($input["date"] ?? ""));

    if ($type === "" || $duration <= 0 || $frequency <= 0 || $date === "") {
        http_response_code(400);
        echo json_encode(["message" => "Invalid workout payload"]);
        exit;
    }

    $stmt = $conn->prepare("
        UPDATE workouts
        SET type = :type,
            duration = :duration,
            frequency_per_week = :frequency_per_week,
            date = :date
        WHERE id = :id
    ");
    $stmt->execute([
        ":type" => $type,
        ":duration" => $duration,
        ":frequency_per_week" => $frequency,
        ":date" => date("Y-m-d H:i:s", strtotime($date)),
        ":id" => $workoutId
    ]);

    echo json_encode(["message" => "Workout updated"]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error", "error" => $e->getMessage()]);
}

