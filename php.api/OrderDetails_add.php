<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include "condb.php";

$order_id   = $_POST['order_id'] ?? '';
$product_id = $_POST['product_id'] ?? '';
$quantity   = $_POST['quantity'] ?? 0;
$price      = $_POST['price'] ?? 0;

try {
    $sql = "INSERT INTO OrderDetails (order_id, product_id, quantity, price) 
            VALUES (:order_id, :product_id, :quantity, :price)";
            
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':order_id'   => $order_id,
        ':product_id' => $product_id,
        ':quantity'   => $quantity,
        ':price'      => $price
    ]);

    echo json_encode(["success" => true]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>