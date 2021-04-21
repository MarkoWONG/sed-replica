#!/bin/dash
# Test script for 
# Line 5,8,20 are from lecture code
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

) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # $ as a line number in , commands
    seq 10 21 | 2041 speed '3,$d'
    seq 10 21 | 2041 speed '$,3d'

    # mulitple matches for 1st address
    seq 493 500 | 2041 speed '/4/,5p'
    seq 494 500 | ./speed.pl '/4/,5p'

    # muliple matches for the 2nd address
    seq 10 25 | ./speed.pl '3,/2/s/1/9/g'
    # ranges match the first apperence of 1st address then match until the first 
    # apperence of 2nd address. 

    # ranges can be applied more than once
    seq 10 31 | 2041 speed '/1$/,/^2/d'
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test03 () -${GREEN}PASSED${NC}"
else
    RED='\033[0;31m';
    echo "Test03 ()  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
fi
