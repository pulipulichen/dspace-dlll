## Script (Python) "ZoomifyView"
##bind container=container
##bind context=context
##bind namespace=
##bind script=script
##bind subpath=traverse_subpath
##parameters=width='', height=''
##title=
##

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

zoomifyFolderName = context.id() + '_data'
zoomifyFolder = context.aq_parent[zoomifyFolderName]

zoomifyViewerURL = ''
if hasattr(zoomifyFolder, 'default_ZoomifyViewer'):
  zoomifyViewerURL = zoomifyFolder.default_ZoomifyViewer.absolute_url()
  if hasattr(context.aq_parent, 'zoomifyViewer.swf'):
    useViewer = getattr(context.aq_parent, 'zoomifyViewer.swf')      
    zoomifyViewerURL = useViewer.absolute_url()

return """
<HTML>
  <BODY>
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
  </BODY>
</HTML>
""" % (width, height, zoomifyFolder.absolute_url(), zoomifyViewerURL, 
       zoomifyFolder.absolute_url(), zoomifyViewerURL, width, height)
