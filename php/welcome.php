<?php
session_start();

if (!isset($_SESSION['Logged'])) {
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
echo 'Welcome '.$_SESSION['FirstName'].' '.$_SESSION['LastName'].'! [<a href="logout.php">log out</a>]<br>';
// TODO: echo 'Balance: $'.$_SESSION['Balance'].'<br>';
?>
  </div>
</body>
</html>
