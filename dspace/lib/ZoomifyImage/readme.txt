--------------------
CONTENTS
--------------------
  DESCRIPTION
  WHO MAY AND MAY NOT BENEFIT FROM THIS SOFTWARE
  DEPENDENCIES
  LICENSE
  INSTALLATION
  USAGE
    - Command line/ Filesystem
    - Zope with OFS.Image objects in the ZODB
    - Zope with ZoomifyImage objects in the ZODB
    - Zope via FTP or WebDAV
  KNOWN ISSUES
  TO DO
  DEVELOPER NOTES
  CONTRIBUTIONS
  CREDITS/RESOURCES
--------------------



___________________________
DESCRIPTION

The ZoomifyImage product allows you to use Zoomify (http://www.zoomify.com/)
from the command line and within the Zope environment to quickly and 
interactively view large, high resolution images over the Web.



___________________________
WHO MAY AND MAY NOT BENEFIT FROM THIS SOFTWARE

ZoomifyImage has two goals: 1) to provide a cross-platform option for processing
images for display within the Zoomify viewer, and 2) to integrate Zoomify into
the Zope Application Server. Therefore, if you want to use Zoomify in your Zope
based site, or if you just want to be able to process images on your
non-Windows/non-Mac based system, you may find this software useful.

Be aware, however, that compared to the official Zoomify processing software,
ZoomifyImage is limited in terms of speed and the size of images that it can
reasonably process. I have used ZoomifyImage on images that are tens of 
megabytes large, and others have reported that it works for images that are
hundreds of megabytes large on higher end hardware. Above that, particularly in
the multi-gigabyte range, ZoomifyImage may simply run out of memory. 

At this point, I believe the weak link performance-wise is the way I am loading
the image data into memory with PIL. Another option is to use Gawain Lavers' 
scripts in the 'contrib' folder, which uses ImageMagick and can process larger
files. Depending on when I can get time to work more on ZoomifyImage, I would
like to make the use of third party imaging software more pluggable to allow for
ImageMagick integration into the core software.



___________________________
DEPENDENCIES

ZoomifyImage requires the Python Imaging Library (PIL) with JPEG support. You
can get PIL at:
  http://www.pythonware.com/products/pil/
  
The installation documentation that comes with PIL will tell you where to get
the JPEG libraries and what versions to use. If you use MacOSX, you can find
binaries of PIL with JPEG support here:
  http://sourceforge.net/projects/mosxzope/

The current version of ZoomifyImage has been tested in the following environments:

  - Zoomify 3.1
  - Python 2.4.5
  - PIL 1.1.4
  - Zope 2.10 

Note that due to deprecations and removals in Zope's transaction handling,
this version of ZoomifyImage requires Zope 2.8 or newer.

The free 'EZ' version of the Zoomify viewer is packaged with the product, so 
you can begin using the product immediately out of the box. Note that this file
has its own licensing terms defined in the accompanying license_Zoomify.txt 
file. You can always download the latest version of this viewer for free at:
  http://www.zoomify.com



___________________________
LICENSE

This product contains a Flash (*.swf) file that is covered by the accompanying
license_Zoomify.txt license and should not be considered part of the Zope
ZoomifyImage product. All other files that are part of the Zope ZoomifyImage
Product are covered by the GNU General Public License contained in the 
license_Zope_ZoomifyImage_Product.txt file.



___________________________
INSTALLATION

After unpacking ZoomifyImage, move it to the Products directory of your Zope 
installation. Prior to the 2.7.0 version of Zope, that location was:
  <zope_home>/lib/python/Products/
  
Since 2.7.0, the location is:
  <zope_instance_home>/Products/
  
Check your Zope documentation if you are unsure where to place new products.



___________________________
USAGE

I have provided several ways of using this product depending on your needs. For 
each of these methods, previously generated metadata for images being 
reprocessed are automatically cleaned up for you before the Zoomify metadata is
regenerated.

The input file for any of these processes can be in any format that Zope 
recognizes as having a content-type of 'image/...' and which PIL can read. 
JPEG's are always produced for the Zoomify viewer. The only 'gotcha' is that the
Zoomify viewer does not like to see Zope OFS.Image or ZoomifyImage objects with
extensions other than '.jpg' such as '.tif'; it will fail to display the image. 
To avoid this issue, give the image a different Zope id -- even changing the 
file extension part of the id from say, '.tif' to '_tif' will work, or you can
simply not use an extension. (I could have the Zope approaches check for this 
and automatically make name changes where appropriate, but I have tentatively
decided that this is too aggressive.)

All Python files mentioned in these instructions are included with the 
ZoomifyImage product.
  

Command line/ Filesystem

If you simply want to use Zoomify as it was originally intended, but want the
ability to process images on a Unix platform or have control of the image
processing from the command line, you can call the process from Python in the
usual manner:
  > python ZoomifyFileProcessor.py <your_image_file>
  
