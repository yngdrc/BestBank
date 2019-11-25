<?php
session_start();

echo $_SESSION['tmp'] . '<br>';

if(isset($_POST['IdentityNumber'])) {
  $ok = true;

  $IdentityNumber = $_POST['IdentityNumber'];
  $Email = $_POST['Email'];
  $LastName = $_POST['LastName'];
  $FirstName = $_POST['FirstName'];
  $BirthDate = $_POST['BirthDate'];
  $AreaCode = $_POST['AreaCode'];
  $PhoneNumber = $_POST['PhoneNumber'];
  $TitleOfCourtesy = $_POST['TitleOfCourtesy'];

  $UserName = strtolower(substr($FirstName,0,3).substr($LastName,0,3)).'0000';
  $RegisterDate = date('Y-m-d');
  $ProfileStatus = "Active";

  // $username = $_POST['username'];
  // if (strlen($username) < 3) { $ok = false; $_SESSION['e_username'] = 'Username: use at least 3 characters'; }
  // if (strlen($username) > 16) { $ok = false; $_SESSION['e_username'] = 'Username: use maximum 16 characters'; }
  // if (ctype_alnum($username) == false) { $ok = false; $_SESSION['e_username'] = 'Username: you can only use letters and numbers'; }

  $password1 = $_POST['Password1'];
  $password2 = $_POST['Password2'];
  if (strlen($password1) < 4) { $ok = false; $_SESSION['e_password'] = 'Password: use at least 4 characters'; }
  if ($password1 != $password2) { $ok = false; $_SESSION['e_password'] = 'Passwords do not match'; }
  $password = $password1; // $password = password_hash($password1, PASSWORD_DEFAULT);

  $_SESSION['f_IdentityNumber'] = $IdentityNumber;
  $_SESSION['f_Email'] = $Email;
  $_SESSION['f_LastName'] = $LastName;
  $_SESSION['f_FirstName'] = $FirstName;
  $_SESSION['f_BirthDate'] = $BirthDate;
  $_SESSION['f_AreaCode'] = $AreaCode;
  $_SESSION['f_PhoneNumber'] = $PhoneNumber;
  $_SESSION['f_TitleOfCourtesy'] = $TitleOfCourtesy;

  require "connect.php";

  $sql = sprintf("SELECT * FROM `Customers` WHERE IdentityNumber='%s'", mysqli_real_escape_string($conn, $IdentityNumber));
  $result = $conn->query($sql);
  $num_users = $result->num_rows;

  if ($num_users > 0) {
    $ok = false;
    $_SESSION['e_IdentityNumber'] = 'This identity number is already registered';
  }

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
      $_SESSION['register_ok'] = true;
      header('Location: index.php');
    }
  }

  $conn->close();
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
        if (isset($_SESSION['f_IdentityNumber'])) {
          echo $_SESSION['f_IdentityNumber'];
          unset($_SESSION['f_IdentityNumber']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="Email" name="Email" value="<?php
        if (isset($_SESSION['f_Email'])) {
          echo $_SESSION['f_Email'];
          unset($_SESSION['f_Email']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="FirstName" name="FirstName" value="<?php
        if (isset($_SESSION['f_FirstName'])) {
          echo $_SESSION['f_FirstName'];
          unset($_SESSION['f_FirstName']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="LastName" name="LastName" value="<?php
        if (isset($_SESSION['f_LastName'])) {
          echo $_SESSION['f_LastName'];
          unset($_SESSION['f_LastName']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="BirthDate" name="BirthDate" value="<?php
        if (isset($_SESSION['f_BirthDate'])) {
          echo $_SESSION['f_BirthDate'];
          unset($_SESSION['f_BirthDate']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="AreaCode" name="AreaCode" value="<?php
        if (isset($_SESSION['f_AreaCode'])) {
          echo $_SESSION['f_AreaCode'];
          unset($_SESSION['f_AreaCode']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="PhoneNumber" name="PhoneNumber" value="<?php
        if (isset($_SESSION['f_PhoneNumber'])) {
          echo $_SESSION['f_PhoneNumber'];
          unset($_SESSION['f_PhoneNumber']);
        }
      ?>" autocomplete="off"><br>

      <input type="text" placeholder="TitleOfCourtesy" name="TitleOfCourtesy" value="<?php
        if (isset($_SESSION['f_TitleOfCourtesy'])) {
          echo $_SESSION['f_TitleOfCourtesy'];
          unset($_SESSION['f_TitleOfCourtesy']);
        }
      ?>" autocomplete="off"><br>

      <input type="password" placeholder="Password" name="Password1"><br>
      <input type="password" placeholder="Confirm password" name="Password2"><br>
      <?php
      if (isset($_SESSION['e_password'])) {
        echo $_SESSION['e_password'].'<br>';
        unset($_SESSION['e_password']);
      }
      ?>
      <button type="submit">Register</button>
    </form>
  </div>
</body>
</html>
