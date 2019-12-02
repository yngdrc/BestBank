<?php
function input_value($key) {
  if (isset($_SESSION[$key])) {
    echo $_SESSION[$key];
    unset($_SESSION[$key]);
  }
}

function session_msg($key) {
  if (isset($_SESSION[$key])) {
    echo $_SESSION[$key].'<br>';
    unset($_SESSION[$key]);
  }
}
?>