This approach essentially replicates Zoomify's own processing program available
on Windows and MacOSX. It creates a new directory in the same location as the
image file based on the file name of the image. For example, an image called
'test.jpg' would have a corresponding folder called 'test' containing all the
metadata needed by the Zoomify viewer. If there is no file extension on the 
image file name, the folder is named by appending '_data' to the image name. So,
and image file named 'test' would have a corresponding directory called 
'test_data'.

When processing is complete, follow the instructions that accompany Zoomify to 
use this data in your environment. Also note that this approach allows you to 
pass multiple files to the script.
 

Zope with OFS.Image objects in the ZODB

If you want to use Zoomify with existing images in your Zope site, add a 
Python script to Zope and copy and paste the contents of 
ZoomifyZopeProcessorScript.py into that script. Now you can process a normal 
OFS.Image object in Zope in a way that mimics the command line/filesystem 
approach. So, if you have an Image object here:
  http://<your_site>/test/test.jpg
  
...and you have saved the Python script, as say, 'ZoomifyProcess' where it can 
be acquired by the Image object, you can call that script on the image in the 
following manner:
  http://<your_site>/test/test.jpg/ZoomifyProcess

The Zoomify metadata is saved in a folder called:
  <image_object_name>_data

in the same location as the Image object. In addition to the normal metadata,
an OFS.File object called default_ZoomifyViewer is created. This is the Flash 
'EZ' version of the Zoomify viewer. It is included as a convenience.

So, to display this Image object in Zoomify, create a Python script in Zope and
copy and paste the contents of the ZoomifyZopeViewScript.py file into that 
script, taking care to add the width and height parameters as indicated in the 
comments of that file. Again, if you have an Image object here:
  http://<your_site>/test/test.jpg
  
...and you saved the second Python script, as say, 'ZoomifyView' where it can be
acquired by the Image object, you can call that script on the Image in the
following manner:
  http://<your_site>/test/test.jpg/ZoomifyView?width=700&height=700
  
This view script is written in such a way that by default, it uses the 
default_ZoomifyViewer object that was created with the Zoomify metadata. This is
for your convenience, but if you want to create and use a custom Zoomify viewer,
simply upload it in a location where it can be acquired by the script and the
Image object, and call it 'zoomifyViewer.swf'. The view script will then use
this viewer instead.

The ZoomifyImage product has liberal security settings which allow you to call
it from Python scripts this way. However, there are some versions of Zope in 
which this machinery is a little buggy and will not allow you to access the
product's code directly despite these settings. In this case, simply convert the 
'ZoomifyProcess' script into an external method:

   1. In the Zope management interface, add an 'External Method'
   2. Populate the external method object in the following manner:
        id:ZoomifyProcess
        module name:ZoomifyProcess
        function name:ZoomifyProcess
   3. In your Zope 'Extensions' folder at: 
        <zope_home>/Extensions/
        (or at <zope_instance_home>/Extensions/ in 2.7.0 and later)
      ... create a new file called ZoomifyProcess.py and past the following into
      it:
# begin cut/paste      
def ZoomifyProcess(self):
  """ start the zoomify process on this image """
  if hasattr(self, 'content_type') and self.content_type.startswith('image'):  
    from Products.ZoomifyImage.ZoomifyZopeProcessor import ZoomifyZopeProcessor
    ZoomifyZopeProcessor().ZoomifyProcess(self)
  return
# end cut/paste
      

Zope with ZoomifyImage objects in the ZODB

The previous two methods may fit your particular environment, but if you use 
Zope and you are uploading new images, there is a far more powerful method for
using Zoomify. This method uses the true ZoomifyImage product, which is a thin
wrapper around the OFS.Image and OFS.ObjectManager objects that adds the 
capability to generate Zoomify metadata.

From the Zope Management Interface (ZMI), add a 'Zoomify Image' object. The add
form will be the same form you are accustomed to using for regular 'Image' 
objects. When you upload an image, the Zoomify metadata is automatically 
generated for you on the server within the image object. If you edit the object
and upload a new image, the Zoomify metadata is automatically refreshed for you.

If you click on the image to edit it in the ZMI, you will see that the usual 
edit tab is now called 'Edit Image' and a new tab appears next to it called 
'Edit Contents' which gives you the folder view of the Zoomify metadata
contained in the image object.

To view the image, you can call the 'view' method of the object. So, for a
Zoomify Image at:
  http://<your_site>/test/test.jpg
  
you can view the image in Zoomify by going to:
  http://<your_site>/test/test.jpg/view
    
To include this view of the image in your own pages, simply call the 'tag' 
method of the image as you would a normal Image object in Zope. So, in a Page 
Template, you might display it this way:
  <span tal:replace="here/test.jpg/tag"/>

