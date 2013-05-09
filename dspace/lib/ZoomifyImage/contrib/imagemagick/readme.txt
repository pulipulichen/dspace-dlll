The first thing to do with this class is to adjust the local class variables
"CONVERT" AND "IDENTIFY" to point towards the appropriate Image Magick
executables on your system.

Also, I've defined a limited list of extensions that it will accept for an
input file -- .png, .tif, and .tiff (case insensitive), which could be
expanded, or a smarter method for deciding if a file is zoomifiable might be
used (i.e. parsing the output of identify).  However, this class is designed
specifically for large files.  Within my own workflow framework I divide
files up based on whether they are greater or lesser than 1GB.  This is
somewhat arbitrary, but in line with the memory available on my server. The
smaller files use your ZoomifyImage, as it is radically faster.  The larger
files risk having PIL crash from running out of memory, so I use Image Magick
for them.  The cost is significantly slower processing (as a result of constant,
heavy disk I/O).

Usage should be simple:
import zoomify_im
zim = zoomify_im.ZoomifyIM([path to image])
zim.generateTileSet()

You can adjust some other variables during initialization, but most will result
in Zoomify not being able to deal with your tileset.  You may want to direct the
tiles into a specific directory, for which the parameter "targetDir" is available.

If the user was using this in place of ZoomifyImage because they lacked the
PIL extension, they would be suffering from a minor inefficiency.  The
algorithm for breaking down the file is different, because cost of
performing any one operation on a huge file is so great that I choose to
recursively break the file into halves.  There is an convert option that
allows a single file to be chopped into strips, or even tiles, with a single
command, but on larger files it is either excessively slow or crashes.
Whether or not it would be worth having three options -- PIL, efficient IM,
inefficient (but large file capable) IM I don't know.  Probably if
efficiency on small files is valuable to you, you'll install PIL.


Gawain Lavers
lavers2@llnl.gov
