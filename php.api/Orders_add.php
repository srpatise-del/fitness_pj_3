<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include "condb.php";

$customer_id = $_POST['customer_id'] ?? '';
$total       = $_POST['total'] ?? 0;
$status      = $_POST['status'] ?? 'Pending';

try {
    $sql = "INSERT INTO Orders (customer_id, total, status) 
            VALUES (:customer_id, :total, :status)";
            
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':customer_id' => $customer_id,
        ':total'       => $total,
        ':status'      => $status
    ]);

    echo json_encode(["success" => true, "order_id" => $conn->lastInsertId()]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>