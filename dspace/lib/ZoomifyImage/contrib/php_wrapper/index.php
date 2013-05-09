<?php

include_once "zoomify.php";

$imagepath = "images/";
$zoomifyObject = new zoomify($imagepath);

?>

<h1>Zoomify Inspector</h1>
<p>Below is a list of converted images.  If there are none yet, you may need to convert them, i.e.:

<code>
$ php zoomifyImageWrapper.php
</code>

<hr>

<?php

$zoomifyObject->listZoomifiedImages($imagepath);

?>