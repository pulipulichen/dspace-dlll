"""
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

class TreeOps:
	"""
	"""
	DEBUG = False
	
	def __init__(self, debug = False):
		if(debug):
			self.DEBUG = debug
	#end constructor
	
	def debug(self, str):
		if(self.DEBUG):
			print str
	#end def debug
	
	def Compound(self, input, compoundDef, postProcessDef = None):
		done = False
		tree_stack = []
		tree_stack.append([])
		iterations = 0
		inner_iterations = 0
		
		while(len(input)):
			iterations += 1
			a = input.pop(0)
			level = 0
			tree_stack[level].append(a)
			while((len(tree_stack[level]) == 2 or not len(input)) and not done):
				inner_iterations += 1
				self.debug(('  '*level)+str(tree_stack))
				a = tree_stack[level].pop(0)
				if(len(tree_stack[level])):
					b = tree_stack[level].pop(0)
					a = compoundDef(a, b)
				level += 1
				if(len(tree_stack) <= level):
					if not len(input):
						done = True
					tree_stack.append([])
				if(postProcessDef != None):
					a = postProcessDef(a)
				tree_stack[level].append(a)
			self.debug(str(tree_stack))
		self.debug("%d iterations" % iterations)
		self.debug("%d inner_iterations" % inner_iterations)
		
		#at this point, the tree should be
		#fully compounded, with the final value
		#at the last position in the tree stack
		return tree_stack[level][0]
	#end def Compound
	
	def Halve(self, input, termDef, splitDef, postProcessDef = None):
		resultList = []
		tree_stack = []
		tree_stack.append(input)
		iterations = 0
		while(len(tree_stack) > 0):
			iterations += 1
			current = tree_stack.pop()
			if(termDef(current)):
				if(postProcessDef != None):
					current = postProcessDef(current)
				resultList.append(current)
				self.debug("results: "+str(resultList))
			else:
				a, b = splitDef(current)
				tree_stack.append(b)
				tree_stack.append(a)
				self.debug("stack: "+str(tree_stack))
		self.debug("%d iterations" % iterations)
		return resultList
	#end def Halve
	
	def Test(self):
		import string
		
		def termDef(a):
			retVal = False
			if(len(a) == 1):
				retVal = True
			return retVal
		
		def splitDef(a):
			length = len(a)
			offset = length/2 + length%2
			return a[:offset], a[offset:]
		
		def c(a, b):
			return a + b
		
		def p(a):
			return a.upper()
		
		self.DEBUG = True
		
		input = self.Halve(string.ascii_lowercase, termDef, splitDef)
		
		output = self.Compound(input, c, p)
		print output
	#end def Test
#end class TreeOps

























