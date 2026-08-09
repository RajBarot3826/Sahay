<?php
// Government & System Admin Web Console (Role 7 — PHP Web)
require_once __DIR__ . '/../config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sahay — MoRTH eDAR Government Admin Console</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { background: #070a12; color: #fff; font-family: 'Plus Jakarta Sans', sans-serif; padding: 2rem; }
        .card { background: #0f172a; border: 1px solid #1e293b; border-radius: 16px; padding: 1.5rem; }
        .grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-top: 1rem; }
        .metric { background: #1e293b; padding: 1rem; border-radius: 12px; text-align: center; }
        .metric h2 { font-size: 2rem; color: #a855f7; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🏛️ Sahay Master Government Admin Console</h1>
        <p>eDAR National Crash Database Sync • GIS Blackspot Analytics • Bhavnagar District</p>
        
        <div class="grid">
            <div class="metric">
                <h2>3 Apps</h2>
                <p>Flutter Mobile Apps</p>
            </div>
            <div class="metric">
                <h2 style="color:#10b981;">2 Portals</h2>
                <p>PHP Web Portals</p>
            </div>
            <div class="metric">
                <h2 style="color:#38bdf8;">&lt; 5 Mins</h2>
                <p>Highway Response Time</p>
            </div>
            <div class="metric">
                <h2 style="color:#ff2a4b;">50,000+</h2>
                <p>Target Lives Saved</p>
            </div>
        </div>
    </div>
</body>
</html>
