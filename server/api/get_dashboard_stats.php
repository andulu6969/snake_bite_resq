<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "snake_bite_db");

// Initialize counters (Added Observation, Removed Dead)
$stats = [
    "ICU" => 0,
    "Ward" => 0,
    "Observation" => 0,
    "Discharge" => 0,
    "total" => 0
];

$sql = "SELECT final_disposition, COUNT(*) as count FROM patients GROUP BY final_disposition";
$result = $conn->query($sql);

while($row = $result->fetch_assoc()) {
    $disp = $row['final_disposition'];
    $count = (int)$row['count'];
    
    // LOGIC: Count each category separately
    if (stripos($disp, 'ICU') !== false) {
        $stats["ICU"] += $count;
    } 
    elseif (stripos($disp, 'Ward') !== false) {
        $stats["Ward"] += $count;
    } 
    elseif (stripos($disp, 'Observation') !== false) {
        $stats["Observation"] += $count; // Counted separately now
    }
    elseif (stripos($disp, 'Discharge') !== false) {
        $stats["Discharge"] += $count;
    }
    
    $stats["total"] += $count;
}

echo json_encode($stats);
$conn->close();
?>