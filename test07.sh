#!/bin/dash
# Test script for multiple commands - ranges
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
    # don't do anything on quit line if quit has piority
    seq 1 20 | ./speed.pl '3q;1,$p'
    seq 1 20 | ./speed.pl '3q;1,$s/./-/'
    seq 1 20 | ./speed.pl '3q;2,3d'

    # if quit don't have piority then don't do anything?
    seq 1 20 | ./speed.pl '1,$p;3q'
    seq 1 20 | ./speed.pl '1,$s/./-/;3q'
    seq 1 20 | ./speed.pl '2,3d;3q'
    seq 1 20 | ./speed.pl  -n '10p;$p'

) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    
    # don't do anything on quit line if quit has piority
    seq 1 20 | 2041 speed '3q;1,$p'
    seq 1 20 | 2041 speed '3q;1,$s/./-/'
    seq 1 20 | 2041 speed '3q;2,3d'

    # if quit don't have piority then don't do anything?
    seq 1 20 | 2041 speed '1,$p;3q'
    seq 1 20 | 2041 speed '1,$s/./-/;3q'
    seq 1 20 | 2041 speed '2,3d;3q'
    seq 1 20 | 2041 speed  -n '10p;$p'

    # just comment
    seq 1 20 | 2041 speed ' # asofms  '

    #autotest fails
    seq 1 100 | 2041 speed -n '1,/.1/p;/5/,/9/s/.//;/.{2}/,/.9/p;85q' #63
    seq 1 100 | ./speed.pl -n '1,/.1/p;/5/,/9/s/.//;/.{2}/,/.9/p;85q;'
    #seq 1 100 | ./speed.pl -n '1,/.1/p;/.{2}/,/.9/p;' #85q;' # each range variable varient need it's own variable
    #seq 1 100 | ./speed.pl '1,/.1/p;/5/,/9/s/.//;' #keep orinal lines when comparing and need own range variables
    #seq 1 100 | ./speed.pl '/5/,/9/s/.//;' #only modify things once
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test07 (multiple commands - ranges) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test07 (multiple commands - ranges)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
