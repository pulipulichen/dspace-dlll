##############################################################################
# Copyright (C) 2006  Donald Ball donald.ball@nashville.gov
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
import os, sys, shutil
import PIL.Image
from ZoomifyFileProcessor import ZoomifyFileProcessor

class ZoomifyDirectoryProcessor(ZoomifyFileProcessor):

    _v_sourceDirectory = ''
    _v_destDirectory = ''
    _v_image = None
    _v_overwrite = False
    _v_min_width = 200
    _v_min_height = 200

    def __init__(self, sourceDirectory, destDirectory):
        self._v_sourceDirectory = sourceDirectory
        self._v_destDirectory = destDirectory

    def setOverwrite(overwrite):
        self._v_overwrite = overwrite

    def setMinWidth(width):
        self._v_min_width = width

    def setMinHeight(height):
        self._v_min_height = height

    def openImage(self):
        if not self._v_image:
            self._v_image = PIL.Image.open(os.path.join(self._v_sourceDirectory, self._v_imageFilename))
        return self._v_image

    def createDataContainer(self):
        root, ext = os.path.splitext(self._v_imageFilename)
        if not ext:
            root = root + '_data'
        self._v_saveToLocation = os.path.join(self._v_destDirectory, root)
        if os.path.exists(self._v_saveToLocation):
            if self._v_overwrite:
                shutil.rmtree(self._v_saveToLocation)
            else:
                return False
        if not os.path.exists(self._v_saveToLocation):
            os.mkdir(self._v_saveToLocation)
        return True
    
    def process(self):
        files = os.listdir(self._v_sourceDirectory)
        for file in files:
            try:
                self._v_imageFilename = file
                self._v_image = None
                self.openImage()
                width, height = self._v_image.size
                if width < self._v_min_width or height < self._v_min_height:
                    continue
                if not self.createDataContainer():
                    continue
                self.getImageMetadata()
                self.processImage()
                self.saveXMLOutput()
            except Exception, ex:
                pass

processor = ZoomifyDirectoryProcessor(sys.argv[1], sys.argv[2])
processor.process()
