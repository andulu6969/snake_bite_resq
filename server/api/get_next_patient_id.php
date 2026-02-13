<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "snake_bite_db");

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed"]));
}

// 1. Get current 2-digit year (e.g., "26" for 2026)
$currentYear = date("y"); 

// 2. Fetch the very last patient ID recorded
$sql = "SELECT patient_id FROM patients ORDER BY id DESC LIMIT 1";
$result = $conn->query($sql);

// Default fallback (First patient of the current year)
$nextId = "KDH-ER-" . $currentYear . "-0001";

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $lastId = $row['patient_id'];
    
    // Expected format: KDH-ER-YY-XXXX
    // Explode splits the string by "-"
    $parts = explode('-', $lastId);
    
    // Safety check: Ensure ID has 4 parts
    if (count($parts) == 4) {
        $dbYear = $parts[2];      // The year part from DB (e.g., "25")
        $dbSequence = intval($parts[3]); // The number part (e.g., 618)
        
        if ($dbYear === $currentYear) {
            // SAME YEAR: Just increment the number
            $newSequence = $dbSequence + 1;
        } else {
            // NEW YEAR DETECTED: Reset sequence to 1
            $newSequence = 1;
        }
        
        // Build the new ID
        // str_pad adds zeros to the left (e.g., 1 becomes 0001)
        $nextId = "KDH-ER-" . $currentYear . "-" . str_pad($newSequence, 4, "0", STR_PAD_LEFT);
    }
}

echo json_encode(["next_id" => $nextId]);

$conn->close();
?>