<?php
session_start();

if ((!isset($_POST['username']) || (!isset($_POST['password'])))) {
  header('Location: index.php');
  exit();
}

require "connect.php";

$username = $_POST['username'];
$password = $_POST['password'];

$username = htmlentities($username, ENT_QUOTES, "UTF-8");
$password = htmlentities($password, ENT_QUOTES, "UTF-8");

$sql = sprintf(
  "SELECT * FROM `Temp` WHERE Username='%s' AND Password='%s'",
  mysqli_real_escape_string($conn, $username),
  mysqli_real_escape_string($conn, $password)
);

$result = $conn->query($sql);
$num_users = $result->num_rows;

if ($num_users > 0) {
  $_SESSION['logged'] = true;

  $row = $result->fetch_assoc();
  // $_SESSION['id'] = $row['Id'];
  $_SESSION['username'] = $row['Username'];
  $_SESSION['balance'] = $row['Balance'];

  unset($_SESSION['error']);
  $result->close();
  header('Location: welcome.php');
} else {
  $_SESSION['error'] = 'Authentication failed. You entered an incorrect username or password.';
  header('Location: index.php');
}

$conn->close();
?>
