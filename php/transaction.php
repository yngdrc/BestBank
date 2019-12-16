<?php
session_start();

if (!isset($_SESSION['Logged'])) {
  header('Location: index.php');
  exit();
}

require 'connect.php';
require 'base.php';

if (isset($_POST['PayerAccountNumber'])) {
  $ok = true;

  $PayerAccountNumber = $_POST['PayerAccountNumber'];
  $RecipientAccountNumber = $_POST['RecipientAccountNumber'];
  $Amount = intval($_POST['Amount']);
  $IdentityNumber = $_SESSION['IdentityNumber'];

  if ($Amount <= 0) {
    $ok = false;
    $_SESSION['TFE_Amount'] = 'Invalid Amount';
  }

  $sql = sprintf(
    "SELECT * FROM `Accounts` WHERE AccountNumber='%s'",
    mysqli_real_escape_string($conn, $PayerAccountNumber)
  );
  $result = $conn->query($sql);
  $row = $result->fetch_assoc();
  $PayerBalance = $row['Balance'];

  if ($Amount > $PayerBalance) {
    $ok = false;
    $_SESSION['TFE_Amount'] = 'You don\'t have enough money';
  }

  $sql = sprintf(
    "SELECT * FROM `Accounts` WHERE AccountNumber='%s'",
    mysqli_real_escape_string($conn, $RecipientAccountNumber)
  );
  $result = $conn->query($sql);
  $num_accounts = $result->num_rows;

  if ($num_accounts == 0) {
    $ok = false;
    $_SESSION['TFE_RecipientAccountNumber'] = 'Invalid RecipientAccountNumber';
  }

  $row = $result->fetch_assoc();
  $RecipientBalance = $row['Balance'];

  if ($ok == true) {
    $NewPayerBalance = $PayerBalance - $Amount;
    $NewRecipientBalance = $RecipientBalance + $Amount;

    $sql = sprintf(
      "UPDATE `Accounts` SET `Balance`='%s' WHERE `AccountNumber`='%s'",
      mysqli_real_escape_string($conn, $NewPayerBalance),
      mysqli_real_escape_string($conn, $PayerAccountNumber)
    );
    $result = $conn->query($sql);

    $sql = sprintf(
      "UPDATE `Accounts` SET `Balance`='%s' WHERE `AccountNumber`='%s'",
      mysqli_real_escape_string($conn, $NewRecipientBalance),
      mysqli_real_escape_string($conn, $RecipientAccountNumber)
    );
    $result = $conn->query($sql);

    $_SESSION['TransactionInfo'] = 'Transaction succeeded';
    header('Location: welcome.php');
  }
}
?>

<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div id="top"><a href="/">BestBank</a></div>
  <div id="container">
    <div><?php
      echo 'Welcome '.$_SESSION['FirstName'].' '.$_SESSION['LastName'].'! [<a href="logout.php">log out</a>]<br>';
    ?></div>

    <?php session_msg('TFE_Amount') ?>
    <?php session_msg('TFE_RecipientAccountNumber') ?>

    <form method="post">
      <table>
        <tr>
          <td>PayerAccountNumber</td>
          <td><?php
            $sql = sprintf(
              "SELECT * FROM `Accounts` WHERE IdentityNumber='%s'",
              mysqli_real_escape_string($conn, $_SESSION['IdentityNumber'])
            );
            $result = $conn->query($sql);
            $num_accounts = $result->num_rows;

            if ($num_accounts == 0) {
              $_SESSION['TransactionError'] = 'You don\'t have any account';
              header('Location: welcome.php');
              exit();
            } else {
              echo '<select name="PayerAccountNumber">';
              while ($row = $result->fetch_assoc()) {
                $AccountNumber = $row['AccountNumber'];
                echo '<option value="'.$AccountNumber.'">'.$AccountNumber.'</option>';
              }
              echo '</select>';
            }
          ?></td>
        </tr>
        <tr>
          <td>RecipientAccountNumber</td>
          <td><input type="text" name="RecipientAccountNumber" size="26"></td>
        </tr>
        <tr>
          <td>Amount</td>
          <td><input type="text" name="Amount" size="26"></td>
        </tr>
      </table>
      <button type="submit">Submit</button>
    </form>
  </div>
</body>
</html>
