<?php
session_start();

if (!isset($_SESSION['Logged'])) {
  header('Location: index.php');
  exit();
}

require 'connect.php';
require 'base.php';
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
      <a href="add_account.php">add account</a> |
      <a href="transaction.php">transaction</a>
    </div>

    <div id="content">
      <div id="welcome"><?php
        echo 'Welcome '.$_SESSION['FirstName'].' '.$_SESSION['LastName'].'! [<a href="logout.php">log out</a>]<br>';
      ?></div><br>

      <?php session_msg('TransactionInfo'); ?>
      <?php session_msg('TransactionError'); ?>

      <?php
      $sql = sprintf(
        "SELECT * FROM `Accounts` WHERE IdentityNumber='%s'",
        mysqli_real_escape_string($conn, $_SESSION['IdentityNumber'])
      );
      $result = $conn->query($sql);
      $num_accounts = $result->num_rows;

      if ($num_accounts != 0) {
        echo '
        <table class="centerTable">
          <tr>
            <td>Balance</td>
            <td>Number</td>
            <td>Type</td>
            <td>Name</td>
          </tr>';

        while ($row = $result->fetch_assoc()) {
          $Balance = $row['Balance'];
          $AccountNumber = $row['AccountNumber'];
          $AccountType = $row['AccountType'];
          $AccountName = $row['AccountName'];
          echo "
          <tr>
            <td>$Balance</td>
            <td>$AccountNumber</td>
            <td>$AccountType</td>
            <td>$AccountName</td>
          </tr>";
        }

        echo '</table>';
      }
      ?>
    </div>
  </div>
</body>
</html>
