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
    # Overlaping ranges 
    seq 1 30 | ./speed.pl '1,15p; 5,20s/.//;'
    echo $?
    seq 1 30 | ./speed.pl '1,/15/p; 5,/20/s/.//;'
    echo $?
    seq 1 30 | ./speed.pl '/1/,15p; /5/,20s/.//;'
    echo $?
    seq 1 30 | ./speed.pl '/1/,/15/p; /5/,/20/s/.//;'
    echo $?

    # ranges of the same type (eg.regex to regex) and same command type
    # seq 1 30 | ./speed.pl '/1/,3p; /5/,5p;'
    # echo $?

    # Test order matters
    # once deleted don't activate other commands for that affected line
    seq 1 30 | ./speed.pl '/1/,/2/d; /1/,/2/p;'
    echo $?
    seq 1 30 | ./speed.pl '/2/,5d; /.2/,5s/../-/g'
    echo $?
    seq 1 30 | ./speed.pl '/2/,/3/p; /1/d; /1/p;'
    echo $?
    seq 1 30 | ./speed.pl '/1/,3p; /2/,/8/d; /.2/,/.5/s/../-/g'
    echo $?
    #still apply the commands on the affected line if it comes before the delete
    seq 1 30 | ./speed.pl '/1/,5p; /2/,/.5/d; /.2/,/.3/s/../-/g'
    echo $?
    # once quitted don't activate other commands
    seq 1 30 | ./speed.pl '/1/q; /1/,/2/p;'
    echo $?
    seq 1 30 | ./speed.pl '/2/q; /.2/,/.3/s/../-/g'
    echo $?
    seq 1 30 | ./speed.pl '/2/,/5/p; /1/q; /1/p;'
    echo $?
    seq 1 30 | ./speed.pl '/1/,/3/p; /2/q; /.2/s/../-/g'
    echo $?
    #still apply the commands on the affected line if it comes before the delete
    seq 1 30 | ./speed.pl '/1/,/2/p; /4/q; /.2/s/../-/g'
    echo $?

    # delete and quit has the same order of priority 
    seq 1 15 | ./speed.pl '/1/,/2/p; 3,5d; 2q;' #deleting the quit line will result in not quitting
    echo $?
    seq 1 15 | ./speed.pl '/1/,/3/p; 4q; 4d;' #qutting on the delete line will result in not deleteing
    echo $?

    # print and substitute don't restrict other commands (but still order matters)
    seq 1 15 | ./speed.pl '/1/,/2/p; /1/,/2/s/.*/hi/;'
    echo $?
    seq 1 15 | ./speed.pl '/1/,12s/.*/hi/;/1/,/.2/p;'
    echo $?
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # Overlaping ranges 
    seq 1 30 | 2041 speed '1,15p; 5,20s/.//;'
    echo $?
    seq 1 30 | 2041 speed '1,/15/p; 5,/20/s/.//;'
    echo $?
    seq 1 30 | 2041 speed '/1/,15p; /5/,20s/.//;'
    echo $?
    seq 1 30 | 2041 speed '/1/,/15/p; /5/,/20/s/.//;'
    echo $?

    # ranges of the same type (eg.regex to regex) and same command type
    # seq 1 30 | 2041 speed '/1/,3p; /5/,5p;'
    # echo $?

    # Test order matters
    # once deleted don't activate other commands for that affected line
    seq 1 30 | 2041 speed '/1/,/2/d; /1/,/2/p;'
    echo $?
    seq 1 30 | 2041 speed '/2/,5d; /.2/,5s/../-/g'
    echo $?
    seq 1 30 | 2041 speed '/2/,/3/p; /1/d; /1/p;'
    echo $?
    seq 1 30 | 2041 speed '/1/,3p; /2/,/8/d; /.2/,/.5/s/../-/g'
    echo $?
    #still apply the commands on the affected line if it comes before the delete
    seq 1 30 | 2041 speed '/1/,5p; /2/,/.5/d; /.2/,/.3/s/../-/g'
    echo $?
    # once quitted don't activate other commands
    seq 1 30 | 2041 speed '/1/q; /1/,/2/p;'
    echo $?
    seq 1 30 | 2041 speed '/2/q; /.2/,/.3/s/../-/g'
    echo $?
    seq 1 30 | 2041 speed '/2/,/5/p; /1/q; /1/p;'
    echo $?
    seq 1 30 | 2041 speed '/1/,/3/p; /2/q; /.2/s/../-/g'
    echo $?
    #still apply the commands on the affected line if it comes before the delete
    seq 1 30 | 2041 speed '/1/,/2/p; /4/q; /.2/s/../-/g'
    echo $?

    # delete and quit has the same order of priority 
    seq 1 15 | 2041 speed '/1/,/2/p; 3,5d; 2q;' #deleting the quit line will result in not quitting
    echo $?
    seq 1 15 | 2041 speed '/1/,/3/p; 4q; 4d;' #qutting on the delete line will result in not deleteing
    echo $?

    # print and substitute don't restrict other commands (but still order matters)
    seq 1 15 | 2041 speed '/1/,/2/p; /1/,/2/s/.*/hi/;'
    echo $?
    seq 1 15 | 2041 speed '/1/,12s/.*/hi/;/1/,/.2/p;'
    echo $?

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
