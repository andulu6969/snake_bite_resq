<?php
/**
 * get_dashboard_stats.php
 * Returns patient disposition counts for the dashboard chart.
 * Supports both unit-scoped and admin (ALL) queries.
 *
 * Query params:
 *   ?unit_id=KDH-HSB-01  (use "ALL" for admin cross-hospital view)
 *   ?filter=monthly       (default) — counts for the current calendar month
 *   ?filter=yearly                  — counts for the current calendar year
 *
 * Example response:
 *   { "ICU": 3, "Ward": 5, "Observation": 2, "Discharge": 8, "total": 18, "filter": "monthly" }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

// --- 1. Determine time filter ---
$filter = isset($_GET['filter']) ? strtolower(trim($_GET['filter'])) : 'monthly';
$unit_id = isset($_GET['unit_id']) ? trim($_GET['unit_id']) : '';

if ($filter === 'yearly') {
    $timeWhere = "YEAR(recorded_at) = YEAR(CURDATE())";
}
else {
    $timeWhere = "YEAR(recorded_at) = YEAR(CURDATE()) AND MONTH(recorded_at) = MONTH(CURDATE())";
}

// --- 2. Build unit filter ---
// If unit_id is "ALL" or empty, skip the unit filter (admin mode / fallback)
$unitWhere = '';
$params = [];
$types = '';

if (!empty($unit_id) && strtoupper($unit_id) !== 'ALL') {
    $unitWhere = "AND unit_id = ?";
    $params[] = $unit_id;
    $types .= 's';
}

// --- 3. Query grouped by disposition ---
$sql = "SELECT final_disposition, COUNT(*) AS count
        FROM patients
        WHERE $timeWhere $unitWhere
        GROUP BY final_disposition";

$stmt = $conn->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$result = $stmt->get_result();

// --- 4. Tally into categories ---
$stats = [
    "ICU" => 0,
    "Ward" => 0,
    "Observation" => 0,
    "Discharge" => 0,
    "total" => 0,
    "filter" => $filter,
    "unit_id" => $unit_id ?: "all",
];

while ($row = $result->fetch_assoc()) {
    $disp = $row['final_disposition'];
    $count = (int)$row['count'];

    if (stripos($disp, 'ICU') !== false) {
        $stats["ICU"] += $count;
    }
    elseif (stripos($disp, 'Ward') !== false) {
        $stats["Ward"] += $count;
    }
    elseif (stripos($disp, 'Observation') !== false) {
        $stats["Observation"] += $count;
    }
    elseif (stripos($disp, 'Discharge') !== false) {
        $stats["Discharge"] += $count;
    }

    $stats["total"] += $count;
}

echo json_encode($stats);
$stmt->close();
$conn->close();
?>