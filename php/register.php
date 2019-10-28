<?php
session_start();

if(isset($_POST['username'])) {
  $ok = true;

  $username = $_POST['username'];

  if (strlen($username) < 3) {
    $ok = false;
    $_SESSION['e_username'] = 'Username: use at least 3 characters';
  }

  if (strlen($username) > 16) {
    $ok = false;
    $_SESSION['e_username'] = 'Username: use maximum 16 characters';
  }

  if (ctype_alnum($username) == false) {
    $ok = false;
    $_SESSION['e_username'] = 'Username: you can only use letters and numbers';
  }

  $password1 = $_POST['password1'];
  $password2 = $_POST['password2'];

  if (strlen($password1) < 4) {
    $ok = false;
    $_SESSION['e_password'] = 'Password: use at least 4 characters';
  }

  if ($password1 != $password2) {
    $ok = false;
    $_SESSION['e_password'] = 'Passwords do not match';
  }

  $password = password_hash($password1, PASSWORD_DEFAULT);

  $_SESSION['f_username'] = $username;

  require "connect.php";

  $sql = sprintf(
    "SELECT * FROM `Temp` WHERE Username='%s'",
    mysqli_real_escape_string($conn, $username)
  );

  $result = $conn->query($sql);
  $num_users = $result->num_rows;

  if ($num_users > 0) {
    $ok = false;
    $_SESSION['e_username'] = 'This username is already registered';
  }

  if ($ok == true) {
    $sql = sprintf(
      "INSERT INTO `Temp` VALUES ('%s', '%s', %d)",
      mysqli_real_escape_string($conn, $username),
      $password,
      500
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
      <input type="text" placeholder="Username" name="username" value="<?php
        if (isset($_SESSION['f_username']))
          echo $_SESSION['f_username'];
          unset($_SESSION['f_username']);
      ?>" autocomplete="off"><br>
      <?php
      if (isset($_SESSION['e_username'])) {
        echo $_SESSION['e_username'].'<br>';
        unset($_SESSION['e_username']);
      }
      ?>
      <input type="password" placeholder="Password" name="password1"><br>
      <input type="password" placeholder="Confirm password" name="password2"><br>
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
