<?php
session_start();

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
    <form action="login.php" method="post">
      <input type="text" placeholder="Username" name="username"><br>
      <input type="password" placeholder="Password" name="password"><br>
      <button type="submit">Login</button>
    </form>
    <?php if (isset($_SESSION['error'])) echo $_SESSION['error']; ?>
  </div>
</body>
</html>
