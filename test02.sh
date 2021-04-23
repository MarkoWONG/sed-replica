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
    seq 1 100 | ./speed.pl -n '1,/.1/p;/5/,/9/s/.//;' #/.{2}/,/.9/p;85q;'
    #seq 1 100 | ./speed.pl '1,/.1/p;/5/,/9/s/.//;' #/.{2}/,/.9/p;85q;'
    #seq 1 100 | ./speed.pl '/5/,/9/s/.//;' #/.{2}/,/.9/p;85q;'
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    seq 1 100 | 2041 speed -n '1,/.1/p;/5/,/9/s/.//;' #/.{2}/,/.9/p;85;'
    #seq 1 100 | 2041 speed '1,/.1/p;/5/,/9/s/.//;' #/.{2}/,/.9/p;85;'
    #seq 1 100 | 2041 speed '/5/,/9/s/.//;' #/.{2}/,/.9/p;85;'
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test02 () -${GREEN}PASSED${NC}"
else
    RED='\033[0;31m';
    echo "Test02 ()  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
fi
