<?php
session_start();

// if (isset($_SESSION['f_username'])) unset($_SESSION['f_username']);
// if (isset($_SESSION['e_username'])) unset($_SESSION['e_username']);
// if (isset($_SESSION['e_password'])) unset($_SESSION['e_password']);

if ((isset($_SESSION['logged'])) && ($_SESSION['logged'] == true)) {
  header('Location: welcome.php');
  exit();
}
?>

<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div id="container">
    <?php
    if (isset($_SESSION['register_ok'])) {
      unset($_SESSION['register_ok']);
      echo 'Thank you for creating an account!<br><br>';
    }
    ?>
    <form action="login.php" method="post">
      <input type="text" placeholder="UserName" name="UserName"><br>
      <input type="password" placeholder="Password" name="Password"><br>
      <button type="submit">Login</button>
    </form>
    <?php if (isset($_SESSION['error'])) echo $_SESSION['error']; ?>
    <a href="register.php">Create account</a>
  </div>
</body>
</html>
