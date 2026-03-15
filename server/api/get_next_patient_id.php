<?php
/**
 * get_next_patient_id.php
 * Returns the next patient ID for this hospital unit in the current year.
 *
 * New format: {HOSP_CODE}-{YY}-{XXXX}
 *   HOSP_CODE = extracted from unit_id (e.g. "KDH-HSB-01" → "HSB")
 *   YY        = 2-digit current year (e.g. 26)
 *   XXXX      = zero-padded count of patients for this hospital in this year
 *
 * Examples:
 *   KDH-HSB-01  → HSB-26-0007
 *   KDH-HSAH-01 → HSAH-26-0003
 *   KDH-HKU-01  → HKU-26-0001
 *
 * Query params:
 *   ?unit_id=KDH-HSB-01
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once 'db_connect.php';

$unit_id = isset($_GET['unit_id']) ? trim($_GET['unit_id']) : '';
$currentYear = date("y"); // 2-digit year

// --- Extract hospital code from unit_id ---
// Pattern: KDH-{CODE}-{NUM}  e.g. KDH-HSB-01 → HSB
//                              or  KDH-HSAH-01 → HSAH
function extractHospCode(string $unit_id): string
{
    $parts = explode('-', $unit_id);
    // parts[0]=KDH, parts[1]=HOSP code, parts[2]=unit number
    if (count($parts) >= 3) {
        // Strip leading 'H' from abbreviated codes like HHSB, keep HSAH etc. as-is
        return strtoupper($parts[1]);
    }
    return 'UNIT';
}

if (empty($unit_id)) {
    // Fallback: generic format
    echo json_encode(["next_id" => "KDH-$currentYear-0001"]);
    $conn->close();
    exit();
}

$hospCode = extractHospCode($unit_id);

// Pattern matches IDs like "HSB-26-%" for this hospital+year
$prefix = "$hospCode-$currentYear-";
$pattern = "$prefix%";

// Count existing records for this unit in this year for a reliable sequence
$stmt = $conn->prepare(
    "SELECT COUNT(*) AS cnt
     FROM patients
     WHERE unit_id = ? AND YEAR(recorded_at) = YEAR(CURDATE())"
);
$stmt->bind_param("s", $unit_id);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();
$nextSeq = ((int)$row['cnt']) + 1;
$stmt->close();

// Double-check: also ensure the generated ID isn't already taken (race condition safety)
$nextId = $prefix . str_pad($nextSeq, 4, "0", STR_PAD_LEFT);
$checkStmt = $conn->prepare("SELECT id FROM patients WHERE patient_id = ? LIMIT 1");
$checkStmt->bind_param("s", $nextId);
$checkStmt->execute();
$exists = $checkStmt->get_result()->num_rows > 0;
$checkStmt->close();

// If collision, increment until clear
while ($exists) {
    $nextSeq++;
    $nextId = $prefix . str_pad($nextSeq, 4, "0", STR_PAD_LEFT);
    $checkStmt = $conn->prepare("SELECT id FROM patients WHERE patient_id = ? LIMIT 1");
    $checkStmt->bind_param("s", $nextId);
    $checkStmt->execute();
    $exists = $checkStmt->get_result()->num_rows > 0;
    $checkStmt->close();
}

echo json_encode(["next_id" => $nextId]);

$conn->close();
?>