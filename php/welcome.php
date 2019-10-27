<?php
session_start();

if (!isset($_SESSION['logged'])) {
  header('Location: index.php');
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
echo 'Welcome '.$_SESSION['username'].'! [<a href="logout.php">log out</a>]<br>';
echo 'Balance: $'.$_SESSION['balance'].'<br>';
?>
  </div>
</body>
</html>
