"""
ZoomifyIM is a python class designed to generate
Zoomify(tm) compatible tileset folders from a tiff or png file

Special thanks to Adam Smith for original PIL version and
assistance in figuring out the zoomify format and approach.

Copyright (C) 2005, Gawain Lavers (lavers2@llnl.gov)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
"""

import os
import math
import string
import random

#local imports
from run import *
from treeops import *
import system_config

class ZoomifyIM:
	"""
		This class chops a single image into the tilesets used
		by zoomify using Imagemagick.  It only operates on tiff
		or png images.
	"""
	
	#Exception codes:
	IMG_EXT_NOT_RECOGNIZIED = "ExtensionNotRecognized"
	IMG_NOT_FOUND = "ImagePathNotFound"
	TARGET_DIR_NOT_FOUND = "TargetDirectoryNotFound"
	CREATE_TARGET_DIR_FAILED = "FailedToCreateTargetDirectory"
	IDENTIFY_PATH_NOT_FOUND = "IdentifyImagePathNotFound"
	CUT_TILE_ERROR = "ErrorCuttingTileFromRow"
	SPLIT_FILE_ERROR = "ErrorSplittingFileInHalf"
	APPEND_ROWS_ERROR = "ErrorAppendingRows"
	RESIZE_ROW_ERROR = "ErrorResizingRow"
	
	#Local constants:
	CONVERT = "/usr/bin/convert"
	IDENTIFY = "/usr/bin/identify"
	DEFAULT_TILE_WIDTH = 256
	DEFAULT_TILE_HEIGHT = 256
	IMAGE_EXTENSIONS = ['.tiff', '.tif', '.png']
	TMP_EXT = ".tiff"
	TILE_EXT = ".jpg"
		
	#Member variables:
	imagePath = None
	tileWidth = None
	tileHeight = None
	targetDir = None
	imageWidth = None
	imageHeight = None
	maxFolderFiles = None
	tileInfo = {}
	
	def __init__(self, imagePath, tileWidth = None, tileHeight = None, maxFolderFiles = 256, targetDir = None):
		if not os.path.exists(imagePath):
			raise self.IMG_NOT_FOUND, imagePath
		imgRoot, ext = os.path.splitext(imagePath)
		if targetDir == None:
			targetDir = imgRoot
		if not os.path.exists(targetDir):
			os.mkdir(targetDir)
		if ext.lower() not in self.IMAGE_EXTENSIONS:
			raise self.IMG_EXT_NOT_RECOGNIZED, ext
		
		if tileWidth == None:
			tileWidth = self.DEFAULT_TILE_WIDTH
		if tileHeight == None:
			tileHeight = self.DEFAULT_TILE_HEIGHT
		
		self.imagePath = imagePath
		self.targetDir = targetDir
		self.imageWidth, self.imageHeight = self.getImageDimensions()
		self.tileWidth, self.tileHeight = tileWidth, tileHeight
		self.maxFolderFiles = maxFolderFiles
		self.currentRow = 0
		self.generateTileInfo()
	#end def __init__
	
	def generateXMLText(self):
		maxDepth = len(self.tileInfo) - 1
		totalTiles = self.tileInfo[maxDepth]['previous'] + self.tileInfo[maxDepth]['tiles']
		data = {}
		data['WIDTH'] = "%d" % (self.imageWidth)
		data['HEIGHT'] = "%d" % (self.imageHeight)
		data['NUMTILES'] = "%d" % (totalTiles)
		data['NUMIMAGES'] = "1"
		data['VERSION'] = "1.8"
		data['TILESIZE'] = "%d" % (self.tileWidth)
		
		data_array = []
		for key in data.keys():
			data_array.append(key+"=\""+data[key]+"\"")
		attributes = string.join(data_array, " ")
		
		return "<IMAGE_PROPERTIES %s />" % attributes
	#end def generateXMLText
	
	def getImageDimensions(self, imagePath = None):
		if imagePath == None:
			imagePath = self.imagePath
		if not os.path.exists(imagePath):
			raise self.IDENTIFY_PATH_NOT_FOUND, imagePath
		cmd = "%s -format \"%%wx%%h\" \"%s\"" % (self.IDENTIFY, imagePath)
		out, err = Run(cmd)
		if(err):
			#I'd kind of like to save this somehow
			#but since there is often non-serious
			#error text, I can't just fail on it
			pass
		return map(int, out.split("x"))
	#end def getImageDimensions
	
	def generateTileInfo(self):
		maxDim = self.imageWidth
		if self.imageHeight > self.imageWidth:
			maxDim = self.imageHeight
		depth = int(math.ceil(math.log(maxDim/(self.tileWidth * 1.0), 2)))
		
		tileInfo = []
		for res in range(depth + 1):
			data = {}
			data['width'] = int(self.imageWidth / pow(2, res))
			data['height'] = int(self.imageHeight / pow(2, res))
			data['rows'] = int(math.ceil(data['height'] / (self.tileHeight * 1.0)))
			data['columns'] = int(math.ceil(data['width'] / (self.tileWidth * 1.0)))
			data['tiles'] = data['rows'] * data['columns']
			tileInfo.append(data)
		
		tileInfo.reverse()
		
		previousFiles = 0
		for depth in range(len(tileInfo)):
			tileInfo[depth]['previous'] = previousFiles
			previousFiles += tileInfo[depth]['tiles']
		self.tileInfo = tileInfo
	#end def generateTileInfo
	
	def getTempFileName(self, path, extension, fStart = "tempFile.", randChars = 6):
		doOnce = True
		fNameChars = string.ascii_letters+string.digits
		while(doOnce or os.path.exists(tempName)):
			doOnce = False
			tempName = fStart
			for i in range(randChars):
				tempName += fNameChars[int(random.random() * len(fNameChars))]
			tempName = os.path.join(path, tempName+self.TMP_EXT)
		return tempName
	#end def getTempFileName
	
	def getTilegroup(self, tilePtr):
		folderNumber = tilePtr/self.maxFolderFiles
		return "TileGroup%d" % folderNumber
	
	def appendRows(self, firstRow, secondRow):
		cmd = "%s \"%s\" \"%s\" -append \"%s\"" % (self.CONVERT, firstRow, secondRow, firstRow)
		return Run(cmd, getStdout = False)
	#end def appendRows
	
	def resizeRow(self, row, percentage):
		#for the purposes of this application, I always expect percentage to be 0.5
		percentage = int(percentage * 100)
		cmd = "%s \"%s\" -resize %d%% \"%s\"" % (self.CONVERT, row, percentage, row)
		return Run(cmd, getStdout = False)
	#end def resizeRow
	
	def cutTile(self, rowFile, tilePath, xOffset):
		cmd = "%s \"%s\" -crop %dx%d+%d+0 \"%s\"" % (self.CONVERT, rowFile, self.tileWidth, self.tileHeight, xOffset, tilePath)
		return Run(cmd, getStdout = False)
	#end def cutTile
	
	def cutTilesFromRow(self, rowFile, depth, rowNumber, tilePtr):
		columns = self.tileInfo[depth]['columns']
		
		for column in range(columns):
			xOffset = column * self.tileWidth
			if not os.path.exists(self.targetDir):
				os.mkdir(self.targetDir)
			tilegroupPath = os.path.join(self.targetDir, self.getTilegroup(tilePtr))
			if not os.path.exists(tilegroupPath):
				os.mkdir(tilegroupPath)
			tileName = "%d-%d-%d%s" % (depth, column, rowNumber, self.TILE_EXT)
			tilePath = os.path.join(tilegroupPath, tileName)
			cutTileRetCode = self.cutTile(rowFile, tilePath, xOffset)
			if cutTileRetCode:
				retData = "Error Code: %d, row: %s, tile: %s" % (cutTileRetCode, rowFile, tilePath)
				raise self.CUT_TILE_ERROR, retData
			tilePtr += 1
		return tilePtr
	#end def cutTilesFromRow
	
	def generateTiles(self, rowList):
		depth = len(self.tileInfo)
		flag = True
		
		while(flag):
			#I use a flag here, because I want to do one
			#more pass after I hit my terminal condition
			depth -= 1
			if(len(rowList) <= 1 and self.tileInfo[depth]['width'] <= 256):
				#I should be able to rely on depth...
				flag = False
			tilePtr = self.tileInfo[depth]['previous']
			newRowList = []
			rowCounter = 0
			while(len(rowList) > 0):
				rowA = rowList.pop(0)
				tilePtr = self.cutTilesFromRow(rowA, depth, rowCounter, tilePtr)
				rowCounter += 1
				if(len(rowList) > 0):
					rowB = rowList.pop(0)
					tilePtr = self.cutTilesFromRow(rowB, depth, rowCounter, tilePtr)
					rowCounter += 1
					appendReturnCode = self.appendRows(rowA, rowB)
					if appendReturnCode:
						retCodeStr = "Error Code: %d, rowA: %s, rowB: %s" % (appendReturnCode, rowA, rowB)
						raise self.APPEND_ROWS_ERROR, retCodeStr
					os.remove(rowB)
				resizeReturnCode = self.resizeRow(rowA, 0.5)
				if resizeReturnCode:
					retCodeStr = "Error Code: %d, row: %s" % (resizeReturnCode, rowA)
					raise self.RESIZE_ROW_ERROR, retCodeStr
				newRowList.append(rowA)
			#end while(len(rowlist) > 0)
			rowList = newRowList
		#end while(flag)
		#get rid of remaining row file
		os.remove(rowA)
	#end def generateTiles
	
	def splitFile(self, filePath, x, y):
		basename, ext = os.path.splitext(filePath)
		basepath, fname = os.path.split(basename)
		cmd = "%s \"%s\" -crop %dx%d \"%s.%%d%s\"" % (self.CONVERT, filePath, x, y, basename, self.TMP_EXT)
		cropRetval = Run(cmd, getStdout = False)
		if cropRetval:
			retData = "Error Code: %d, file: %s" % (cropRetval, filePath)
			raise self.SPLIT_FILE_ERROR, retData
		
		#I know what the new filenames will be:
		topFilename = basename+".0"+self.TMP_EXT
		bottomFilename = basename+".1"+self.TMP_EXT
		
		#But I want them to be something else, or else
		#I will quickly exceed the 256 char filename
		#limit, at least on Mac OS
		newTop = self.getTempFileName(basepath, self.TMP_EXT)
		newBottom = self.getTempFileName(basepath, self.TMP_EXT)
		os.rename(topFilename, newTop)
		os.rename(bottomFilename, newBottom)
		
		return newTop, newBottom
	#end def splitFile
	
	def getHalfByIncrement(self, value, increment):
		increment *= 1.0
		rows = int(math.ceil(value/increment))
		half = rows/2 + rows%2
		halfwayPoint = half * increment
		return halfwayPoint
	#end def getHalfByIncrement
	
	def split(self, file_list):
		currFile, currWidth, currHeight = file_list
		yOffset = self.getHalfByIncrement(currHeight, self.tileHeight)
		topFile, bottomFile = self.splitFile(currFile, currWidth, yOffset)
		topFile_list = (topFile, currWidth, yOffset)
		bottomFile_list = (bottomFile, currWidth, currHeight - yOffset)
		if(currFile != self.imagePath):
			os.remove(currFile)
		return topFile_list, bottomFile_list
	
	def termination(self, file_list):
		currFile, currWidth, currHeight = file_list
		return currHeight <= self.tileHeight
	#end def termination
	
	def rowGen(self, file_list):
		currFile, currWidth, currHeight = file_list
		currRoot, currName = os.path.split(currFile)
		rowFilename = "temprow%04d%s" % (self.currentRow, self.TMP_EXT)
		self.currentRow += 1
		rowFilePath = os.path.join(currRoot, rowFilename)
		os.rename(currFile, rowFilePath)
		return rowFilePath
	#end def rowGen
	
	def splitRows(self):
		imageList = (self.imagePath, self.imageWidth, self.imageHeight)
		self.currentRow = 0
		
		to = TreeOps()
		rowList = to.Halve(imageList, self.termination, self.split, self.rowGen)
		return rowList
	#end def splitRows
	
	def generateTileSet(self):
		self.generateTiles(self.splitRows())
		xmlPath = os.path.join(self.targetDir, 'ImageProperties.xml')
		xml = open(xmlPath, 'w+')
		xml.write(self.generateXMLText())
		xml.close()
		return self.targetDir
	#end def generateTileSet
#end class ZoomifyIM
	




























