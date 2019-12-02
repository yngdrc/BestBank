<?php
session_start();

if (isset($_POST['IdentityNumber'])) {
  $ok = true;

  $IdentityNumber = $_POST['IdentityNumber'];
  $Email = $_POST['Email'];
  $LastName = $_POST['LastName'];
  $FirstName = $_POST['FirstName'];
  $BirthDate = $_POST['BirthDate'];
  $AreaCode = $_POST['AreaCode'];
  $PhoneNumber = $_POST['PhoneNumber'];
  $TitleOfCourtesy = $_POST['TitleOfCourtesy'];

  if (preg_match('/^[0-9]+$/', $IdentityNumber) !== 1) {
    $ok = false;
    $_SESSION['RFE_IdentityNumber'] = 'Invalid IdentityNumber';
  }

  if (preg_match('/^.+@[a-z]+\\.[a-z]+$/', $Email) !== 1) {
    $ok = false;
    $_SESSION['RFE_Email'] = 'Invalid Email';
  }

  if (preg_match('/^[A-Z]/', $LastName) !== 1 ||
      preg_match('/^.[a-z[:space:]]{2,}$/', $LastName) !== 1) {
    $ok = false;
    $_SESSION['RFE_LastName'] = 'Invalid LastName';
  }

  if (preg_match('/^[A-Z]/', $FirstName) !== 1 ||
      preg_match('/^.[a-z[:space:]]{2,}$/', $FirstName) !== 1) {
    $ok = false;
    $_SESSION['RFE_FirstName'] = 'Invalid FirstName';
  }

  if (preg_match('/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/', $BirthDate) !== 1) {
    $ok = false;
    $_SESSION['RFE_BirthDate'] = 'Invalid BirthDate (yyyy-mm-dd)';
  }

  if (preg_match('/^\\+?[0-9]+$/', $AreaCode) !== 1) {
    $ok = false;
    $_SESSION['RFE_AreaCode'] = 'Invalid AreaCode';
  }

  if (preg_match('/^[0-9]+$/', $PhoneNumber) !== 1) {
    $ok = false;
    $_SESSION['RFE_PhoneNumber'] = 'Invalid PhoneNumber';
  }

  if ($TitleOfCourtesy !== 'Mr.' && $TitleOfCourtesy !== 'Mrs.') {
    $ok = false;
    $_SESSION['RFE_TitleOfCourtesy'] = 'Invalid TitleOfCourtesy (Mr. / Mrs.)';
  }

  $password1 = $_POST['Password1'];
  $password2 = $_POST['Password2'];

  if (strlen($password1) < 4) {
    $ok = false;
    $_SESSION['RFE_Password'] = 'Password: use at least 4 characters';
  }

  if ($password1 !== $password2) {
    $ok = false;
    $_SESSION['RFE_Password'] = 'Passwords do not match';
  }

  $password = password_hash($password1, PASSWORD_DEFAULT);

  $_SESSION['RF_IdentityNumber'] = $IdentityNumber;
  $_SESSION['RF_Email'] = $Email;
  $_SESSION['RF_LastName'] = $LastName;
  $_SESSION['RF_FirstName'] = $FirstName;
  $_SESSION['RF_BirthDate'] = $BirthDate;
  $_SESSION['RF_AreaCode'] = $AreaCode;
  $_SESSION['RF_PhoneNumber'] = $PhoneNumber;
  $_SESSION['RF_TitleOfCourtesy'] = $TitleOfCourtesy;

  require 'connect.php';

  $sql = sprintf("SELECT * FROM `Customers` WHERE IdentityNumber='%s'", mysqli_real_escape_string($conn, $IdentityNumber));
  $result = $conn->query($sql);
  $num_users = $result->num_rows;

  if ($num_users > 0) {
    $ok = false;
    $_SESSION['RFE_IdentityNumber'] = 'This IdentityNumber is already registered';
  }

  $sql = sprintf("SELECT * FROM `Customers` WHERE Email='%s'", mysqli_real_escape_string($conn, $Email));
  $result = $conn->query($sql);
  $num_emails = $result->num_rows;

  if ($num_emails > 0) {
    $ok = false;
    $_SESSION['RFE_Email'] = 'This Email is taken';
  }

  $UserNameBeginning = strtolower(substr($FirstName,0,3).substr($LastName,0,3));
  $sql = sprintf(
    "SELECT * FROM `Customers` WHERE UserName LIKE '%s",
    mysqli_real_escape_string($conn, $UserNameBeginning)
  )."%'";
  $result = $conn->query($sql);
  $num_users = $result->num_rows;
  $UserNameEnd = str_pad($num_users + 1, 4 , '0' , STR_PAD_LEFT);

  $UserName = $UserNameBeginning . $UserNameEnd;
  $RegisterDate = date('Y-m-d');
  $ProfileStatus = 'Active';

  if ($ok == true) {
    $sql = sprintf(
      "INSERT INTO `Customers` VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
      mysqli_real_escape_string($conn, $IdentityNumber),
      mysqli_real_escape_string($conn, $Email),
      mysqli_real_escape_string($conn, $LastName),
      mysqli_real_escape_string($conn, $FirstName),
      mysqli_real_escape_string($conn, $BirthDate),
      mysqli_real_escape_string($conn, $AreaCode),
      mysqli_real_escape_string($conn, $PhoneNumber),
      mysqli_real_escape_string($conn, $TitleOfCourtesy),
      mysqli_real_escape_string($conn, $UserName),
      $password,
      mysqli_real_escape_string($conn, $RegisterDate),
      mysqli_real_escape_string($conn, $ProfileStatus)
    );

    $result = $conn->query($sql);
    if ($result) {
      $_SESSION['Register_UserName'] = $UserName;
      header('Location: index.php');
    }
  }

  $conn->close();
}