Note that if the process of generating the Zoomify metadata is not yet complete 
when you try to view it, the object will try to call the tag method on the 
0-0-0.jpg version of the image before giving up and informing the user that the 
image is not yet ready to be viewed. (The 0-0-0.jpg version of the image will be
explained in the 'Developer Notes' section later.)

As with the previous Zope approach, the default_ZoomifyViewer object is created
with the Zoomify metadata and will be used by default. You can override it the
same way, by creating a custom Zoomify viewer called 'zoomifyViewer.swf' in a
location where the ZoomifyImage object can acquire it.


Zope via FTP or WebDAV

You may also create ZoomifyImage objects in Zope using a FTP or WebDAV client. 
To do this, override the default PUT_factory method in the following manner 
(adapted from 'The Zope Book' 2.6 edition):

   1. Copy the accompanying PUT_factory.py file to your Zope 'Extensions' 
      folder at: 
        <zope_home>/Extensions/
        (or at <zope_instance_home>/Extensions/ in 2.7.0 and later)
   2. In the Zope management interface, add an 'External Method'
   3. Populate the external method object in the following manner:
        id:PUT_factory
        title:custom Zoomify PUT factory 
        module name:PUT_factory
        function name:PUT_factory
  
This PUT_factory method is the same as the default used by Zope except that any
uploaded image that acquires this PUT_factory is saved as a ZoomifyImage object
instead of an OFS.Image object, and Zoomify metadata is automatically generated
on the server in the same manner as when you create ZoomifyImage objects in the
ZMI.



___________________________
KNOWN ISSUES

First, be aware that ZoomifyImage is a complete Python port of the Zoomify 
processing software provided by Zoomify Incorporated, which is written in C++. 
Therefore, ZoomifyImage will not be as fast or be able to process images as 
large as Zoomify Incorporated's software can.

ZoomifyImage has gone through a few phases, starting with trying to simply be
a correct, faithful Python port of the Zoomify processing software. I then
added code to write out temporary files to free up RAM and allow for the 
processing of larger files. I have found memory management with PIL to be 
challenging however, and this is currently the main limit to the software.

If you need a cross platform method like ZoomifyImage, but are hitting its 
limits, I recommend that you look at Gawain Lavers' software in the 'contrib'
folder.



___________________________
TO DO

I want to improve the 'tag' method so it can be used more flexibly for 
displaying the Zoomify viewer. I need to investigate the different options that
might be passed to a Zoomify viewer and how they are specified. 

I have also thought about adding the ability to create a simple configuration
file to control certain aspects of processing. 

I have attempted to explicitly do processing in a separate thread within Zope. 
Ideally, I would like the method to return a response to a client while the 
zoomify processing continues on the server. I have not been very successful, 
however, and have tentatively abandoned doing this, as the transaction 
mechanism in Zope seems to do a decent job of threading in the first place. 
After researching list postings, more experienced Zope developers seem to prefer
using ZEO to address these issues anyway. In the meantime, I have left the code
in place, commented, and may return to it later. (If anyone else is interested
in pursuing this, I can provide useful links to people who describe how to 
approach multithreading in Zope. Essentially, the new thread needs to explicitly
open and close its own ZODB connection.)



___________________________
DEVELOPER NOTES

To be viewed within the Zoomify viewer, an image must be processed to produce 
'tiles' of the image at different scales or 'tiers' along with an XML file that 
describes the generated tiles.

Conceptually, the process is simple: starting with the original image at 100% 
scale, the image is repeatedly scaled down by half to produce the next 'tier' 
until both the width and the height are less than 256 pixels. Each version of 
the image at a tier is then divided into tiles. Each tile is 256 pixels wide and 
256 pixels tall, except on the right and bottom edges of the image where the 
width and height may be less than 256 pixels depending on the dimensions of the 
image at that tier. Tiles are created like this from left to right, then top to
bottom.

To better handle very large images, this process is actually done by loading the
original image in strips that are 256 pixels high (except possibly the last 
strip at the bottom of the image) and the width of the image. Each strip is cut 
into tiles 256 pixels wide (except possibly the last tile for each row) from 
left to right to create the tiles for that tier. (It might help to think of this
process as 'slicing and dicing'.) Then the row is scaled down by half and saved
to a temporary file. For every two half-scaled rows created in a particular 
tier, a row can be processed in the next tier by combining the two previous 
half-scaled rows, and the process of creating the tiles and scaling the image by
half is repeated.

The tiles are saved according to a naming convention:
  z-y-x.jpg
where z is a reference to the tier from which the tile was created; the smallest 
scaled tier is 0. The y and x indicate the column number and row number of the 
tile with respect to the other tiles at that tier. So, at the smallest tier, the 
image is contained in one file called '0-0-0.jpg' which is less than 256x256.

