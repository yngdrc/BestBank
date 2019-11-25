<?php
session_start();

if ((!isset($_POST['UserName']) || (!isset($_POST['Password'])))) {
  header('Location: index.php');
  exit();
}

require "connect.php";

$username = $_POST['UserName'];
$password = $_POST['Password'];

$username = htmlentities($username, ENT_QUOTES, "UTF-8");

$sql = sprintf(
  "SELECT * FROM `Customers` WHERE UserName='%s'",
  mysqli_real_escape_string($conn, $username)
);

$result = $conn->query($sql);
$num_users = $result->num_rows;

if ($num_users > 0) {
  $row = $result->fetch_assoc();
  if ($password === $row['UserPassword']) { // (password_verify($password, $row['UserPassword']))
    $_SESSION['logged'] = true;
    $_SESSION['IdentityNumber'] = $row['IdentityNumber'];
    $_SESSION['Email'] = $row['Email'];
    $_SESSION['LastName'] = $row['LastName'];
    $_SESSION['FirstName'] = $row['FirstName'];
    $_SESSION['BirthDate'] = $row['BirthDate'];
    $_SESSION['AreaCode'] = $row['AreaCode'];
    $_SESSION['PhoneNumber'] = $row['PhoneNumber'];
    $_SESSION['TitleOfCourtesy'] = $row['TitleOfCourtesy'];
    $_SESSION['UserName'] = $row['UserName'];
    $_SESSION['RegisterDate'] = $row['RegisterDate'];
    $_SESSION['ProfileStatus'] = $row['ProfileStatus'];
    // TODO: $_SESSION['Balance'] = $row['Balance'];

    unset($_SESSION['error']);
    $result->close();
    header('Location: welcome.php');
  } else {
    $_SESSION['error'] = 'Authentication failed. You entered an incorrect username or password.';
    header('Location: index.php');
  }
} else {
  $_SESSION['error'] = 'Authentication failed. You entered an incorrect username or password.';
  header('Location: index.php');
}

$conn->close();
?>
