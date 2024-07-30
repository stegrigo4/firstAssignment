<?php
$servername = "db"; //numele serviciului din docker-compose
// $username = "myapp_user";
// $password = "example";
// $dbname = "myapp_db";
$username = getenv('MYSQL_USER');
$password = getenv('MYSQL_PASSWORD');
$dbname = getenv('MYSQL_DATABASE');

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Conexiunea a eșuat: " . $conn->connect_error);
}

// Interogare pentru a selecta primul nume
$sql = "SELECT name FROM names ORDER BY id ASC LIMIT 1";
$result = $conn->query($sql);

// Verificare și afișare rezultat
if ($result->num_rows > 0) {
    // Afișează primul nume
    $row = $result->fetch_assoc();
    echo "Hello,  " . $row["name"] . "!";
} else {
    echo "Nu sunt date disponibile.";
}

// Închide conexiunea
$conn->close();
?>