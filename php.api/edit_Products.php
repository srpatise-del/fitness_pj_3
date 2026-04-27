<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include 'condb.php';
header('Content-Type: application/json');

try {
    $product_id   = $_POST['product_id'] ?? '';
    $product_name = $_POST['product_name'] ?? '';
    $description  = $_POST['description'] ?? '';
    $price        = $_POST['price'] ?? 0;
    $stock        = $_POST['stock'] ?? 0;
    $oldImage     = $_POST['old_image'] ?? ''; 

    $imageName = $oldImage; 

    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $targetDir = "./images/";
        
        $imageName = time() . "_" . basename($_FILES["image"]["name"]);
        $targetFile = $targetDir . $imageName;

        if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
            if ($oldImage != "" && file_exists($targetDir . $oldImage)) {
                unlink($targetDir . $oldImage);
            }
        } else {
            echo json_encode(["success" => false, "error" => "Upload failed"]);
            exit;
        }
    }

    $sql = "UPDATE Products 
            SET product_name = :product_name,
                description  = :description,
                price        = :price,
                stock        = :stock,
                image        = :image
            WHERE product_id = :product_id";

    $stmt = $conn->prepare($sql);

    $stmt->bindParam(':product_id',   $product_id);
    $stmt->bindParam(':product_name', $product_name);
    $stmt->bindParam(':description',  $description);
    $stmt->bindParam(':price',        $price);
    $stmt->bindParam(':stock',        $stock);
    $stmt->bindParam(':image',        $imageName);

    $stmt->execute();

    echo json_encode(["success" => true, "message" => "Product updated successfully"]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
?>