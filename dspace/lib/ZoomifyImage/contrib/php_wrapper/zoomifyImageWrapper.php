<?php
include_once "zoomify.php";

$imagepath = "images/";

$zoomifyObject = new zoomify($imagepath);

echo "Processing all files in $imagepath ...\n";

$zoomifyObject->processImages();

echo "Finished processing all files in $imagepath.\n";


?>