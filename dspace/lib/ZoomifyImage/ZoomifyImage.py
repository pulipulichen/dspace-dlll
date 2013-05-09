##############################################################################
# Copyright (C) 2005  Adam Smith  asmith@agile-software.com
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################

from OFS.Image import File, Image, getImageInfo, manage_addImageForm, manage_addImage
from OFS.Folder import Folder 
from OFS.ObjectManager import ObjectManager
from Globals import Persistent, DTMLFile, package_home
from OFS.PropertyManager import PropertyManager
from AccessControl.Role import RoleManager
import OFS.FindSupport
from OFS.SimpleItem import Item_w__name__
from cStringIO import StringIO
from Acquisition import Implicit
from OFS.Cache import Cacheable
import os, transaction
from AccessControl import getSecurityManager, ClassSecurityInfo

import PIL.Image
import thread
from ZoomifyBase import ZoomifyBase

StringType=type('')

def cookId(id, title, file):
  """ use instead of the OFS.Image method """\
  
  if not id and hasattr(file,'filename'):
    filename=file.filename
    title=title or filename
    id=filename[max(filename.rfind('/'),
                    filename.rfind('\\'),
                    filename.rfind(':'),
                    )+1:]
    # if this is eventually saved to the filesystem, make sure the id 
    # that is used as the filename is valid
    id = id.replace('.', '_')
    
  return id, title
  
# is there a way to not have to override this method and still get the right
# type of object added?
def manage_addImage(self, id, file, title='', precondition='', content_type='',
                          REQUEST=None):
  """ override Image.manage_addImage """

  id=str(id)
  title=str(title)
  content_type=str(content_type)
  precondition=str(precondition)

  id, title = cookId(id, title, file)

  self=self.this()

  # First, we create the image without data:
  self._setObject(id, ZoomifyImage(id,title,'',content_type, precondition))

  transaction.commit()
  newImage = getattr(self, id)
  
  # Now we "upload" the data.  By doing this in two steps, we
  # can use a database trick to make the upload more efficient.
  if file:
    newImage.manage_upload(file)

  if content_type:
    newImage.content_type=content_type
  
  if REQUEST is not None:
    try:    url=self.DestinationURL()
    except: url=REQUEST['URL1']
    REQUEST.RESPONSE.redirect('%s/manage_main' % url)
    
  return id

                      
