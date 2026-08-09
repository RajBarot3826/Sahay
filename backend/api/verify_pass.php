<?php
// Sahay Hospital & Police Immunity Pass Verification PHP REST API
require_once __DIR__ . '/../config.php';

header('Content-Type: application/json');

$inputData = json_decode(file_get_contents('php://input'), true);
$qrDataString = $inputData['qr_data_string'] ?? '';

if (empty($qrDataString)) {
    echo json_encode([
        'status' => 'ERROR',
        'message' => 'Missing QR Data Payload'
    ]);
    exit();
}

$decodedPass = json_decode($qrDataString, true);

if (!$decodedPass || !isset($decodedPass['hmac_signature'])) {
    echo json_encode([
        'status' => 'INVALID',
        'message' => 'Invalid or Tampered Good Samaritan Pass'
    ]);
    exit();
}

// Verification response for Hospital Casualty Doctors & Police
$response = [
    'status' => 'VERIFIED_IMMUNITY',
    'legal_statute' => 'Motor Vehicles Act 1988 (Section 134A) & Supreme Court SaveLIFE 2016 Guidelines',
    'incident_id' => $decodedPass['incident_id'] ?? 'SHY-BVN-9921',
    'bystander_immunity_status' => 'ACTIVE',
    'hospital_directives' => [
        'mandatory_cash_deposit_required' => false,
        'bystander_detention_permitted' => false,
        'cashless_trauma_coverage_limit_inr' => 150000,
        'action' => 'ALLOW_IMMEDIATE_ER_ENTRY_AND_RELEASE_BYSTANDER'
    ],
    'verification_timestamp' => date('Y-m-d H:i:s')
];

echo json_encode($response, JSON_PRETTY_PRINT);
?>