Tiles are saved in directories or folders in groups of 256. These 
directories also follow a naming convention, beginning with the 'TileGroup0' 
directory, then 'TileGroup1' and so on. The Zoomify viewer expects lower 
numbered tile groups to contain tiles for lower numbered tiers. So, the 
0-0-0.jpg image will always be in TileGroup0.

The entire logic of this process, including the format of the XML file that 
accompanies the tiles, is encapsulated in the ZoomifyBase.py file. Look 
particularly at the processImage and processRowImage methods.


Here is a brief overview of the main classes of the ZoomifyImage product. 

ZoomifyBase.py
This is the base class that contains the logic for generating Zoomify metadata.
This class is never meant to be called directly, and only provides placeholders
for methods that subclasses will likely need to implement.

ZoomifyFileProcessor.py
This is a subclass of the ZoomifyBase class that provides a command line
interface for creating Zoomify metadata on the filesystem. This class 
essentially reproduces the Zoomify drag-and-drop converter available on Windows
and MacOSX.

ZoomifyZopeProcessor.py
This is another subclass of the ZoomifyBase class that replicates the basic
approach of the command line interface within the Zope environment. It has
liberal security settings to allow for custom Python scripts in Zope to use it
without the need for writing external methods. This class is intended for those
who have existing images in Zope that they would like to present within the
Zoomify viewer.

ZoomifyImage.py
Another subclass of ZoomifyBase that is also a thin wrapper around the 
OFS.Image and OFS.ObjectManager classes. The Zoomify processing is 
triggered by the manage_upload method which is used by both the add and edit
methods. For ZoomifyImage objects created using FTP or WebDAV, the processing
is triggered by the manage_afterAdd method. If you are adding new images into
Zope that you would like to automatically process and present within the Zoomify
viewer, this new object type provides the most functionality.


The Zope classes implement subtransactions for better process management while 
generating Zoomify metadata.



___________________________
CONTRIBUTIONS

The 'contrib' directory in this distribution contains code from users of 
ZoomifyImage who have either extended it or come up with alternative
approaches. Each author has given me permission to add their code to this
distribution so others can benefit from their work. I thank them, and encourage
anyone else who has done similar work to contact me so I can add their work to
future releases.


imagemagick
by Gawain Lavers, lavers2@llnl.gov

Another Python based approach to processing images for viewing with Zoomify. 
It uses ImageMagick instead of PIL and is capable of processing larger images 
than can ZoomifyImage

-----

php_wrapper
by Justin Henry, jhenry@uvm.edu

A PHP wrapper around the ZoomifyImage software allowing it to be used in a 
PHP environment.

UPDATE: Justin Henry and Wes Wright have updated this approach to be a full
port of ZoomifyImage in PHP. The code can be found here:
  http://greengaloshes.cc/2007/05/zoomifyimage-ported-to-php/
  
Justin also gives instructions for Zoomifying Flickr images within WordPress:
  http://greengaloshes.cc/2007/06/caching-and-zooming-your-flickr-images/
  
-----

netpbm_shell_script
by Fran Firman, ffirman@netgate.net.nz

A shell script that uses the NETPBM package to create the Zoomify tiles and 
XML file. A very nice alternative for UNIX/Linux users who want a small,
scriptable command line approach. This should also be able to handle much
larger images than ZoomifyImage since the underlying image manipulation is
performed by compiled C code.

-----

ZoomifyDirectoryProcessor
by Donald Ball, donald.ball@nashville.gov

This provides "a class to process a source directory of mixed files (images 
and other media) and write the zoomify directories to a separate destination 
directory."

Donald is also actively developing a Ruby port of ZoomifyImage which may
eventually be included in ZoomifyImage's contrib directory or be distributed
as a gem by Donald himself. Either way, when the time comes, one of us will
probably alert the ZoomifyImage support forum to its availability.


___________________________
CREDITS/RESOURCES

Special thanks to David Urbanic, President and CEO of Zoomify Inc., for his 
insights into how the Zoomify client application works, as well as his 
suggestions and encouragement.

Thanks also to those who have generously given me valuable feedback on 
ZoomifyImage. In particular, various people on the PIL listserv have given me 
much needed advice, and Gawain Lavers, Ciaran Clissmann, Donald Ball, Anthony 
Paul, Tomasz Rodecki and Johannes Raggam have patiently worked with me to 
diagnose and fix bugs. Gawain also contributed a nice alternative approach to 
processing images using ImageMagick. I am also honored that Justin Henry took 
the time to write a PHP wrapper around ZoomifyImage. Gawain and Justin 
graciously allowed me to package their work with ZoomifyImage. Both are 
available in the 'contrib' directory.

Code in the ZoomifyImage product subclasses the OFS.Image product that comes 
with the standard Zope installation. So, thank you to Python and Zope for 
making my life easier and for making me look smarter than I am. And thank you 
to SourceForge for hosting the project.

