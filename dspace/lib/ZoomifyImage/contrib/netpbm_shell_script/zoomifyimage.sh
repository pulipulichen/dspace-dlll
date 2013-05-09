#!/bin/sh

input=$1

#Step 1.
#Scale the image until both the x and y dimensions are less than 257

#First convert the input file into a pnmfile

djpeg -pnm $input >0.pnm

Xinitial=`pnmfile 0.pnm | awk -F raw, '{print $2}' | awk '{print $1}'` ; 
Yinitial=`pnmfile 0.pnm | awk -F raw, '{print $2}' | awk '{print $3}'` ;

echo "Input File size = $Xinitial x $Yinitial"

inputfile=0
destfile=1
continue=1

while test $continue -eq 1; do
	pnmscalefixed .5 $inputfile.pnm >$destfile.pnm
	x=`pnmfile $destfile.pnm | awk -F raw, '{print $2}' | awk '{print $1}'` ; 
	y=`pnmfile $destfile.pnm | awk -F raw, '{print $2}' | awk '{print $3}'` ; echo $x"x"$y
	if test $x -le 256 ; then
		if test $y -le 256 ; then
			continue=0;
		fi
	fi
	inputfile=$destfile
	let destfile=$destfile+1
done


folder=`echo $input | awk -F ".jpg" '{print $1}'`

mkdir -p "$folder/TileGroup0"

# move the smallest file over

cjpeg $inputfile.pnm >$folder/TileGroup0/0-0-0.jpg

rm $inputfile.pnm

let inputfile=$inputfile-1
Z=1
Tiles=1
TileGroup=0
InGroup=1
while test $inputfile -ge 0 ; do
	echo "Doing $inputfile"
	x=`pnmfile $inputfile.pnm | awk -F raw, '{print $2}' | awk '{print $1}'` ;
	
	y=`pnmfile $inputfile.pnm | awk -F raw, '{print $2}' | awk '{print $3}'` ;
	
	let cols=$x/256
	let rows=$y/256
	let xleft=$x-$cols*256
	let yleft=$y-$rows*256
	
	echo $cols
	echo $rows
	echo $xleft
	echo $yleft
	
	
	#Rows
	
	Row=0
	while test $Row -lt $rows ; do
		#Strip out the row first to use it.

		posx=0
		let posy=$Row*256
		pnmcut $posx $posy $x 256 $inputfile.pnm > Therow.pnm
		Col=0
		while test $Col -lt $cols ; do
			let posx=$Col*256
			let posy=$Row*256
			#echo "$Row, $Col -> $posx, $posy, 256, 256"
			pnmcut $posx 0 256 256 Therow.pnm | cjpeg >$folder/TileGroup$TileGroup/$Z-$Col-$Row.jpg
			let Tiles=$Tiles+1
			echo -n "."
			let InGroup=$InGroup+1
			if test $InGroup -ge 256 ; then
				let TileGroup=$TileGroup+1
				InGroup=0
				mkdir $folder/TileGroup$TileGroup
			fi
			let Col=$Col+1
		done
		if test $xleft -gt 0 ; then
			let posx=$Col*256
			let posy=$Row*256
			#echo "$Row, $Col -> $posx, $posy, $xleft, 256"
			pnmcut $posx 0 $xleft 256 Therow.pnm | cjpeg >$folder/TileGroup$TileGroup/$Z-$Col-$Row.jpg
			echo -n "."
			let Tiles=$Tiles+1
			let InGroup=$InGroup+1
			if test $InGroup -ge 256 ; then
				let TileGroup=$TileGroup+1
				InGroup=0
				mkdir $folder/TileGroup$TileGroup
			fi
		fi
		let Row=$Row+1
		rm Therow.pnm
		echo
	done
	if test $yleft -gt 0 ; then
		Col=0
		posx=0
		let posy=$Row*256
		pnmcut $posx $posy $x $yleft $inputfile.pnm > Therow.pnm
		while test $Col -lt $cols ; do
			let posx=$Col*256
			let posy=$Row*256
			#echo "$Row, $Col -> $posx, $posy, 256, $yleft"
			pnmcut $posx 0 256 $yleft Therow.pnm | cjpeg >$folder/TileGroup$TileGroup/$Z-$Col-$Row.jpg
			echo -n "."
			let Tiles=$Tiles+1
			let InGroup=$InGroup+1
			if test $InGroup -ge 256 ; then
				let TileGroup=$TileGroup+1
				InGroup=0
				mkdir $folder/TileGroup$TileGroup
			fi
			let Col=$Col+1
		done
		if test $xleft -gt 0 ; then
			let posx=$Col*256
			let posy=$Row*256
			#echo "$Row, $Col -> $posx, $posy, $xleft, $yleft"
			pnmcut $posx 0 $xleft $yleft Therow.pnm | cjpeg >$folder/TileGroup$TileGroup/$Z-$Col-$Row.jpg
			echo -n "."
			let Tiles=$Tiles+1
			let InGroup=$InGroup+1
			if test $InGroup -ge 256 ; then
				let TileGroup=$TileGroup+1
				InGroup=0
				mkdir $folder/TileGroup$TileGroup
			fi
		fi
		rm Therow.pnm
	fi
	let Z=$Z+1
	rm $inputfile.pnm
	let inputfile=$inputfile-1
	echo