class ZoomifyImage(ZoomifyBase, ObjectManager, Image):
  """ override OFS.Image.Image to automatically generate Zoomify metadata """
  
  archiveOriginalImageData = 1
  
  meta_type='Zoomify Image'
  isPrincipiaFolderish = 0
  
  _v_transactionCount = 0

  manage_options=(
      (
      {'label':'Edit Image', 'action':'manage_editForm',
       'help':('OFSP','File_Edit.stx')},
      {'label':'Edit Contents', 'action':'manage_main',
       'help':('OFSP','File_Edit.stx')},
      {'label':'View', 'action':'view',
       'help':('OFSP','File_View.stx')},
      )
      + PropertyManager.manage_options
      + RoleManager.manage_options
      + Item_w__name__.manage_options
      + Cacheable.manage_options
      )
  
  security = ClassSecurityInfo()
  security.declareObjectProtected('Add Documents, Images, and Files')
    
  def manage_upload(self,file='',REQUEST=None):
    """ overrides Image.manage_upload to trigger Zoomify metadata generation 
        whenever file data is uploaded to Zope (covers add and edit methods) """
   
    self._v_imageFilename = file.filename
    Image.manage_upload(self, file=file, REQUEST=REQUEST)
    
    if REQUEST:
      message=""" The image has been saved, and Zoomify metadata is now being
                  generated on the server. It will take time for the process
                  to complete, and for the image data to be available for the
                  Zoomify viewer. """
                 
      return self.aq_parent.manage_main(self,REQUEST,manage_tabs_message=message)
      
  # private
  update_data__roles__=()
  def update_data(self, data, content_type=None, size=None):
    """ Trigger Zoomify metadata creation. """
    
    OFS.Image.Image.update_data(self, data=data, content_type=content_type, size=size)
      
    if data:
      self.ZoomifyProcess()
      
      if not self.archiveOriginalImageData:
          self.data = None

    return
    
        
            
  def preview(self, height=None, width=None, alt=None,
              scale=0, xscale=0, yscale=0, css_class=None, title=None, **args):
    """ allow custom imageEdit form to work as expected by returning 
        Image.tag result for the preview image """
        
    result = ''
    if hasattr(self, 'TileGroup0') and hasattr(self.TileGroup0, '0-0-0.jpg'):
      result = Image.tag(self.TileGroup0['0-0-0.jpg'], height=height, width=width, 
                                                    alt=alt, scale=scale, 
                                                    xscale=xscale, yscale=yscale, 
                                                    css_class=css_class, 
                                                    title=title, **args)
    else:
      result = 'The image is not yet ready to be displayed.'
                                                  
    return result
    
    
  def tag(self, height=None, width=None, alt=None,
          scale=0, xscale=0, yscale=0, css_class=None, title=None, **args):
    """ Override Image.tag method if this can be displayed in Zoomify, 
        otherwise, call Image.tag. This assumes that you want the image to 
        be displayed in Zoomify, but you also want it to fail gracefully if
        the metadata isn't yet available.
    """
    
    # use a packaged Zoomify viewer for convenience, but allow it to be 
    # overridden in Zope
    zoomifyViewerURL = ''
    if hasattr(self, 'default_ZoomifyViewer'):
      zoomifyViewerURL = self.default_ZoomifyViewer.absolute_url()
      if hasattr(self.aq_parent, 'zoomifyViewer.swf'):
        useViewer = getattr(self.aq_parent, 'zoomifyViewer.swf')      
        zoomifyViewerURL = useViewer.absolute_url()
      
    result = ''
    if hasattr(self, 'ImageProperties.xml') and zoomifyViewerURL: 
        
      if height is None: height='100%'
      if width is None:  width='100%'

      # can I work in these Image.tag capabilities in a way that makes sense?
      # # Auto-scaling support
      # xdelta = xscale or scale
      # ydelta = yscale or scale
# 
      # if xdelta and width:
          # width =  str(int(round(int(width) * xdelta)))
      # if ydelta and height:
          # height = str(int(round(int(height) * ydelta)))

      # if alt is None:
          # alt=getattr(self, 'title', '')
      # result = '%s alt="%s"' % (result, escape(alt, 1))
# 
      # if title is None:
          # title=getattr(self, 'title', '')
      # result = '%s title="%s"' % (result, escape(title, 1))
# 
      # if not 'border' in [ x.lower() for x in  args.keys()]:
          # result = '%s border="0"' % result
