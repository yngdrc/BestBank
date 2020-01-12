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
  <link href="https://fonts.googleapis.com/css?family=Roboto&display=swap" rel="stylesheet">
  <link href="style.css" rel="stylesheet">
</head>
<body>
  <div id="container">
    <div id="top">
      <a href="/">
        <img src="logo.jpg" alt="" width="30" height="30">
        BestBank
      </a>
    </div>

    <div id="menu">
      <a href="register.php">create account</a>
    </div>

    <div id="content">
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
    </div>
  </div>
</body>
</html>
