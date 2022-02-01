#!/bin/bash

# Assignment 3
# Course:                DPS918
# Family Name:           Kim
# Given Name:            Justin
# Student Number:        146-377-163
# Login name:            jkim452
# Professor:             Shahdad Shariatmadari
# Due Date:              August 7, 2020
#
# I declare that the attached assignment is my own work in accordance with
# Seneca Academic Policy.  No part of this assignment has been copied manually
# or electronically from any other source (including web sites) or distributed
# to other students.


#********************************************************************************************************************************************************
#terminal handling
#function that prints folder details
printFileInfo()
{
	#save the cursor position
	tput sc
	#move the cursor to position we are interested in
	tput cup ${twoDArrayY[9,$((position-1))]} ${twoDArrayX[9,$((position-1))]}
	
	#check if there your file is long
	outputLen=$( echo ${lastFileArray[$position-1]} | wc -m)
	maxLen=$(tput cols) 
	#case where file is only one line
	if(( $outputLen < $maxLen - 32 ))
	then
		tput cud 1
	#case where file is one a new line
	elif(( $outputLen >= $maxLen - 32 )) && (( $outputLen < $maxLen ))
	then
		tput cud 1
	else
	#case where it is multiple lines
		tput cud 2
	fi
	#print out the file information
	tput cub $(tput cols)
	ls -ld "${pathArray[$position-1]}" | awk '{print "   Links: " $2 "  Owner: " $3 "  Group: " $4 "  Size: " $5 "  Modified: " $6, $7, $8 }'

	#restore cursor position
	tput rc
}
#function that removes the information line
eraseFileInfo()
{
	#save the cursor position
	tput sc
	tput cup ${twoDArrayY[9,$((position-1))]} ${twoDArrayX[9,$((position-1))]}
	
	
	tput cuf $(tput cols)
	
	#check if the filename is long
	outputLen=$( echo ${lastFileArray[$position-1]} | wc -m)
	maxLen=$(tput cols) 
	
	if(( $outputLen < $maxLen - 32 ))
	then
		tput cud 1
		
	elif  (( $outputLen < $maxLen )) && (( $outputLen >= $maxLen - 32 ))
	then
		tput cud 1
	else
		tput cud 2
	fi
	
	#erase the old file information
	tput el1

	#restore the cursor
	tput rc
}
#function that handles the file permissions
addMode()
{
	#check if it is other permissions
	if(( hposition >= 6 )) && (( hposition <= 8 ))
	then
		permissions="o"
	#check if it is group permissions
	elif (( hposition >= 3 )) && (( hposition <= 5 ))
	then
		permissions="g"
	#check if it is user permissions
	elif (( hposition >= 0 )) && (( hposition <= 2 ))
	then
		permissions="u"
	fi
	#execute chmod command and send to errors to /dev/null
	chmod "$permissions+$key" "${pathArray[$position-1]}" 2> /dev/null
	#return return value of last run command
	return $?
	
}
removeMode()
{
	#check if it is other permissions
	if(( hposition >= 6 )) && (( hposition <= 8 ))
	then
		permissions="o"
	#check if it is group permissions
	elif (( hposition >= 3 )) && (( hposition <= 5 ))
	then
		permissions="g"
	#check if it is user permissions
	elif (( hposition >= 0 )) && (( hposition <= 2 ))
	then
		permissions="u"
	fi
	
	#check if you are reading
	if !(( hposition % 3 ))
	then
		readWriteExe="r"
	#check if you are check if you are writing
	elif (( hposition % 3 == 1))
	then
	#check if you are executing
		readWriteExe="w"
	elif (( hposition % 3 == 2))
	then
		readWriteExe="x"
	fi
	#change mode
	chmod "$permissions-$readWriteExe" "${pathArray[$position-1]}" 2> /dev/null
	return $?
}



#********************************************************************************************************************************************************
#main function

#declare an array
declare -a pathArray 
declare -a lastFileArray
declare -A twoDArrayX
declare -A twoDArrayY

currDir=$1
count=1
pvsCount=0
position=0

