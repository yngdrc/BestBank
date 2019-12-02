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
    <div><?php
      echo 'Welcome '.$_SESSION['FirstName'].' '.$_SESSION['LastName'].'! [<a href="logout.php">log out</a>]<br>';
    ?></div>

    <?php
    require 'connect.php';

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

    <a href="add_account.php">Add account</a>
  </div>
</body>
</html>
