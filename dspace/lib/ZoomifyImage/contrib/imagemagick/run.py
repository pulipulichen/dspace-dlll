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

#this module designed to run external programs
import os

def QuadOp(val, low, high, lowRet, midRet, highRet):
	"""	quadrenary operator:  takes in a value, a low range limit
		a high range limit, and three return values
		if the value is lower than the range defined by the low and
		high range limits, the first return is used, if the value is
		higher than the range, the third return is used, otherwise
		the second return is used
	"""
	QUAD_OP_ERROR = "QuadrenaryOperatorInputError"
	if(low > high):
		errString = "Error: %s is greater than %s" % (low, high)
		raise QUAD_OP_ERROR, errString
	else:
		if(val < low):
			return lowRet
		elif(val > high):
			return highRet
		else:
			return midRet
		#end if-elif-else
	#end if-else
#end def QuadOp

def TernOp(boolVal, ifRet, elseRet):
	retVal = elseRet
	if(boolVal):
		retVal = ifRet
	return retVal
#end def TernOp

def Run(cmdStr, getStdout = True, nice = 'x', bgTask = 0):
	"""	
		takes a shell command string and executes it
		if a nice value is passed it is niced (even on
		windows)
		Returns a pair of values corresponding to the standard output
		and standard error returns of the function
		also accepts a flag to set application as a background task
		(currently not implemented)
	"""
	if(nice != "x"):
		if(os.name == 'nt'):
			nice = "START "+QuadOp(nice, -10, 10, "\HIGH", "\NORMAL", "\LOW")
		else:
			nice = "nice -n"+str(nice)
		cmdStr = nice+" "+cmdStr
	if(getStdout):
		input, output, error = os.popen3(cmdStr)
		o = output.read()
		e = error.read()
		output.close()
		error.close()
		return o, e
	else:
		retCode = os.system(cmdStr)
		return retCode
#end def Run

























