<?php
$servername = "db"; //numele serviciului din docker-compose
$username = getenv('MYSQL_USER');
$password = getenv('MYSQL_PASSWORD');
$dbname = getenv('MYSQL_DATABASE');

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Conexiunea a eșuat: " . $conn->connect_error);
}

$line = isset($_GET['line']) ? intval($_GET['line']) : 0; // verif if line is set in the URL

if ($line < 0) {
    die("Invalid line number.");
}

// // Interogare pentru a selecta primul nume
// $sql = "SELECT name FROM names ORDER BY id ASC";
// $result = $conn->query($sql);

$sql = "SELECT name FROM names ORDER BY id ASC LIMIT ?, 1"; // limit result to one line
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $line);//binds the line value to ?
$stmt->execute();
$result = $stmt->get_result();

// Verificare și afișare rezultat
if ($result->num_rows > 0) {
    // Afișează primul nume
    while($row = $result->fetch_assoc()){;
    echo "Hello,  " . $row["name"] . "!<br>";
    }
} else {
    echo "Nu sunt date disponibile.";
}

// Închide conexiunea
$conn->close();
$stmt->close();
?>