#error handling
if [ $# -gt 1 ]
then
	echo "Usage: vchmod [ filename ]."
	exit 1
fi

#set default directory value
if [ -z $currDir ]
then
	currDir="."
fi

#more error handling
if [[ ! -e "$currDir" ]]
then
	echo "'$currDir' does not exist or is inaccessible"
	exit 1
fi




#printing header
clear
echo "  Owner   Group   Other   Filename"
echo "  -----   -----   -----   --------"

#add extra "/" at the end of the path
dir1=$(realpath $currDir)"/"

#variable that stores the number of iterations needed to loop
iterations=$(echo "${dir1}" | awk -F"/" '{print NF-1}')

#create an array with the full path names
while (( count < $iterations ))
do
	#echo $dir1 | cut -d"/" -f$count
	pathArray[$count]=$(echo $dir1 | cut -d"/" -f$((count+1)))
	lastFileArray[$count]=${pathArray[$count]}
	pathArray[$count]=${pathArray[$pvsCount]}"/"${pathArray[$count]}
	pvsCount=$count
	count=$(( count+1 ))
done

#add the first array element
lastFileArray[0]='/'
pathArray[0]='/'

#loop through again to print out to terminal
count=0
extraLines=0
while (( count < $iterations ))
do
	echo ""
	temp=${lastFileArray[$count]}
	outputLen=$( echo ${lastFileArray[$count]} | wc -m)
	maxLen=$(tput cols) 
	
	twoDArrayX[0,$count]=2
	twoDArrayX[1,$count]=4
	twoDArrayX[2,$count]=6
	twoDArrayX[3,$count]=10
	twoDArrayX[4,$count]=12
	twoDArrayX[5,$count]=14
	twoDArrayX[6,$count]=18
	twoDArrayX[7,$count]=20
	twoDArrayX[8,$count]=22
	twoDArrayX[9,$count]=26
	for (( i=0; i <= 9; i++ )) 
	do
		twoDArrayY[$i,$count]=$((count*2 + 3 + extraLines))
	done

	#short filename case
	if(( $outputLen < $maxLen - 32 ))
	then
		string1=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,1,8); print $2}')
		string2=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,9,5); print $2}')
		string3=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,14,6); print $2}')
		printf "%s  %s  %s   %s\n" "$string1" "$string2" "$string3" "$temp"
	#medium filename case
	elif(( $outputLen >= $maxLen - 32 )) && (( $outputLen < $maxLen ))
	then
		string1=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,1,8); print $2}')
		string2=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,9,5); print $2}')
		string3=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,14,6); print $2}')
		printf "%s  %s  %s\n" "$string1" "$string2" "$string3"
		echo "$temp"
		extraLines=$((extraLines+1))
		twoDArrayX[9,$count]=0
		twoDArrayY[9,$count]=$((${twoDArrayY[9,$count]} + 1))
	#long filename case
	else
		string1=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,1,8); print $2}')
		string2=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,9,5); print $2}')
		string3=$(ls -ld "${pathArray[$count]}" | awk '{gsub(/./,"& ", $1);  $2=substr($1,14,6); print $2}')
		printf "%s  %s  %s\n" "$string1" "$string2" "$string3"
		echo "$temp"
		extraLines=$((extraLines+2))
		twoDArrayX[9,$count]=0
		twoDArrayY[9,$count]=$((${twoDArrayY[9,$count]} + 1))
	fi

	count=$(( count+1 ))
done


position=$(( iterations ))
position=$position
oldsettings=$(stty -g)
stty -echo -icanon min 1
tput cuu 1
printFileInfo
tput sc

#prints the command options on the bottom of the screen
while (( ((position+12)) < $(tput lines)- 1 - extraLines ))
do
	echo ""
	position=$(( position+1 ))
done

position=$(( iterations ))
echo "Valid keys: k (up), j (down): move between filenames"
echo "            h (left), l (right): move between permissions"
echo "            r, w, x, -: change permissions; q: quit"
tput rc


key=""

#loop that keeps reading input without hitting enter
fields=9
hposition=9

#place the cursor onto the first position
tput cup ${twoDArrayY[$hposition,$((position-1))]} ${twoDArrayX[$hposition,$((position-1))]}

while [ "$key" != "q" ]
do
	#trapping the ctrl+c
	trap "break" SIGINT 
	#capturing key
	key=$(dd bs=1 count=1 2> /dev/null)
	if [ "$key" = "k" ] && (( position > 1 ))
	then
		#erase old file information
		eraseFileInfo
		#move the cursor counter
		position=$(( position-1 ))
		#move to the new cursor position
		tput cup ${twoDArrayY[$hposition,$((position-1))]} ${twoDArrayX[$hposition,$((position-1))]}
		#print the file information for the new cursor position
		printFileInfo
	elif [ "$key" = "j" ] && (( position < $iterations ))
	then
		#erase old file information
		eraseFileInfo
		#move the cursor counter
		position=$(( position+1 ))
		#move to the new cursor position
		tput cup ${twoDArrayY[$hposition,$((position-1))]} ${twoDArrayX[$hposition,$((position-1))]}
		#print the file information for the new cursor position
		printFileInfo
	elif [ "$key" = "h" ] && (( hposition > 0 ))
	then
		#move the horizontal position counter
		hposition=$(( hposition - 1 ))
		#move the cursor
		tput cup ${twoDArrayY[$hposition,$((position-1))]} ${twoDArrayX[$hposition,$((position-1))]}
	elif [ "$key" = "l" ] && (( hposition < $fields ))
	then
		#move the horizontal position counter
		hposition=$(( hposition + 1 ))
		#move the cursor
		tput cup ${twoDArrayY[$hposition,$((position-1))]} ${twoDArrayX[$hposition,$((position-1))]}
	#enter this if statement if you press r, w, or x, while in a valid position
	elif  ( !(( hposition % 3 )) && [[ "$key" == "r" ]] ) ||  ( (( hposition % 3 == 1 )) && [[ "$key" == "w" ]]  ) || ( (( hposition % 3 == 2 )) && [[ "$key" == "x" ]] )
	then
		#call function that handles chmod
		addMode
		#check if chmod was successful
		if [ $? = 0 ]
		then
			#if successful, reprint
			tput sc 
			echo $key
			tput rc
		fi
	elif [ "$key" = "-" ]
	then
		#call function that handles removing chmod
		removeMode
		#check if chmod was successful
		if [ $? = 0 ]
		then
			#if successful, reprint
			tput sc
			echo -
			tput rc
		fi
		
	fi
done
#when finished return the cursor to the original settings
tput cud $(( $(tput lines)-position-4 ))
tput cub 32
#change to old settings that were saved
stty $oldsettings
