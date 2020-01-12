<?php
session_start();

if (isset($_SESSION['Logged'])) {
  header('Location: welcome.php');
  exit();
}

require 'base.php'
?>

<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div id="top"><a href="/">BestBank</a></div>
  <div id="container">
    <?php
    if (isset($_SESSION['Register_UserName'])) {
      echo 'Thank you for creating an account!<br>';
      echo 'Your UserName: '.$_SESSION['Register_UserName'].'<br><br>';
      unset($_SESSION['Register_UserName']);
    }
    ?>
    <form action="login.php" method="post">
      <input type="text" placeholder="UserName" name="UserName"><br>
      <input type="password" placeholder="Password" name="Password"><br>
      <button type="submit">Login</button>
    </form>
    <?php session_msg('LoginError'); ?>
    <a href="register.php">Create account</a>
  </div>
</body>
</html>
