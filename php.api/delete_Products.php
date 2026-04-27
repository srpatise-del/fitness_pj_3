<?php
include 'condb.php';
$product_id = $_POST['product_id'];

$sql = "DELETE FROM Products WHERE product_id = ?";
$stmt = $conn->prepare($sql);
if($stmt->execute([$id])){
    echo json_encode(["status" => "success"]);
}
?>