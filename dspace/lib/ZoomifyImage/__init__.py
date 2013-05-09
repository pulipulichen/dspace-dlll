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

from AccessControl import allow_module, allow_class
from AccessControl import ModuleSecurityInfo, ClassSecurityInfo
from Globals import InitializeClass

import ZoomifyImage
from ZoomifyImage import manage_addImage
from ZoomifyImage import manage_addImageForm

from ZoomifyBase import ZoomifyBase
from ZoomifyZopeProcessor import ZoomifyZopeProcessor

__all__ = [ZoomifyBase, ZoomifyZopeProcessor, ZoomifyImage]

def initialize(context):

  perm='Add Documents, Images, and Files'
     
  context.registerClass(ZoomifyImage.ZoomifyImage, 
  permission=perm,
  constructors=(('imageAdd',ZoomifyImage.manage_addImageForm),
                 ZoomifyImage.manage_addImage),
  icon='images/Image_icon.gif',
  legacy=(ZoomifyImage.manage_addImage,),
  )
  
ModuleSecurityInfo('Products').declarePublic('ZoomifyImage')
ModuleSecurityInfo('Products.ZoomifyImage').declarePublic('ZoomifyBase')
ModuleSecurityInfo('Products.ZoomifyImage.ZoomifyBase').declarePublic('ZoomifyBase')
ModuleSecurityInfo('Products.ZoomifyImage').declarePublic('ZoomifyZopeProcessor')
ModuleSecurityInfo('Products.ZoomifyImage.ZoomifyZopeProcessor').declarePublic('ZoomifyZopeProcessor')
ModuleSecurityInfo('Products.ZoomifyImage').declarePublic('ZoomifyImage')
ModuleSecurityInfo('Products.ZoomifyImage').declarePublic('manage_addImage')
ModuleSecurityInfo('Products.ZoomifyImage').declarePublic('manage_addImageForm')
ModuleSecurityInfo('Products.ZoomifyImage.ZoomifyImage').declarePublic('manage_editForm')
ModuleSecurityInfo('Products.ZoomifyImage.ZoomifyImage').declarePublic('manage_edit')

allow_module('Products.ZoomifyImage')
allow_module('Products.ZoomifyImage.ZoomifyBase')
allow_class(ZoomifyBase)
allow_module('Products.ZoomifyImage.ZoomifyImage')
allow_module('Products.ZoomifyImage.ZoomifyZopeProcessor')
allow_class(ZoomifyZopeProcessor)

