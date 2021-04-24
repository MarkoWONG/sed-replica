#!/bin/dash
# Test script for subset0 no address
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
    # whitespace commands just prints out all the lines
    seq 6 20 | ./speed.pl ''
    echo $?
    seq 6 20 | ./speed.pl '       '
    echo $?
    
    # Just a command no address (address after command gives error)
    # still prints the first line before quiting
    seq 1 5 | ./speed.pl 'q'
    echo $?
    # Can't test "seq 1 5 | ./speed.pl 'q2'" as this will not give an error 
    # because of GNU extension behaviour
    # address after command gives error
    seq 1 5 | ./speed.pl 'q2a'
    echo $?
    seq 1 5 | ./speed.pl 'q/1/'
    echo $?
    # print every line
    seq 7 11 | ./speed.pl 'p'
    echo $?
    seq 7 11 | ./speed.pl 'p1s'
    echo $?
    seq 7 11 | ./speed.pl 'p/2/'
    echo $?
    # does nothing
    seq 1 100 | ./speed.pl 'd'
    echo $?
    seq 1 100 | ./speed.pl 'd4s'
    echo $?
    seq 1 100 | ./speed.pl 'd/15/'
    echo $?
    # subtitute command cannot have a empty regex
    seq 1 5 | ./speed.pl 's'
    echo $?
    seq 1 5 | ./speed.pl 's//abc/g'
    echo $?
    seq 1 5 | ./speed.pl 's//a/'
    echo $?

    # regex address can't be empty
    seq 1 100 | ./speed.pl '//d'
    echo $?

) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # whitespace commands just prints out all the lines
    seq 6 20 | 2041 speed ''
    echo $?
    seq 6 20 | 2041 speed '       '
    echo $?
    
    # Just a command no address (address don't count after command)
    # still prints the first line before quiting
    seq 1 5 | 2041 speed 'q'
    echo $?
    # Can't test "seq 1 5 | ./speed.pl 'q2'" as this will not give an error 
    # because of GNU extension behaviour
    # address after command gives error
    seq 1 5 | 2041 speed 'q2a'
    echo $?
    seq 1 5 | 2041 speed 'q/1/'
    echo $?
    # print every line
    seq 7 11 | 2041 speed 'p'
    echo $?
    seq 7 11 | 2041 speed 'p1s'
    echo $?
    seq 7 11 | 2041 speed 'p/2/'
    echo $?
    # does nothing
    seq 1 100 | 2041 speed 'd'
    echo $?
    seq 1 100 | 2041 speed 'd4s'
    echo $?
    seq 1 100 | 2041 speed 'd/15/'
    echo $?
    # subtitute command cannot have a empty regex
    seq 1 5 | 2041 speed 's'
    echo $?
    seq 1 5 | 2041 speed 's//abc/g'
    echo $?
    seq 1 5 | 2041 speed 's//a/'
    echo $?
    # regex address can't be empty
    seq 1 100 | 2041 speed '//d'
    echo $?
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test00 (subset0: no address) -${GREEN}PASSED${NC}"
    exit 0;
else
    RED='\033[0;31m';
    echo "Test00 (subset0: no address)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1;
fi
