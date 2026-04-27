<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

include "condb.php";

try {
    $workoutId = (int)($_GET["id"] ?? 0);
    if ($workoutId <= 0) {
        http_response_code(400);
        echo json_encode(["message" => "id is required"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM workouts WHERE id = :id");
    $stmt->execute([":id" => $workoutId]);

    echo json_encode(["message" => "Workout deleted"]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error", "error" => $e->getMessage()]);
}

