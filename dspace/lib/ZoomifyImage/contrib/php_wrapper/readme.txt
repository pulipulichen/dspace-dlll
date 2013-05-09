


UPDATE: Justin Henry and Wes Wright have updated this approach to be a full
port of ZoomifyImage in PHP. The code can be found here:
  http://greengaloshes.cc/2007/05/zoomifyimage-ported-to-php/
  
Justin also gives instructions for Zoomifying Flickr images within WordPress:
  http://greengaloshes.cc/2007/06/caching-and-zooming-your-flickr-images/
  



The following is an offline version of a blog entry that can be found at:
  http://www.uvm.edu/~jhenry/wordpress/2006/02/09/batch-converting-for-zoomify-with-zoomifyimage/
  
  
Batch converting for Zoomify with ZoomifyImage
Published by justin February 9th, 2006 in Home, Tool Box, web apps, scripts, Cool Tools

Zoomify is a pretty slick application that allows you to serve “fast, high-res images in flash”. These images can be zoomed in upon, and if you have the “Enterprise” version as we do, the images can be “annotated” with circles, arrows, labels, and more.

Recently I noticed that Wes, in a fantastic example of synergy in action, got Python upgraded on zoo so that it’s now possible to convert images into the necessary format from within a UNIX environment. This opens up some options that we hadn’t had before, such as being able to process images uploaded via a web interface, and provide web initiated batch processing of images.

Today we’ll look at how to get images converted to the “Zoomify” format, using a free, open source Python script. In short, we’ll be covering:

    * Installing the ZoomifyImage package
    * Using a PHP “wrapper” with ZoomifyImage to convert a directory of images
    * Using a PHP script to easily inspect the processed images

Installing the Python scripts and the PIL module

First, download the Python PIL imaging library. Upload it into the account you will be installing it to.

Install PIL. I did something like this, after uploading the file that I downloaded from the above site:

$ tar -xvf Imaging-1.1.5.tar
$ cd Imaging-1.1.5
$ python setup.py install --home=/path/to/desired/location

Note the use of the –home switch, as I don’t have root, and so am installing this module in my home directory. This means that the last part would look something like --home=/users/j/h/jhenry

Get the ZoomifyImage pagckage.

Upload ZoomifyBase.py and ZoomifyFileProcessor.py to a location nearby to where you’ll be processing your images. Edit ZoomifyFileProcessor to allow it to find the PIL library. I did this by adding this line just before the “import PIL.Image” statement.

sys.path.append("/path/to/installed/location/lib/python")

Note that “/path/to/installed/location” should be the same as what I specified with the “–home” switch above. So if I was installing it to my home directory, this might look more like “/users/j/h/jhenry/lib/python”. This tells python to look in the correct directory at runtime for any libraries it might need.

You should now be able to process an image with something like this. I’ve put an image into a directory called upload, which is in the same directory as the ZoomifyFileProcessor.py script.

$ python ZoomifyFileProcessor.py upload/imagename.tif

Converting a directory of images

Soon after I had completed the above, I whipped up a PHP “wrapper” for the python script so that I didn’t have to process images one at a time. Since I’m not all that familiar with Python, and the majority of the applications in which I’ll be using zoomify are built in PHP, this seemed like the way to go. All the wrapper does is look through a specified directory, and execute the ZoomifyFileProcessor.py command on each file that it finds there.

All this wrapper really does is loop through the directory and run the converter on any file that is not a directory, checking to see first if the image hasn’t been already converted. I’ve put it together as a class, so it should be relatively easy to adapt to other applications. Since we’re running in safe mode, it’s easier to run it from the command line, rather than calling it inside of a web process. I’m pretty sure there’s a way around this, but I haven’t had a chance to do further testing. So, I put my zoomify.php class file (which will also be used to check our results, below) and the zoomifyImageWrapper.php file that calls the appropriate function from the zoomify class into the same directory as the zoomifyFileProcessor.py and ZoomifyBase.py files which I previously had uploaded when installing the converter. I’ve made sure to edit the path to my image directory in zoomifyWrapper.php:

$imagepath = "path/to/image/folder/";

Now, assuming I’ve uploaded my images to be converted into this directory, I should be able to run my converter from prompt as such:

$ php zoomifyImageWrapper.php

If you see something like this in the output, you should be on the right track:

zoo> php zoomifyImageWrapper.php 
Content-type: text/html
X-Powered-By: PHP/4.3.8

Processing all files in images/ ...
Processing images/DSCN0680.JPG...
Processing images/DSCN0681.JPG...
Processing images/DSCN0682.JPG...
Processing images/DSCN0683.JPG...

Inspecting a directory of converted images

Now we want to be able to see our results. To do this, I have an index.php file, and the ZoomifyDynamicViewer.php file in the same directory as the zoomify.php class file. I also have the zoomifyDynamicViewer.swf file that came with the Zoomify package. In index.php I set my $imagepath variable to whatever I set it to in zoomifyImageWrapper.php above.

Now when I load up the index.php file in a web browser, I should see a list of links which take me to zoomified versions of my images.

Wrapping Up

After all that, my directory structure looks something like this. You can view the example index file here, and download and view the PHP files as an archived file here.

ZoomifyBase.py
ZoomifyFileProcessor.py
images/
index.php
zoomify.php
zoomifyDynamicViewer.php
zoomifyDynamicViewer.swf
zoomifyImageWrapper.php


Justin Henry
jhenry@uvm.edu