function input_value($key) {
  if (isset($_SESSION[$key])) {
    echo $_SESSION[$key];
    unset($_SESSION[$key]);
  }
}

function error_msg($key) {
  if (isset($_SESSION[$key])) {
    echo $_SESSION[$key].'<br>';
    unset($_SESSION[$key]);
  }
}
?>

<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div id="container">
    <form method="post">
      <input type="text" placeholder="IdentityNumber" name="IdentityNumber" value="<?php
        input_value('RF_IdentityNumber'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_IdentityNumber'); ?>

      <input type="text" placeholder="Email" name="Email" value="<?php
        input_value('RF_Email');
      ?>" autocomplete="off"><br>
      <?php error_msg('RFE_Email'); ?>

      <input type="text" placeholder="FirstName" name="FirstName" value="<?php
        input_value('RF_FirstName'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_FirstName'); ?>

      <input type="text" placeholder="LastName" name="LastName" value="<?php
        input_value('RF_LastName'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_LastName'); ?>

      <input type="text" placeholder="BirthDate" name="BirthDate" value="<?php
        input_value('RF_BirthDate'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_BirthDate'); ?>

      <input type="text" placeholder="AreaCode" name="AreaCode" value="<?php
        input_value('RF_AreaCode'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_AreaCode'); ?>

      <input type="text" placeholder="PhoneNumber" name="PhoneNumber" value="<?php
        input_value('RF_PhoneNumber'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_PhoneNumber'); ?>

      <input type="text" placeholder="TitleOfCourtesy" name="TitleOfCourtesy" value="<?php
        input_value('RF_TitleOfCourtesy'); ?>" autocomplete="off"><br>
      <?php error_msg('RFE_TitleOfCourtesy'); ?>

      <input type="password" placeholder="Password" name="Password1"><br>
      <input type="password" placeholder="Confirm password" name="Password2"><br>
      <?php error_msg('RFE_Password'); ?>
      <button type="submit">Register</button>
    </form>
  </div>
</body>
</html>
