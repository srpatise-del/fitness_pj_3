<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include "condb.php";

$order_id = $_POST['order_id'] ?? '';
$amount   = $_POST['amount'] ?? 0;
$method   = $_POST['method'] ?? '';
$status   = $_POST['status'] ?? 'Completed';

try {
    $sql = "INSERT INTO Payments (order_id, amount, method, status) 
            VALUES (:order_id, :amount, :method, :status)";
            
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':order_id' => $order_id,
        ':amount'   => $amount,
        ':method'   => $method,
        ':status'   => $status
    ]);

    echo json_encode(["success" => true]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>