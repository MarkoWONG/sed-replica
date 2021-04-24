#!/bin/dash
# Test script for subset0: with address
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
    # anything after the first command type is an error (except for subsititute)
    seq 1 5 | ./speed.pl '3qd'
    echo $?
    seq 1 5 | ./speed.pl '3pu'
    echo $?
    seq 1 5 | ./speed.pl '3dd'
    echo $?
    seq 1 5 | ./speed.pl '3s/2/4/d'
    echo $?
    seq 1 5 | ./speed.pl '3s/2/4/gd'
    echo $?
    seq 10 15 | ./speed.pl '/.1/q3f'
    echo $?
    seq 10 15 | ./speed.pl '/.1/p3f'
    echo $?
    seq 10 15 | ./speed.pl '/.1/d3f'
    echo $?
    seq 10 15 | ./speed.pl '/.1/s/3/1/gf'
    echo $?
    seq 10 15 | ./speed.pl '/.1/s/3/1/d'
    echo $?

    # characters in front of address is an error (except # for comment)
    seq 1 5 | ./speed.pl '$2p'
    echo $?
    seq 1 5 | ./speed.pl '%2q'
    echo $?
    seq 1 5 | ./speed.pl 'u2d'
    echo $?
    seq 1 5 | ./speed.pl 'u2s/dsgf/sdg/g'
    echo $?

    # test for multi digit in address and -n option
    seq 1 43 | ./speed.pl -n '23p'
    echo $?
    seq 1 1000 | ./speed.pl -n '390p'
    echo $?
    seq 1 20 | ./speed.pl -n '13q'
    echo $?
    seq 1 11 | ./speed.pl -n '10d'
    echo $?
    seq 1 15 | ./speed.pl -n '10s/.2/3/g'
    echo $?

    # address out of range and edge cases (line number has to be > 0)
    # for print
    seq 1 5 | ./speed.pl '1p'
    echo $?
    seq 1 5 | ./speed.pl '5p'
    echo $?
    seq 1 5 | ./speed.pl '0p'
    echo $?
    seq 1 5 | ./speed.pl '6p'
    echo $?
    # for quit
    seq 1 5 | ./speed.pl '1q'
    echo $?
    seq 1 5 | ./speed.pl '5q'
    echo $?
    seq 1 5 | ./speed.pl '0q'
    echo $?
    seq 1 5 | ./speed.pl '6q'
    echo $?
    # for delete
    seq 1 5 | ./speed.pl '1d'
    echo $?
    seq 1 5 | ./speed.pl '5d'
    echo $?
    seq 1 5 | ./speed.pl '0d'
    echo $?
    seq 1 5 | ./speed.pl '6d'
    echo $?
    # for substitute
    seq 1 5 | ./speed.pl '1s/2/4/'
    echo $?
    seq 1 5 | ./speed.pl '5s/2/4/'
    echo $?
    seq 1 5 | ./speed.pl '0s/2/4/'
    echo $?
    seq 1 5 | ./speed.pl '6s/2/4/'
    echo $?

    # wrong command type for substitute/regex format
    seq 1 5 | ./speed.pl '/1/f'
    echo $?
    seq 1 5 | ./speed.pl '/1/c'
    echo $?
    seq 1 5 | ./speed.pl '/1/u'
    echo $?
    seq 1 5 | ./speed.pl 'q/1/s/g'
    echo $?
    seq 1 5 | ./speed.pl 'p/1/s/g'
    echo $?
    seq 1 5 | ./speed.pl 'p/1/s/g'
    echo $?

    # Normal operation
    seq 1 5 | ./speed.pl '2q'
    echo $?
    seq 10 15 | ./speed.pl '/.1/q'
    echo $?
    seq 10 15 | ./speed.pl '/\.1/q'
    echo $?
    seq 10 15 | ./speed.pl '/#.1/q'
    echo $?
    seq 1 5 | ./speed.pl '2p'
    echo $?
    seq 10 15 | ./speed.pl '/.1/p'
    echo $?
    seq 10 15 | ./speed.pl '/\.1/p'
    echo $?
    seq 10 15 | ./speed.pl '/#.1/p'
    echo $?
    seq 1 5 | ./speed.pl '2d'
    echo $?
    seq 10 15 | ./speed.pl '/.1/d'
    echo $?
    seq 10 15 | ./speed.pl '/\.1/d'
    echo $?
    seq 10 15 | ./speed.pl '/#.1/d'
    echo $?
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # anything after the first command type is an error (except for subsititute)
    seq 1 5 | 2041 speed '3qd'
    echo $?
    seq 1 5 | 2041 speed '3pu'
    echo $?
    seq 1 5 | 2041 speed '3dd'
    echo $?
    seq 1 5 | 2041 speed '3s/2/4/d'
    echo $?
    seq 1 5 | 2041 speed '3s/2/4/gd'
    echo $?
    seq 10 15 | 2041 speed '/.1/q3f'
    echo $?
    seq 10 15 | 2041 speed '/.1/p3f'
    echo $?
    seq 10 15 | 2041 speed '/.1/d3f'
    echo $?
    seq 10 15 | 2041 speed '/.1/s/3/1/gf'
    echo $?
    seq 10 15 | 2041 speed '/.1/s/3/1/d'
    echo $?

    # characters in front of address is an error (except # for comment)
    seq 1 5 | 2041 speed '$2p'
    echo $?
    seq 1 5 | 2041 speed '%2q'
    echo $?
    seq 1 5 | 2041 speed 'u2d'
    echo $?
    seq 1 5 | 2041 speed 'u2s/dsgf/sdg/g'
    echo $?

    # test for multi digit in address and -n option
    seq 1 43 | 2041 speed -n '23p'
    echo $?
    seq 1 1000 | 2041 speed -n '390p'
    echo $?
    seq 1 20 | 2041 speed -n '13q'
    echo $?
    seq 1 11 | 2041 speed -n '10d'
    echo $?
    seq 1 15 | 2041 speed -n '10s/.2/3/g'
    echo $?

    # address out of range and edge cases
    # for print
    seq 1 5 | 2041 speed '1p'
    echo $?
    seq 1 5 | 2041 speed '5p'
    echo $?
    seq 1 5 | 2041 speed '0p'
    echo $?
    seq 1 5 | 2041 speed '6p'
    echo $?
    # for quit
    seq 1 5 | 2041 speed '1q'
    echo $?
    seq 1 5 | 2041 speed '5q'
    echo $?
    seq 1 5 | 2041 speed '0q'
    echo $?
    seq 1 5 | 2041 speed '6q'
    echo $?
    # for delete
    seq 1 5 | 2041 speed '1d'
    echo $?
    seq 1 5 | 2041 speed '5d'
    echo $?
    seq 1 5 | 2041 speed '0d'
    echo $?
    seq 1 5 | 2041 speed '6d'
    echo $?
    # for substitute
    seq 1 5 | 2041 speed '1s/2/4/'
    echo $?
    seq 1 5 | 2041 speed '5s/2/4/'
    echo $?
    seq 1 5 | 2041 speed '0s/2/4/'
    echo $?
    seq 1 5 | 2041 speed '6s/2/4/'
    echo $?

    # wrong command type for substitute/regex format
    seq 1 5 | 2041 speed '/1/f'
    echo $?
    seq 1 5 | 2041 speed '/1/c'
    echo $?
    seq 1 5 | 2041 speed '/1/u'
    echo $?
    seq 1 5 | 2041 speed 'q/1/s/g'
    echo $?
    seq 1 5 | 2041 speed 'p/1/s/g'
    echo $?
    seq 1 5 | 2041 speed 'p/1/s/g'
    echo $?

    # Normal operation
    seq 1 5 | 2041 speed '2q'
    echo $?
    seq 10 15 | 2041 speed '/.1/q'
    echo $?
    seq 10 15 | 2041 speed '/\.1/q'
    echo $?
    seq 10 15 | 2041 speed '/#.1/q'
    echo $?
    seq 1 5 | 2041 speed '2p'
    echo $?
    seq 10 15 | 2041 speed '/.1/p'
    echo $?
    seq 10 15 | 2041 speed '/\.1/p'
    echo $?
    seq 10 15 | 2041 speed '/#.1/p'
    echo $?
    seq 1 5 | 2041 speed '2d'
    echo $?
    seq 10 15 | 2041 speed '/.1/d'
    echo $?
    seq 10 15 | 2041 speed '/\.1/d'
    echo $?
    seq 10 15 | 2041 speed '/#.1/d'
    echo $?

) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test01 (subset0: with address) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test01 (subset0: with address)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
