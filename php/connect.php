<?php
$conn = new mysqli("mysql.cba.pl", "bestbank", "BubbleSort123", "bestbank");

if ($conn->connect_error) {
  die("Connection failed");
}
?>
