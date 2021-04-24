#!/bin/dash
# Test script for delimitor in subtitute
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
    # normal delimitor
    seq 1 10 | ./speed.pl 's/./2/'
    seq 1 10 | ./speed.pl 's/./2/g'

    # new delimitor
    # symbol as delimitor
    seq 1 10 | ./speed.pl 's@.@2@'
    echo $?
    seq 1 10 | ./speed.pl 's@.@2@g'
    echo $?
    # letter as delimitor
    echo $?
    seq 1 10 | ./speed.pl 'sa.a2a'
    echo $?
    seq 1 10 | ./speed.pl 'sa.a2ag'
    echo $?
    # number as delimitor
    echo $?
    seq 1 10 | ./speed.pl 's1.121'
    echo $?
    seq 1 10 | ./speed.pl 's1.121g'
    echo $?
    
    # '#' delimitor (testing for proper comment dectection)
    seq 1 10 | ./speed.pl 's#.#2#'
    echo $?
    seq 1 10 | ./speed.pl 's#.#2#g'
    echo $?
    seq 1 10 | ./speed.pl 's#.#2#   #work plz '
    echo $?
    seq 1 10 | ./speed.pl 's#.#2#g  #DH? '
    echo $?

    # '/' in regex instead as delimitor
    seq 1 10 | ./speed.pl 's!.!/!' 
    echo $?
    seq 1 10 | ./speed.pl 's!.!/!g' 
    echo $?
    echo 'dvalv/vaadev' | ./speed.pl 's_/_r_'
    echo $?
    echo 'dvalv/vaadev' | ./speed.pl 's_/_r_g'
    echo $?

) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # normal delimitor
    seq 1 10 | 2041 speed 's/./2/'
    seq 1 10 | 2041 speed 's/./2/g'

    # new delimitor
    # symbol as delimitor
    seq 1 10 | 2041 speed 's@.@2@'
    echo $?
    seq 1 10 | 2041 speed 's@.@2@g'
    echo $?
    # letter as delimitor
    echo $?
    seq 1 10 | 2041 speed 'sa.a2a'
    echo $?
    seq 1 10 | 2041 speed 'sa.a2ag'
    echo $?
    # number as delimitor
    echo $?
    seq 1 10 | 2041 speed 's1.121'
    echo $?
    seq 1 10 | 2041 speed 's1.121g'
    echo $?
    
    # '#' delimitor (testing for proper comment dectection)
    seq 1 10 | 2041 speed 's#.#2#'
    echo $?
    seq 1 10 | 2041 speed 's#.#2#g'
    echo $?
    seq 1 10 | 2041 speed 's#.#2#   #work plz '
    echo $?
    seq 1 10 | 2041 speed 's#.#2#g  #DH? '
    echo $?

    # '/' in regex instead as delimitor
    seq 1 10 | 2041 speed 's!.!/!' 
    echo $?
    seq 1 10 | 2041 speed 's!.!/!g' 
    echo $?
    echo 'dvalv/vaadev' | 2041 speed 's_/_r_'
    echo $?
    echo 'dvalv/vaadev' | 2041 speed 's_/_r_g'
    echo $?

) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test03 (Delimitor substitute) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test03 (Delimitor substitute)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