done

echo "Tiles created = $Tiles"

echo "<IMAGE_PROPERTIES WIDTH=\"$Xinitial\" HEIGHT=\"$Yinitial\" NUMTILES=\"$Tiles\" NUMIMAGES=\"1\" VERSION=\"1.8\" TILESIZE=\"256\" />" >$folder/ImageProperties.xml

echo "<HTML>" >$folder.html
echo "<BODY>" >>$folder.html
echo "<DIV ALIGN=\"center\">" >>$folder.html
echo "" >>$folder.html
echo "<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 BGCOLOR=#000000 WIDTH=\"750\" ALIGN=\"CENTER\">" >>$folder.html
echo "  <TR>" >>$folder.html
echo "	<TD>" >>$folder.html
echo "	  <TABLE BORDER=0 WIDTH=100% BGCOLOR=#ffffff CELLSPACING=0 CELLPADDING=0>" >>$folder.html
echo "		<TR>" >>$folder.html
echo "		  <TD>" >>$folder.html
echo "		  	  <OBJECT CLASSID=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" CODEBASE=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0\" WIDTH=\"750\" HEIGHT=\"450\" ID=\"theMovie\">" >>$folder.html
echo "                <PARAM NAME=\"FlashVars\" VALUE=\"zoomifyImagePath=$folder/\">" >>$folder.html
echo "                <PARAM NAME=\"MENU\" VALUE=\"FALSE\">" >>$folder.html
echo "				<PARAM NAME=\"SRC\" VALUE=\"zoomifyViewer.swf\">" >>$folder.html
echo "                <EMBED FlashVars=\"zoomifyImagePath=$folder/\" SRC=\"zoomifyViewer.swf\" MENU=\"false\" PLUGINSPAGE=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\"  WIDTH=\"750\" HEIGHT=\"450\" NAME=\"theMovie\"> </EMBED>" >>$folder.html
echo "              </OBJECT> </TD>" >>$folder.html
echo "		</TR>" >>$folder.html
echo "	  </TABLE>" >>$folder.html
echo "	</TD>" >>$folder.html
echo "  </TR>" >>$folder.html
echo "</TABLE>" >>$folder.html
echo "<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 BGCOLOR=#FFFFFF WIDTH=\"750\" ALIGN=\"CENTER\">" >>$folder.html
echo "  <TR>" >>$folder.html
echo "    <TD align=\"Right\">" >>$folder.html
echo "      <Font size=\"1\" face=\"arial\" color=\"#1A4658\">Powered by <a href=\"http://www.zoomify.com/\" target=\"_blank\">Zoomify</a></Font>" >>$folder.html
echo "    </TD>" >>$folder.html
echo "" >>$folder.html
echo "</TABLE>" >>$folder.html
echo "" >>$folder.html
echo "</DIV>" >>$folder.html
echo "</BODY>" >>$folder.html
echo "</HTML>" >>$folder.html
