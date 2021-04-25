#!/bin/dash
# Test script for multiple commands (not including ranges)
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
    # empty command
    seq 1 10 | ./speed.pl ';4q'
    echo $?

    # using either a ';' or a '\n' to seperate commands
    seq 1 10 | ./speed.pl '2p;3q'
    echo $?
    seq 1 10 | ./speed.pl '2p
    3q'
    echo $?

    # lots of commands
    seq 1 30 | ./speed.pl '1p; 2d; /3/s/3/q/g; /4/p; 23q;'
    echo $?

    # Overlapping commands
    seq 1 30 | ./speed.pl '/1/p;11d;/1./s/../-/g'
    echo $?

    # Test order matters
    # once deleted don't activate other commands for that affected line
    seq 1 30 | ./speed.pl '/1/d; /1/p;'
    echo $?
    seq 1 30 | ./speed.pl '/2/d; /.2/s/../-/g'
    echo $?
    seq 1 30 | ./speed.pl '/2/p; /1/d; /1/p;'
    echo $?
    seq 1 30 | ./speed.pl '/1/p; /5/p; /2/d; /.2/s/../-/g'
    echo $?
    #still apply the commands on the affected line if it comes before the delete
    seq 1 30 | ./speed.pl '/1/p; /2/p; /2/d; /.2/s/../-/g'
    echo $?

    # once quitted don't activate other commands
    seq 1 30 | ./speed.pl '/1/q; /1/p;'
    echo $?
    seq 1 30 | ./speed.pl '/2/q; /.2/s/../-/g'
    echo $?
    seq 1 30 | ./speed.pl '/2/p; /1/q; /1/p;'
    echo $?
    seq 1 30 | ./speed.pl '/1/p; /5/p; /2/q; /.2/s/../-/g'
    echo $?
    #still apply the commands on the affected line if it comes before the delete
    seq 1 30 | ./speed.pl '/1/p; /2/p; /2/q; /.2/s/../-/g'
    echo $?

    # delete and quit has the same order of priority 
    seq 1 15 | ./speed.pl '/1/p; 2d; 2q;' #deleting the quit line will result in not quitting
    echo $?
    seq 1 15 | ./speed.pl '/1/p; 2q; 2d;' #qutting on the delete line will result in not deleteing
    echo $?

    # print and substitute don't restrict other commands (but still order matters)
    seq 1 15 | ./speed.pl '/1/p; /1/s/.*/hi/;'
    echo $?
    seq 1 15 | ./speed.pl '/1/s/.*/hi/;/1/p;'
    echo $?
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(

) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test04 (Multiple commands - non range) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test04 (Multiple commands - non range)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
