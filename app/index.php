<?php
// This folder is shared between your container and your host machine
// So if you modify this file in one, the changes will be reflected in the other.
?>
<div style="max-width:935px; margin:10px auto 0">
  <h1>
    Apacheep Installation Successful!
  </h1>
  <p>Running on <?=php_uname() ?></p>
  <hr>
</div>

<?php
phpinfo();
