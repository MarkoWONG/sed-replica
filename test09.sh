#!/bin/dash
# Test script for subset 0 and 1
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
    # create a valid command input file with comments
    # header comments
    echo "#Yo this is a test command input file" > temp1.txt
    echo "# Written By Marko Wong" >> temp1.txt
    echo "# on the 25/04/2021" >> temp1.txt 
    echo "" >>temp1.txt
    # every commands in subset 0 and 1 with comments
    echo "/1/,\$p; 5,/20/sX.XX; #print line 2" >> temp1.txt
    echo "/1/,/2/d; 29q;" >> temp1.txt 
    # just a comment
    echo "# done" >>temp1.txt
    echo "" >>temp1.txt

    #create a input file with comments 
    # header comments
    echo "#Yo this is a test input file" > temp2.txt
    echo "# Written By Marko Wong" >> temp2.txt
    echo "# on the 25/04/2021" >> temp2.txt 
    echo "" >>temp2.txt
    #commands with comments
    seq 1 30 >> temp2.txt
    echo "hello # hi" >> temp2.txt 
    # just a comment
    echo "# done" >>temp2.txt
    echo "" >>temp2.txt

    ./speed.pl -n -f temp1.txt temp2.txt
    echo $?
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # create a valid command input file with comments
    # header comments
    echo "#Yo this is a test command input file" > temp1.txt
    echo "# Written By Marko Wong" >> temp1.txt
    echo "# on the 25/04/2021" >> temp1.txt 
    echo "" >>temp1.txt
    # every commands in subset 0 and 1 with comments
    echo "/1/,\$p; 5,/20/sX.XX; #print line 2" >> temp1.txt
    echo "/1/,/2/d; 29q;" >> temp1.txt 
    # just a comment
    echo "# done" >>temp1.txt
    echo "" >>temp1.txt

    #create a input file with comments 
    # header comments
    echo "#Yo this is a test input file" > temp2.txt
    echo "# Written By Marko Wong" >> temp2.txt
    echo "# on the 25/04/2021" >> temp2.txt 
    echo "" >>temp2.txt
    #commands with comments
    seq 1 30 >> temp2.txt
    echo "hello # hi" >> temp2.txt 
    # just a comment
    echo "# done" >>temp2.txt
    echo "" >>temp2.txt

    2041 speed -n -f temp1.txt temp2.txt
    echo $?
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test09 (Integrated test) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test09 (Integrated test)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
