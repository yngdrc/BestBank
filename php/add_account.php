<?php
session_start();

if (!isset($_SESSION['Logged'])) {
  header('Location: index.php');
  exit();
}

require 'connect.php';

function randomNumber($length=26) {
  $characters = '0123456789';
  $charactersLength = strlen($characters);
  $accountNumber = '';
  for ($i=0; $i < $length; $i++) {
      $accountNumber .= $characters[rand(0, $charactersLength-1)];
  }
  return $accountNumber;
}

if (isset($_POST['AccountType'])) {
  $AccountNumber = randomNumber(2) . '12345678' . randomNumber(16);
  $AccountType = $_POST['AccountType'];
  $IdentityNumber = $_SESSION['IdentityNumber'];
  $AccountName = $_POST['AccountName'];
  $Balance = 2000;
  $OpeningDate = date('Y-m-d');
  $AccountStatus = 'Active';

  $sql = sprintf(
    "INSERT INTO `Accounts` VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', NULL)",
    mysqli_real_escape_string($conn, $AccountNumber),
    mysqli_real_escape_string($conn, $AccountType),
    mysqli_real_escape_string($conn, $IdentityNumber),
    mysqli_real_escape_string($conn, $AccountName),
    mysqli_real_escape_string($conn, $Balance),
    mysqli_real_escape_string($conn, $OpeningDate),
    mysqli_real_escape_string($conn, $AccountStatus)
  );

  $result = $conn->query($sql);
  if ($result) {
    header('Location: welcome.php');
    exit();
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
    <div><?php
      echo 'Welcome '.$_SESSION['FirstName'].' '.$_SESSION['LastName'].'! [<a href="logout.php">log out</a>]<br>';
    ?></div>

    <form method="post">
      <?php
      $sql = sprintf(
        "SELECT * FROM `AccountTypes`",
        mysqli_real_escape_string($conn, $_SESSION['IdentityNumber'])
      );
      $result = $conn->query($sql);

      while ($row = $result->fetch_assoc()) {
        $AccountType = $row['AccountType'];
        echo '<input type="radio" name="AccountType" id="'.$AccountType.'" value="'.$AccountType.'">';
        echo '<label for="'.$AccountType.'">'.$AccountType.'</label><br>';
      }
      ?>
      <input type="text" placeholder="AccountName" name="AccountName"><br>
      <button type="submit">Add</button>
    </form>
  </div>
</body>
</html>