# 
      # if css_class is not None:
          # result = '%s class="%s"' % (result, css_class)

      # otherAttributes = ''
      # for key in args.keys():
          # value = args.get(key)
          # otherAttributes = ' %s %s="%s"' % (otherAttributes, key, value)
        
      result = """
      <OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" 
              codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" 
              id="theMovie"
              width="%s"
              height="%s">
            
        <PARAM name="FlashVars" 
               value="zoomifyImagePath=%s">
        <PARAM name="src" 
               value="%s">
        
        <EMBED FlashVars="zoomifyImagePath=%s" 
               SRC="%s" 
               width="%s"
               height="%s"
               pluginspace="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"  
               name="theMovie"></EMBED> 
                
      </OBJECT>
      """ % (width, height, self.absolute_url(), zoomifyViewerURL, 
             self.absolute_url(), zoomifyViewerURL, width, height)
      
    else:
      
      # fail gracefully
      # display a manageable size, being careful not to download the entire
      # original image data
      result = self.preview(height=height, width=width, alt=alt, scale=scale, 
                            xscale=xscale, yscale=yscale, css_class=css_class, 
                            title=title, **args)                                   
                            
    return result
  
  def index_html(self):
    """ a default view of the image that allows for Zoomify viewer """
    
    result = """
      <HTML>
        <BODY>
          %s
        </BODY>
      </HTML>
    """ % self.tag()
    
    return result
    
  def view(self):
    """ a default view of the image that allows for Zoomify viewer """
    
    return self.index_html()

    
  def openImage(self):
    """ load the image data """
      
    return PIL.Image.open(StringIO(str(self.data)))


  def createDefaultViewer(self):
    """ add the default Zoomify viewer to the Zoomify metadata """
    
    # add the default zoomifyViewer here if a zoomify viewer is acquirable
    # (could this be done a better way, like using the 'web methods' 
    # approach that points to ZMI screens that are DTML or ZPT files
    # in the product package)?
    if not hasattr(self, 'default_ZoomifyViewer'):
      defaultViewerPath = os.path.join(package_home(globals()), 'www', 'zoomifyViewer.swf')
      if os.path.isfile(defaultViewerPath):
        fileContent = open(defaultViewerPath).read()
        self._setObject('default_ZoomifyViewer', 
                        File('default_ZoomifyViewer', '', fileContent, 
                             'application/x-shockwave-flash', ''))
                                                 
    transaction.savepoint
    
    return
    
    
  def createDataContainer(self):
    """ create a folder that contains all the tiles of the image 
        This object is a container, so just be sure that any previous
        metadata that was generated is cleared. """
      
    self.manage_delObjects(self.objectIds())

    return
      
      
  def createTileContainer(self, tileContainerName=None):
    """ create a container for the next group of tiles within the data container """ 
     
    if tileContainerName:
      if hasattr(self, tileContainerName):
        # allow for tiles to be updated from a changed image
        self._delObject(tileContainerName)
      
      if not hasattr(self, tileContainerName):
        newFolder = Folder()
        newFolder.id = tileContainerName
        self._setObject(tileContainerName, newFolder)
        
      ob = self._getOb(tileContainerName)
      transaction.savepoint()
      
    return
    
    
  def saveXMLOutput(self):
    """ save xml metadata about the tiles """
      
    if hasattr(self, 'ImageProperties.xml'):
      # allow file to be updated from a changed image, regenerated tiles
      self._delObject('ImageProperties.xml')
      
    self._setObject('ImageProperties.xml', 
                    File('ImageProperties.xml', '', self.getXMLOutput(), 
                         'text/xml', ''))
      
    transaction.savepoint()
    
    return
    
  
  def saveTile(self, image, scaleNumber, column, row):
    """ save the cropped region """
  
    w,h = image.size
    if w != 0 and h != 0:
      tileImageData = StringIO()
      image.save(tileImageData, 'JPEG', quality=self.qualitySetting)
      tileImageData.seek(0)
      
      tileFileName = self.getTileFileName(scaleNumber, column, row)
      tileContainerName = self.getAssignedTileContainerName(tileFileName=tileFileName)
      
      if hasattr(self, tileContainerName):
        
        tileFolder = getattr(self, tileContainerName)
  
        # if an image of this name already exists, delete and replace it.
        if hasattr(tileFolder, tileFileName):
          tileFolder._delObject(tileFileName)
          
        tileFolder._setObject(tileFileName, Image(tileFileName, '', '', 'image/jpeg', ''))
        
        tileFolder._getOb(tileFileName).manage_upload(tileImageData)
  
      self._v_transactionCount += 1  
      if self._v_transactionCount % 5 == 0:
        transaction.savepoint()
      
    return
    
    
  
  def _process(self):
    """ the actual zoomify processing workflow """

    self.createDataContainer()
    self.createDefaultViewer()
    self.getImageMetadata()
    self.processImage()
    self.saveXMLOutput()
    
    return
    
    
  def _ZoomifyProcess(self):
    """ factored out ZODB connection handling """
    
    #import Zope
    #app = Zope.app()
    #get_transaction().begin(1)
    
    self._process()
    transaction.savepoint()
    
    #app._p_jar.close()
    #del app
    
    return
    

  security.declareProtected('Add Documents, Images, and Files', 'ZoomifyProcess')
  def ZoomifyProcess(self):
    """ factored out threading of process """

    transaction.savepoint()
    #thread.start_new_thread(self._ZoomifyProcess, ())
    self._ZoomifyProcess()
    
    return

  manage_editForm  =DTMLFile('dtml/imageEdit',globals(),
                              Kind='Image',kind='image')
  manage_editForm._setName('manage_editForm')
    
    
        
