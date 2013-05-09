<?php

/****************************************************************************************
Class Name: zoomify

Purpose: methods to support the use of the ZoomifyImage python 
	script, for converting images to the "zoomified" format. 
	Also provides methods for inspecting resulting processed
	images.
	
****************************************************************************************/

class zoomify
{

	//*****************************************************************************
	// constructor
	// initialize process, set class vars
	function zoomify ($imagepath) {
	
		define ("IMAGEPATH", $imagepath);
		
	}
	
	//*****************************************************************************
	//takes path to a directory
	//prints list of links to a zoomified image
	function listZoomifiedImages($dir) {
	    if ($dh = @opendir($dir)) {
	        while (false !== ($filename = readdir($dh))) {
	            if (($filename != ".") && ($filename != "..") && (is_dir($dir.$filename."/")))
	                echo "<a href=\"zoomifyDynamicViewer.php?file=" . $filename . "&path=" . IMAGEPATH ."\">$filename</a><br>\n";
	        }

	    } else return false;

	}	
			
	//*****************************************************************************
	//takes path to a directory
	//returns an array containing each entry in the directory
	function getDirList($dir) {
	    if ($dh = @opendir($dir)) {
	        while (false !== ($filename = readdir($dh))) {
	            if (($filename != ".") && ($filename != ".."))
	                $filelist[] = $filename;
	        }

	        sort($filelist);
        
	        return $filelist;
	    } else return false;

	}

	//*****************************************************************************
	//takes path to a directory
	//returns an array w/ every file in the directory that is not a dir
	function getImageList($dir) {
	    if ($dh = @opendir($dir)) {
	        while (false !== ($filename = readdir($dh))) {
	            if (($filename != ".") && ($filename != "..") && (!is_dir($dir.$filename."/")))
	                $filelist[] = $filename;
	        }

	        sort($filelist);
        
	        return $filelist;
	    } else return false;

	}

	//*****************************************************************************
	// run the zoomify converter on the specified file.
	// check to be sure the file hasn't been converted already
	// set the perms appropriately
	function zoomifyObject($filename, $path) {
	
		$trimmedFilename = $this->stripExtension($filename);
	
		if (!file_exists($path . $trimmedFilename)) {
			echo "Processing " . $path . $filename . "...\n";
			passthru('python ZoomifyFileProcessor.py ' . $path . $filename);
		} else {
			echo "Skipping " . $path . $filename . "... (" . $path . $trimmedFilename . " exists)\n";
		}
	
		passthru('chmod -R 755 ' . $path . $trimmedFilename);
	
	}

	//*****************************************************************************
	// list the specified directory 
	function processImages() {
		$objects = $this->getImageList(IMAGEPATH);

		foreach ($objects as $object) {
			$this->zoomifyObject($object,IMAGEPATH);
		}
	}

	/***************************************************************************/
	//strips the extension off of the filename, i.e. file.ext -> file
	function stripExtension($filename, $ext=".jpg")
	{
	
	    $filename = explode(".",$filename);
	    $file_ext = array_pop($filename);
	    $filename = implode(".",$filename);
	    return $filename; 
	}

}