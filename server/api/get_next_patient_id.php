<?php
/**
 * get_next_patient_id.php
 * Returns the next patient ID shared across ALL doctors in the same hospital.
 *
 * Format: {HOSP_CODE}-{YY}-{XXXX}
 *   HOSP_CODE = abbreviation derived from hospital_name
 *   YY        = 2-digit current year (e.g. 26)
 *   XXXX      = zero-padded count of all patients in this HOSPITAL this year
 *
 * Examples:
 *   hospital_name = "Hospital Sultanah Bahiyah"  → HSB-26-0007
 *   hospital_name = "Hospital Sultan Abdul Halim" → HSAH-26-0003
 *   hospital_name = "Hospital Kulim"              → HKU-26-0001
 *
 * Query params (one of these must be provided):
 *   ?hospital_name=Hospital+Sultanah+Bahiyah
 *   ?unit_id=KDH-HSB-01   (legacy – resolved via doctors/station_units table)
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

$currentYear = date("y"); // 2-digit year

// --- 1. Determine hospital name ---
$hospitalName = isset($_GET['hospital_name']) ? trim($_GET['hospital_name']) : '';
$unitId       = isset($_GET['unit_id'])       ? trim($_GET['unit_id'])       : '';

if (empty($hospitalName) && !empty($unitId)) {
    // Try doctors table first (new system)
    $st = $conn->prepare("SELECT hospital_name FROM doctors WHERE username = ? LIMIT 1");
    $st->bind_param("s", $unitId);
    $st->execute();
    $row = $st->get_result()->fetch_assoc();
    $st->close();
    if ($row) {
        $hospitalName = $row['hospital_name'];
    } else {
        // Fallback to station_units (legacy)
        $st2 = $conn->prepare("SELECT hospital_name FROM station_units WHERE unit_id = ? LIMIT 1");
        $st2->bind_param("s", $unitId);
        $st2->execute();
        $row2 = $st2->get_result()->fetch_assoc();
        $st2->close();
        if ($row2) $hospitalName = $row2['hospital_name'];
    }
}

if (empty($hospitalName)) {
    echo json_encode(["next_id" => "KDH-$currentYear-0001"]);
    $conn->close();
    exit();
}

// --- 2. Generate hospital code abbreviation ---
function hospitalCode(string $name): string
{
    // Strip "Hospital " prefix
    $stripped = preg_replace('/^Hospital\s+/i', '', $name);
    // Take first letter of each word
    $words = preg_split('/\s+/', trim($stripped));
    $code  = '';
    foreach ($words as $w) {
        if (!empty($w)) $code .= strtoupper($w[0]);
    }
    // Ensure at least 2 chars
    return strlen($code) >= 2 ? $code : strtoupper(substr($stripped, 0, 3));
}

$hospCode = hospitalCode($hospitalName);
$prefix   = "$hospCode-$currentYear-";

// --- 3. Count ALL patients in this hospital for this year (shared counter) ---
$stmt = $conn->prepare(
    "SELECT COUNT(*) AS cnt
     FROM patients
     WHERE hospital_name = ? AND YEAR(recorded_at) = YEAR(CURDATE())"
);
$stmt->bind_param("s", $hospitalName);
$stmt->execute();
$row     = $stmt->get_result()->fetch_assoc();
$nextSeq = ((int)$row['cnt']) + 1;
$stmt->close();

// --- 4. Collision check ---
$nextId   = $prefix . str_pad($nextSeq, 4, "0", STR_PAD_LEFT);
$chkStmt  = $conn->prepare("SELECT id FROM patients WHERE patient_id = ? LIMIT 1");
$chkStmt->bind_param("s", $nextId);
$chkStmt->execute();
$exists = $chkStmt->get_result()->num_rows > 0;
$chkStmt->close();

while ($exists) {
    $nextSeq++;
    $nextId  = $prefix . str_pad($nextSeq, 4, "0", STR_PAD_LEFT);
    $chkStmt = $conn->prepare("SELECT id FROM patients WHERE patient_id = ? LIMIT 1");
    $chkStmt->bind_param("s", $nextId);
    $chkStmt->execute();
    $exists = $chkStmt->get_result()->num_rows > 0;
    $chkStmt->close();
}

echo json_encode(["next_id" => $nextId]);
$conn->close();
?>