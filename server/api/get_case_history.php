<?php
/**
 * get_case_history.php
 * Returns paginated patient records, scoped to hospital (not unit/doctor).
 * All doctors from the same hospital see the same history.
 *
 * Query params:
 *   ?hospital_name=Hospital+Sultanah+Bahiyah  (preferred, hospital scope)
 *   ?unit_id=dr.ahmad     (resolved to hospital_name via doctors table)
 *   &page=1               (optional, default 1)
 *   &limit=15             (optional, default 15)
 *   &search=HSB-26-0001   (optional, filters by patient_id, species, or ic_passport)
 *   &severity=CRITICAL    (optional)
 *
 * Use unit_id=ALL for admin cross-hospital view.
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

// --- Params ---
$hospitalName = isset($_GET['hospital_name']) ? trim($_GET['hospital_name']) : '';
$unitId       = isset($_GET['unit_id'])       ? trim($_GET['unit_id'])       : '';
$page         = max(1, (int)($_GET['page']  ?? 1));
$limit        = min(50, max(1, (int)($_GET['limit'] ?? 15)));
$search       = isset($_GET['search'])   ? trim($_GET['search'])   : '';
$severity     = isset($_GET['severity']) ? trim($_GET['severity']) : '';
$offset       = ($page - 1) * $limit;

$isAdminAll   = strtoupper($unitId) === 'ALL';

// Resolve hospital_name from username / unit_id
if (!$isAdminAll && empty($hospitalName) && !empty($unitId)) {
    $st = $conn->prepare("SELECT hospital_name FROM doctors WHERE username = ? LIMIT 1");
    $st->bind_param("s", $unitId);
    $st->execute();
    $row = $st->get_result()->fetch_assoc();
    $st->close();
    if ($row) {
        $hospitalName = $row['hospital_name'];
    } else {
        $st2 = $conn->prepare("SELECT hospital_name FROM station_units WHERE unit_id = ? LIMIT 1");
        $st2->bind_param("s", $unitId);
        $st2->execute();
        $row2 = $st2->get_result()->fetch_assoc();
        $st2->close();
        if ($row2) $hospitalName = $row2['hospital_name'];
    }
}

if (empty($hospitalName) && !$isAdminAll) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "hospital_name or unit_id is required"]);
    $conn->close();
    exit();
}

// --- Build WHERE clause ---
$conditions = [];
$types      = "";
$params     = [];

if (!$isAdminAll && !empty($hospitalName)) {
    $conditions[] = "hospital_name = ?";
    $types        .= "s";
    $params[]     = $hospitalName;
}

if (!empty($search)) {
    $conditions[] = "(patient_id LIKE ? OR species_identified LIKE ? OR ic_passport LIKE ?)";
    $types        .= "sss";
    $like          = "%$search%";
    $params[]      = $like;
    $params[]      = $like;
    $params[]      = $like;
}

if (!empty($severity)) {
    $conditions[] = "severity_level = ?";
    $types        .= "s";
    $params[]     = $severity;
}

$where = !empty($conditions) ? implode(" AND ", $conditions) : "1=1";

// --- COUNT total ---
$countStmt = $conn->prepare("SELECT COUNT(*) AS total FROM patients WHERE $where");
if (!empty($params)) {
    $countStmt->bind_param($types, ...$params);
}
$countStmt->execute();
$countResult = $countStmt->get_result()->fetch_assoc();
$total       = (int)$countResult['total'];
$totalPages  = max(1, (int)ceil($total / $limit));
$countStmt->close();

// --- FETCH page ---
$dataStmt = $conn->prepare(
    "SELECT patient_id,
            species_identified AS species,
            severity_level     AS severity,
            final_disposition  AS disposition,
            ic_passport,
            diagnosed_by,
            hospital_name,
            unit_id,
            recorded_at
     FROM patients
     WHERE $where
     ORDER BY recorded_at DESC
     LIMIT ? OFFSET ?"
);
$types  .= "ii";
$params[] = $limit;
$params[] = $offset;
$dataStmt->bind_param($types, ...$params);
$dataStmt->execute();
$rows = $dataStmt->get_result()->fetch_all(MYSQLI_ASSOC);
$dataStmt->close();
$conn->close();

echo json_encode([
    "status"  => "success",
    "total"   => $total,
    "page"    => $page,
    "pages"   => $totalPages,
    "records" => $rows,
]);
?>
