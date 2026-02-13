<?php

header("Access-Control-Allow-Origin: *"); // Allows any website to connect
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");


// 1. Connection Config
$host = "localhost";
$user = "root";
$pass = "";
$db   = "snake_bite_db";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed"]));
}

// 2. Receive JSON Data from Flutter
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    $patient_id = $data['patient_id'];
    $species = $data['species'];
    $severity = $data['severity'];
    $disposition = $data['disposition'];

    // 3. Insert into Database
    $sql = "INSERT INTO patients (patient_id, species_identified, severity_level, final_disposition) 
            VALUES ('$patient_id', '$species', '$severity', '$disposition')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Patient record saved"]);
    } else {
        echo json_encode(["status" => "error", "message" => "SQL Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No data received"]);
}

$conn->close();
?>