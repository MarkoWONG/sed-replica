#!/bin/dash
# Test script for input files - comments
# Line 5,8,14 are from lecture code
# Make a temp directory for testing
test_dir=$(mktemp -d /tmp/dir.XXXXXXXXXX)

# ensure temporary directory + all its contents removed on exit
trap 'rm -rf "$test_dir; exit"' INT TERM EXIT

# copy speed.pl file to test directory
cp "./speed.pl" ""$test_dir"/speed.pl";

# change working directory to the new temporary directory
cd "$test_dir" || exit 1

# Begin tests:
(
    # create a command input file with comments
    # header comments
    echo "#Yo this is a test command input file" > temp1.txt
    echo "# Written By Marko Wong" >> temp1.txt
    echo "# on the 25/04/2021" >> temp1.txt 
    echo "" >>temp1.txt
    #commands with comments
    echo "2p #print line 2" >> temp1.txt
    #echo "1,/5s/./-/g # print from line 1 til regex match 5" >> temp1.txt  #produce error with extra info
    echo "1,/5/s/./-/g # print from line 1 til regex match 5" >> temp1.txt 
    # just a comment
    echo "# now halfway through commands" >>temp1.txt
    echo "9p; 10q # print line 9 and quit on line 10" >>temp1.txt
    echo "" >>temp1.txt

    #create a input file with comments 
    # header comments
    echo "#Yo this is a test input file" > temp2.txt
    echo "# Written By Marko Wong" >> temp2.txt
    echo "# on the 25/04/2021" >> temp2.txt 
    echo "" >>temp2.txt
    #commands with comments
    echo "12 #12" >> temp2.txt
    echo "hello # hi" >> temp2.txt 
    # just a comment
    echo "# now halfway through commands" >>temp2.txt
    echo "9 # 9 " >>temp2.txt
    echo "19 # 19 " >>temp2.txt
    echo "" >>temp2.txt

    ./speed.pl -f temp1.txt temp2.txt
    echo $?



) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # create a command input file with comments
    # header comments
    echo "#Yo this is a test command input file" > temp1.txt
    echo "# Written By Marko Wong" >> temp1.txt
    echo "# on the 25/04/2021" >> temp1.txt 
    echo "" >>temp1.txt
    #commands with comments
    echo "2p #print line 2" >> temp1.txt
    echo "1,/5/s/./-/g # print from line 1 til regex match 5" >> temp1.txt 
    # just a comment
    echo "# now halfway through commands" >>temp1.txt
    echo "9p; 10q # print line 9 and quit on line 10" >>temp1.txt
    echo "" >>temp1.txt

    #create a input file with comments 
    # header comments
    echo "#Yo this is a test input file" > temp2.txt
    echo "# Written By Marko Wong" >> temp2.txt
    echo "# on the 25/04/2021" >> temp2.txt 
    echo "" >>temp2.txt
    #commands with comments
    echo "12 #12" >> temp2.txt
    echo "hello # hi" >> temp2.txt 
    # just a comment
    echo "# now halfway through commands" >>temp2.txt
    echo "9 # 9 " >>temp2.txt
    echo "19 # 19 " >>temp2.txt
    echo "" >>temp2.txt

    2041 speed -f temp1.txt temp2.txt
    echo $?
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test08 (input files - comments) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test08 (input files - comments)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
