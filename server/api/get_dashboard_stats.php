<?php
/**
 * get_dashboard_stats.php
 * Returns patient disposition counts for the dashboard bar chart.
 *
 * Scoping (in priority order):
 *   1. hospital_name param  → exact hospital scope (preferred)
 *   2. unit_id param        → resolved to hospital_name via doctors/station_units table
 *   3. unit_id = "ALL"      → admin cross-hospital, no filter
 *
 * Query params:
 *   ?hospital_name=Hospital+Sultanah+Bahiyah
 *   ?unit_id=dr.ahmad       (resolved to hospital, OR "ALL" for admin)
 *   ?filter=monthly         (default) — current calendar month
 *   ?filter=yearly          — current calendar year
 *
 * Response:
 *   { "ICU": 3, "Ward": 5, "Observation": 2, "Discharge": 8, "total": 18, "filter": "monthly" }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

// --- 1. Time filter ---
$filter = isset($_GET['filter']) ? strtolower(trim($_GET['filter'])) : 'monthly';
$timeWhere = ($filter === 'yearly')
    ? "YEAR(recorded_at) = YEAR(CURDATE())"
    : "YEAR(recorded_at) = YEAR(CURDATE()) AND MONTH(recorded_at) = MONTH(CURDATE())";

// --- 2. Resolve scope ---
$hospitalName = isset($_GET['hospital_name']) ? trim($_GET['hospital_name']) : '';
$unitId       = isset($_GET['unit_id'])       ? trim($_GET['unit_id'])       : '';
$isAdminAll   = strtoupper($unitId) === 'ALL';

// Resolve hospital_name from username/unit_id if not provided directly
if (!$isAdminAll && empty($hospitalName) && !empty($unitId)) {
    // Try doctors table first (new auth system)
    $st = $conn->prepare("SELECT hospital_name FROM doctors WHERE username = ? LIMIT 1");
    $st->bind_param("s", $unitId);
    $st->execute();
    $row = $st->get_result()->fetch_assoc();
    $st->close();
    if ($row) {
        $hospitalName = $row['hospital_name'];
    } else {
        // Fallback: legacy station_units
        $st2 = $conn->prepare("SELECT hospital_name FROM station_units WHERE unit_id = ? LIMIT 1");
        $st2->bind_param("s", $unitId);
        $st2->execute();
        $row2 = $st2->get_result()->fetch_assoc();
        $st2->close();
        if ($row2) $hospitalName = $row2['hospital_name'];
    }
}

// --- 3. Build WHERE ---
$params = [];
$types  = '';
$scopeWhere = '';

if (!$isAdminAll && !empty($hospitalName)) {
    // NEW records: scoped by hospital_name column
    // OLD records (pre-migration): fall through via OR on unit_id join
    // We use a subquery to catch both hospital_name match AND unit_id that maps to this hospital
    $scopeWhere = "AND (
        hospital_name = ?
        OR (hospital_name IS NULL AND unit_id IN (
            SELECT unit_id FROM station_units WHERE hospital_name = ?
        ))
    )";
    $params[] = $hospitalName;
    $params[] = $hospitalName;
    $types   .= 'ss';
}
// If $isAdminAll or no hospital → no scope filter (show all)

// --- 4. Query ---
$sql = "SELECT final_disposition, COUNT(*) AS count
        FROM patients
        WHERE $timeWhere $scopeWhere
        GROUP BY final_disposition";

$stmt = $conn->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$result = $stmt->get_result();

// --- 5. Tally ---
$stats = [
    "ICU"         => 0,
    "Ward"        => 0,
    "Observation" => 0,
    "Discharge"   => 0,
    "total"       => 0,
    "filter"      => $filter,
    "hospital"    => $hospitalName ?: ($isAdminAll ? 'ALL' : 'unknown'),
];

while ($row = $result->fetch_assoc()) {
    $disp  = $row['final_disposition'];
    $count = (int)$row['count'];

    if      (stripos($disp, 'ICU')         !== false) $stats["ICU"]         += $count;
    elseif  (stripos($disp, 'Ward')        !== false) $stats["Ward"]        += $count;
    elseif  (stripos($disp, 'Observation') !== false) $stats["Observation"] += $count;
    elseif  (stripos($disp, 'Discharge')   !== false) $stats["Discharge"]   += $count;

    $stats["total"] += $count;
}

echo json_encode($stats);
$stmt->close();
$conn->close();
?>