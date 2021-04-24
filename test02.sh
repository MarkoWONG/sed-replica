#!/bin/dash
# Test script for range function 
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
    # For substitute command the regex can't be nothing
    seq 1 10 | ./speed.pl 1,/5/s//s/
    echo $?
    seq 1 10 | ./speed.pl 1,/5/s//s/g
    echo $?

    # Line number have to be a positive number
    seq 1 10 | ./speed.pl /1/,0s/p
    echo $?
    seq 1 10 | ./speed.pl /1/,0s/d
    echo $?

    # ranges produce error when used on quit command
    seq 1 10 | ./speed.pl /1/,/5/q
    echo $?
    seq 1 10 | ./speed.pl 1,/5/q
    echo $?
    seq 1 10 | ./speed.pl /1/,5q
    echo $?
    seq 1 10 | ./speed.pl 1,5q
    echo $?

    # Detect the correct 's' for command (non greedy matching)
    seq 1 10 | ./speed.pl /s/,/s/s/./s/
    echo $?
    seq 1 10 | ./speed.pl /s/,/s/s/./s/g
    echo $?
    seq 1 10 | ./speed.pl 1,/s/s/./s/
    echo $?
    seq 1 10 | ./speed.pl 1,/s/s/./s/g
    echo $?
    seq 1 10 | ./speed.pl /s/,5s/./s/
    echo $?
    seq 1 10 | ./speed.pl /s/,5s/./s/g
    echo $?
    seq 1 10 | ./speed.pl 1,5s/./s/
    echo $?
    seq 1 10 | ./speed.pl 1,5s/./s/g
    echo $?

    # using '$' in ranges
    seq 1 10 | ./speed.pl $,/5/s/./a/
    echo $?
    seq 1 10 | ./speed.pl $,/5/s/./s/g
    echo $?
    seq 1 10 | ./speed.pl $,/5/p
    echo $?
    seq 1 10 | ./speed.pl $,/5/d
    echo $?
    seq 1 10 | ./speed.pl /1/,\$s/./s/
    echo $?
    seq 1 10 | ./speed.pl /1/,\$s/./s/g
    echo $?
    seq 1 10 | ./speed.pl /1/,\$p
    echo $?
    seq 1 10 | ./speed.pl /1/,\$d
    echo $?
    seq 1 10 | ./speed.pl $,\$s/./s/
    echo $?
    seq 1 10 | ./speed.pl $,\$s/./s/g
    echo $?
    seq 1 10 | ./speed.pl $,\$p
    echo $?
    seq 1 10 | ./speed.pl $,\$d
    echo $?

    # normal working cases
    # line to line
    seq 1 50 | ./speed.pl 1,5d
    echo $?
    seq 1 50 | ./speed.pl 1,5p
    echo $?
    seq 1 50 | ./speed.pl 1,5s/./-
    echo $?
    # line to regex
    seq 1 50 | ./speed.pl 1,/5/d
    echo $?
    seq 1 50 | ./speed.pl 1,/5/p
    echo $?
    seq 1 50 | ./speed.pl 1,/5/s/./- # end range regex doesn't activate command
    echo $?
    # regex to line
    seq 1 50 | ./speed.pl /1/,5d
    echo $?
    seq 1 50 | ./speed.pl /1/,5p
    echo $?
    seq 1 50 | ./speed.pl /1/,5s/./- # only activate command after range ends
    echo $?
    # regex to regex
    seq 1 50 | ./speed.pl /1/,/5/d
    echo $?
    seq 1 50 | ./speed.pl /1/,/5/p
    echo $?
    seq 1 50 | ./speed.pl /1/,/5/s/./- # range can restart
    echo $?
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # For substitute command the regex can't be nothing
    seq 1 10 | 2041 speed 1,/5/s//s/
    echo $?
    seq 1 10 | 2041 speed 1,/5/s//s/g
    echo $?

    # Line number have to be a positive number
    seq 1 10 | 2041 speed /1/,0s/p
    echo $?
    seq 1 10 | 2041 speed /1/,0s/d
    echo $?

    # ranges produce error when used on quit command
    seq 1 10 | 2041 speed /1/,/5/q
    echo $?
    seq 1 10 | 2041 speed 1,/5/q
    echo $?
    seq 1 10 | 2041 speed /1/,5q
    echo $?
    seq 1 10 | 2041 speed 1,5q
    echo $?

    # Detect the correct 's' for command (non greedy matching)
    seq 1 10 | 2041 speed /s/,/s/s/./s/
    echo $?
    seq 1 10 | 2041 speed /s/,/s/s/./s/g
    echo $?
    seq 1 10 | 2041 speed 1,/s/s/./s/
    echo $?
    seq 1 10 | 2041 speed 1,/s/s/./s/g
    echo $?
    seq 1 10 | 2041 speed /s/,5s/./s/
    echo $?
    seq 1 10 | 2041 speed /s/,5s/./s/g
    echo $?
    seq 1 10 | 2041 speed 1,5s/./s/
    echo $?
    seq 1 10 | 2041 speed 1,5s/./s/g
    echo $?

    # using '$' in ranges
    seq 1 10 | 2041 speed $,/5/s/./a/
    echo $?
    seq 1 10 | 2041 speed $,/5/s/./s/g
    echo $?
    seq 1 10 | 2041 speed $,/5/p
    echo $?
    seq 1 10 | 2041 speed $,/5/d
    echo $?
    seq 1 10 | 2041 speed /1/,\$s/./s/
    echo $?
    seq 1 10 | 2041 speed /1/,\$s/./s/g
    echo $?
    seq 1 10 | 2041 speed /1/,\$p
    echo $?
    seq 1 10 | 2041 speed /1/,\$d
    echo $?
    seq 1 10 | 2041 speed $,\$s/./s/
    echo $?
    seq 1 10 | 2041 speed $,\$s/./s/g
    echo $?
    seq 1 10 | 2041 speed $,\$p
    echo $?
    seq 1 10 | 2041 speed $,\$d
    echo $?

    # normal working cases
    # line to line
    seq 1 50 | 2041 speed 1,5d
    echo $?
    seq 1 50 | 2041 speed 1,5p
    echo $?
    seq 1 50 | 2041 speed 1,5s/./-
    echo $?
    # line to regex
    seq 1 50 | 2041 speed 1,/5/d
    echo $?
    seq 1 50 | 2041 speed 1,/5/p
    echo $?
    seq 1 50 | 2041 speed 1,/5/s/./- # end range regex doesn't activate command
    echo $?
    # regex to line
    seq 1 50 | 2041 speed /1/,5d
    echo $?
    seq 1 50 | 2041 speed /1/,5p
    echo $?
    seq 1 50 | 2041 speed /1/,5s/./- # only activate command after range ends
    echo $?
    # regex to regex
    seq 1 50 | 2041 speed /1/,/5/d
    echo $?
    seq 1 50 | 2041 speed /1/,/5/p
    echo $?
    seq 1 50 | 2041 speed /1/,/5/s/./- # range can restart
    echo $?
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test02 (Ranges) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test02 (Ranges)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1;
fi
