#!/bin/dash
# Test script for -f option and input files
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
    # -f commands can be supplied by semicolons ; or newlines
    echo "s/1/-/g; 4q;" > temp.txt
    echo 1p >> temp.txt
    seq 1 15 | ./speed.pl -f temp.txt
    echo $?

    # invalid file
    seq 1 15 | ./speed.pl -f temp2.txt
    echo $?

    # input file's input can also be separated by semicolons ; or newlines
    echo "123;213" > temp1.txt
    echo 32 >> temp1.txt
    ./speed.pl s/1/-/g temp1.txt
    echo $?

    # invalid file
    ./speed.pl s/1/-/g temp2.txt
    echo $?

    # correct input file detection when other options are used
    ./speed.pl -n s/1/-/g temp1.txt
    echo $?
    ./speed.pl -n -f temp.txt temp1.txt
    echo $?

    # muitple input files 
    seq 1 10 > ten.txt
    seq 1 15 > fifteen.txt
    ./speed.pl s/1/-/g ten.txt fifteen.txt temp1.txt
    echo $?

) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # -f commands can be supplied by semicolons ; or newlines
    echo "s/1/-/g; 4q;" > temp.txt
    echo 1p >> temp.txt
    seq 1 15 | 2041 speed -f temp.txt
    echo $?

    # invalid file
    seq 1 15 | 2041 speed -f temp2.txt
    echo $?

    # input file's input can also be separated by semicolons ; or newlines
    echo "123;213" > temp1.txt
    echo 32 >> temp1.txt
    2041 speed s/1/-/g temp1.txt
    echo $?

    # invalid file
    2041 speed s/1/-/g temp2.txt
    echo $?

    # correct input file detection when other options are used
    2041 speed -n s/1/-/g temp1.txt
    echo $?
    2041 speed -n -f temp.txt temp1.txt
    echo $?

    # muitple input files 
    seq 1 10 > ten.txt
    seq 1 15 > fifteen.txt
    2041 speed s/1/-/g ten.txt fifteen.txt temp1.txt
    echo $?
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test05 (Input files) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test05 (Input files)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
