<?php
/**
 * get_case_history.php
 * Returns paginated patient records, with optional search.
 * Supports both unit-scoped queries and admin (ALL) queries.
 *
 * Query params:
 *   ?unit_id=KDH-HSB-01          (required — use "ALL" for admin cross-hospital view)
 *   &page=1                       (optional, default 1)
 *   &limit=15                     (optional, default 15)
 *   &search=HSB-26-0001           (optional, filters by patient_id or species)
 *   &severity=CRITICAL            (optional, filter by severity_level)
 *
 * Returns:
 *   {
 *     "status": "success",
 *     "total": 23,
 *     "page": 1,
 *     "pages": 2,
 *     "records": [
 *       {
 *         "patient_id": "HSB-26-0001",
 *         "species_identified": "Likely Malayan Pit Viper",
 *         "severity_level": "CRITICAL",
 *         "final_disposition": "Admit ICU",
 *         "recorded_at": "2026-02-01 08:22:00"
 *       }, ...
 *     ]
 *   }
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

// --- Params ---
$unit_id = isset($_GET['unit_id']) ? trim($_GET['unit_id']) : '';
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = min(50, max(1, (int)($_GET['limit'] ?? 15)));
$search = isset($_GET['search']) ? trim($_GET['search']) : '';
$severity = isset($_GET['severity']) ? trim($_GET['severity']) : '';
$offset = ($page - 1) * $limit;

if (empty($unit_id)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "unit_id is required"]);
    $conn->close();
    exit();
}

// --- Build WHERE clause ---
// If unit_id is "ALL", skip the unit filter (admin mode)
$conditions = [];
$types = "";
$params = [];

if (strtoupper($unit_id) !== 'ALL') {
    $conditions[] = "unit_id = ?";
    $types .= "s";
    $params[] = $unit_id;
}

if (!empty($search)) {
    $conditions[] = "(patient_id LIKE ? OR species_identified LIKE ?)";
    $types .= "ss";
    $like = "%$search%";
    $params[] = $like;
    $params[] = $like;
}

if (!empty($severity)) {
    $conditions[] = "severity_level = ?";
    $types .= "s";
    $params[] = $severity;
}

$where = !empty($conditions) ? implode(" AND ", $conditions) : "1=1";

// --- COUNT total ---
$countStmt = $conn->prepare("SELECT COUNT(*) AS total FROM patients WHERE $where");
if (!empty($params)) {
    $countStmt->bind_param($types, ...$params);
}
$countStmt->execute();
$countResult = $countStmt->get_result()->fetch_assoc();
$total = (int)$countResult['total'];
$totalPages = max(1, (int)ceil($total / $limit));
$countStmt->close();

// --- FETCH page ---
$dataStmt = $conn->prepare(
    "SELECT patient_id,
            species_identified AS species,
            severity_level     AS severity,
            final_disposition  AS disposition,
            unit_id,
            recorded_at
     FROM patients
     WHERE $where
     ORDER BY recorded_at DESC
     LIMIT ? OFFSET ?"
);
$types .= "ii";
$params[] = $limit;
$params[] = $offset;
$dataStmt->bind_param($types, ...$params);
$dataStmt->execute();
$rows = $dataStmt->get_result()->fetch_all(MYSQLI_ASSOC);
$dataStmt->close();
$conn->close();

echo json_encode([
    "status" => "success",
    "total" => $total,
    "page" => $page,
    "pages" => $totalPages,
    "records" => $rows,
]);
?>
