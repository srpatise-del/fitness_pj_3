<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include "condb.php";

$firstName = $_POST['firstName'] ?? '';
$lastName  = $_POST['lastName'] ?? '';
$phone     = $_POST['phone'] ?? '';
$username  = $_POST['username'] ?? '';
$password  = $_POST['password'] ?? '';

try {
    $sql = "INSERT INTO Customers (firstName, lastName, phone, username, password) 
            VALUES (:firstName, :lastName, :phone, :username, :password)";
            
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':firstName' => $firstName,
        ':lastName'  => $lastName,
        ':phone'     => $phone,
        ':username'  => $username,
        ':password'  => $password
    ]);

    echo json_encode(["success" => true, "message" => "Customer added successfully"]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>