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

# Override the default PUT_factory method in Zope to accomodate adding
# ZoomifyImage objects via FTP and WebDAV.

import OFS.Folder
import string
from zLOG import LOG, ERROR
       
def PUT_factory(self, name, typ, body):
      
  if name and name.endswith('.pt'):
    from Products.PageTemplates.ZopePageTemplate import ZopePageTemplate
    ob = ZopePageTemplate(name, body, content_type=typ)
  elif typ in ('text/html', 'text/xml', 'text/plain'):
    from OFS.DTMLDocument import DTMLDocument
    ob = DTMLDocument( '', __name__=name )
  elif typ[:6]=='image/':
    try:
      from Products.ZoomifyImage.ZoomifyImage import ZoomifyImage
      ob = ZoomifyImage(name, '', body, content_type=typ)
    except Exception, ex:
      LOG('PUT_factory_error: ', ERROR, ex)
  else:
    from OFS.Image import File
    ob=File(name, '', body, content_type=typ)
  return ob
     
import webdav.NullResource
webdav.NullResource.NullResource._default_PUT_factory = PUT_factory
