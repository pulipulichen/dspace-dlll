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

from OFS.Image import File, Image
import os, transaction
from cStringIO import StringIO
from AccessControl import getSecurityManager, ClassSecurityInfo
from Globals import package_home
from OFS.Image import File
import PIL.Image
import thread
from OFS.Folder import Folder 
from ZoomifyBase import ZoomifyBase

class ZoomifyZopeProcessor(ZoomifyBase):
  """ basic functionality to provide Zoomify functionality inside Zope """
  
  _v_imageObject = None
  _v_saveFolderObject = None
  _v_transactionCount = 0

  security = ClassSecurityInfo()
  security.declareObjectProtected('Add Documents, Images, and Files')
  
  def openImage(self):
    """ load the image data """
    
    return PIL.Image.open(StringIO(str(self._v_imageObject.data)))
      
    return
    
    
  def createDefaultViewer(self):
    """ add the default Zoomify viewer to the Zoomify metadata """
    
    # also, add the default zoomifyViewer here if a zoomify viewer is acquirable
    # (could this be done a better way, like using the 'web methods' 
    # approach that points to ZMI screens that are DTML or ZPT files
    # in the product package)?
    if not hasattr(self._v_saveFolderObject, 'default_ZoomifyViewer'):
      defaultViewerPath = os.path.join(package_home(globals()), 'www', 'zoomifyViewer.swf')
      if os.path.isfile(defaultViewerPath):
        fileContent = open(defaultViewerPath).read()
        self._v_saveFolderObject._setObject('default_ZoomifyViewer', 
                                            File('default_ZoomifyViewer', '', fileContent, 
                                                 'application/x-shockwave-flash', ''))
                                                 
    transaction.savepoint()
    
    return
    

  def createDataContainer(self):
    """ create a folder that contains all the tiles of the image """
    
    self._v_saveToLocation = str(self._v_imageObject.getId()) + '_data'
    
    parent = self._v_imageObject.aq_parent
    if hasattr(parent, self._v_saveToLocation):
      # allow for tiles to be updated from a changed image
      parent._delObject(self._v_saveToLocation)
    
    if not hasattr(parent, self._v_saveToLocation):
      newFolder = Folder()
      newFolder.id = self._v_saveToLocation
      parent._setObject(self._v_saveToLocation, newFolder)
      
    self._v_saveFolderObject = parent[self._v_saveToLocation]
    
    transaction.savepoint()
        
    return
      
      
  def createTileContainer(self, tileContainerName=None):
    """ create a container for the next group of tiles within the data container """ 
     
    if hasattr(self._v_saveFolderObject, tileContainerName):
      # allow for tiles to be updated from a changed image
      self._v_saveFolderObject._delObject(tileContainerName)
    
    if not hasattr(self._v_saveFolderObject, tileContainerName):
      newFolder = Folder()
      newFolder.id = tileContainerName
      self._v_saveFolderObject._setObject(tileContainerName, newFolder)

    transaction.savepoint()
      
    return
    
      
  def getNumberOfTiles(self):
    """ get the number of tiles generated 
        Should this be implemented as a safeguard, or just use the count of 
        tiles gotten from processing? (This would make subclassing a little
        easier.) """
    
    # tiles = 0
    # if (hasattr(self._v_saveFolderObject, self._v_tileContainerName)):
      # tileFolder = getattr(self._v_saveFolderObject, self._v_tileContainerName)
      # tiles =  len(tileFolder._objects)
        
    return self.numberOfTiles
    
    
  def saveXMLOutput(self):
    """ save xml metadata about the tiles """
      
    if hasattr(self._v_saveFolderObject, 'ImageProperties.xml'):
      # allow file to be updated from a changed image, regenerated tiles
      self._v_saveFolderObject._delObject('ImageProperties.xml')
                                                                      
    self._v_saveFolderObject._setObject('ImageProperties.xml', 
                        File('ImageProperties.xml', '', self.getXMLOutput(), 
                             'text/xml', ''))
      
    transaction.savepoint()
      
    return
    
  
  def saveTile(self, image, scaleNumber, column, row):
    """ save the cropped region """
   
    w,h = image.size
    if w != 0 and h != 0:
      tileFileName = self.getTileFileName(scaleNumber, column, row)
      tileContainerName = self.getAssignedTileContainerName(tileFileName=tileFileName)
      
      tileImageData = StringIO()
      image.save(tileImageData, 'JPEG', quality=self.qualitySetting)
      tileImageData.seek(0)
      
      if hasattr(self._v_saveFolderObject, tileContainerName):
        
        tileFolder = getattr(self._v_saveFolderObject, tileContainerName)
        
        # if an image of this name already exists, delete and replace it.
        if hasattr(tileFolder, tileFileName):
          tileFolder._delObject(tileFileName)
          
        # finally, save the image data as a Zope Image object
        tileFolder._setObject(tileFileName, Image(tileFileName, '', '', 'image/jpeg', ''))
        tileFolder._getOb(tileFileName).manage_upload(tileImageData)
        
      self._v_transactionCount += 1
      if self._v_transactionCount % 10 == 0:
        transaction.savepoint()
    
    return
   
  
  def _process(self):
    """ the actual zoomify processing workflow """

    self.createDataContainer()
    self.createDefaultViewer()
    self.openImage()
    self.getImageMetadata()
    self.processImage()
    self.saveXMLOutput()
    
    return
    
    
  def _ZoomifyProcess(self):
    """ factored out ZODB connection handling """
    
    #import Zope
    #app = Zope.app()
    #get_transaction().begin()
    
    self._process()
    transaction.commit()
    
    #app._p_jar.close()
    #del app
    
    return
    
    
  security.declareProtected('Add Documents, Images, and Files', 'ZoomifyProcess')
  def ZoomifyProcess(self, imageObject=None):
    """ factored out threading of process (removed for now) """
    
    if imageObject:
      self._v_imageObject = imageObject
      self._v_imageFilename = imageObject.getId()
      self._ZoomifyProcess()
    
    return
    
    

