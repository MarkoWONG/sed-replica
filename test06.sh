#!/bin/dash
# Test script for Comments & White Space
# Line 5,8,14 are from lecture code
# Make a temp directory for testing
test_dir=$(mktemp -d /tmp/dir.XXXXXXXXXX)

# ensure temporary directory + all its contents removed on exit
trap 'rm -rf "$test_dir; exit"' INT TERM EXIT

# copy speed.pl file to test directory
cp "speed.pl" ""$test_dir"/speed.pl";

# change working directory to the new temporary directory
cd "$test_dir" || exit 1

# Begin tests:
(
    # test for whitespace (simple)
    echo $?
    seq 1 10 | ./speed.pl '      '
    echo $?
    seq 1 10 | ./speed.pl '      3q'
    echo $?
    seq 1 10 | ./speed.pl '  3q    '
    echo $?
    seq 1 10 | ./speed.pl '      3d'
    echo $?
    seq 1 10 | ./speed.pl '  3d    '
    echo $?
    seq 1 10 | ./speed.pl '      3p'
    echo $?
    seq 1 10 | ./speed.pl '  3p    '
    echo $?
    seq 1 10 | ./speed.pl '      3s/./q/'
    echo $?
    seq 1 10 | ./speed.pl '  3s/./q/    '
    echo $?

    # test for whitespace (ranges)
    seq 1 10 | ./speed.pl '      1,3q   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,3q   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/   ,  3q   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,/3/q   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/  ,   /3/   q   '
    echo $?
    seq 1 10 | ./speed.pl '      1,3d   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,3d   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/   ,  3d   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,/3/d   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/  ,   /3/   d   '
    echo $?
    seq 1 10 | ./speed.pl '      1,3p   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,3p   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/   ,  3p   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,/3/p   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/  ,   /3/   p   '
    echo $?
    seq 1 10 | ./speed.pl '      1,3s/./w/   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,3s/./w/   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/   ,  3s/./w/   '
    echo $?
    seq 1 10 | ./speed.pl '      /1/,/3/s/./w/    '
    echo $?
    seq 1 10 | ./speed.pl '      /1/  ,   /3/   s/./w/    '
    echo $?

    # whitespaces in regex is unaffected
    echo "hello world" | ./speed.pl '/helloworld/s/e/-/g'
    echo $?
    echo "hello world" | ./speed.pl '/hello world/s/e/-/g'
    echo $?
    echo "hello world" | ./speed.pl '/hello    world/s/e/-/g'
    echo $?
    echo "hello world" | ./speed.pl '/helloworld/p'
    echo $?
    echo "hello world" | ./speed.pl '/hello world/p'
    echo $?
    echo "hello world" | ./speed.pl '/hello    world/p'
    echo $?
    echo "hello world" | ./speed.pl '/helloworld/d'
    echo $?
    echo "hello world" | ./speed.pl '/hello world/d'
    echo $?
    echo "hello world" | ./speed.pl '/hello    world/d'
    echo $?
    echo "hello world" | ./speed.pl '/helloworld/q'
    echo $?
    echo "hello world" | ./speed.pl '/hello world/q'
    echo $?
    echo "hello world" | ./speed.pl '/hello    world/q'
    echo $?

    # test for whitespace (mulitple commands)
    seq 1 10 | ./speed.pl ' /1/  p   ;  3 q    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p   ;  3 q    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/  p   ;  3 p    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p   ;  3 p    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/  p   ;  3 d    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p   ;  3 d    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/  p   ;  3 s/./-/    '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p   ;  3 s/./-/    '
    echo $?

    # test for comment (simple)
    seq 1 10 | ./speed.pl '3p #yo '
    echo $?
    seq 1 10 | ./speed.pl '3q #yo '
    echo $?
    seq 1 10 | ./speed.pl '3d #yo '
    echo $?
    seq 1 10 | ./speed.pl '3s/./@/ #yo '
    echo $?

    # test for comment (mulitple commands)
    seq 1 10 | ./speed.pl '3p #yo ; 
    5q #done '
    echo $?
    seq 1 10 | ./speed.pl '3p #yo 
     5q #done '
    echo $?
    
    #comment in the wrong place
    seq 1 10 | ./speed.pl '#yo 3p' #valid just no command
    echo $?
    seq 1 10 | ./speed.pl '3#yop'
    echo $?
    seq 1 10 | ./speed.pl '#yo 3d' #valid just no command
    echo $?
    seq 1 10 | ./speed.pl '3#yod'
    echo $?
    seq 1 10 | ./speed.pl '#yo 3q' #valid just no command
    echo $?
    seq 1 10 | ./speed.pl '3#yoq'
    echo $?
    seq 1 10 | ./speed.pl '#yo 3s/2/e/' #valid just no command
    echo $?
    seq 1 10 | ./speed.pl '3#yops/2/e/'
    echo $?
    seq 1 10 | ./speed.pl '2p ; 3#yop'
    echo $?
    seq 1 10 | ./speed.pl '3#yoq ; 2p'
    echo $?

    # commnets and whitespace test
    seq 1 10 | ./speed.pl ' /1/  p #apgdfin  ;  
    3 q  #adsg  '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p  #sadg ;  
    3 q   #asdg '
    echo $?
    seq 1 10 | ./speed.pl ' /1/  p  #sdg ;  
    3 p  #sdg  '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p  #sdg ;  
    3 p  #FAe  '
    echo $?
    seq 1 10 | ./speed.pl ' /1/  p  #adgf ;  
    3 d   #dagf '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p # ASDf  ;  
    3 d  #fsafg   '
    echo $?
    seq 1 10 | ./speed.pl ' /1/  p  #agd as gf ;  
    3 s/./-/   #dsag asf  '
    echo $?
    seq 1 10 | ./speed.pl ' /1/ , /2/  p # adsf ase  ;  
    3 s/./-/  #a sdfsad fg  '
    echo $?
    
    # test for proper comment detection
    seq 1 10 | ./speed.pl 's#.#2#; 
    2p #sgd'
    echo $?
    seq 1 10 | ./speed.pl 's#.#2#g'
    echo $?
    seq 1 10 | ./speed.pl 's#.#2#   #work plz; 
    3p #asf '
    echo $?
    seq 1 10 | ./speed.pl 's#.#2#g  #DH? '
    echo $?
) >>"output.txt" 2>>"output.txt"

mkdir "solution"
cd "solution"
(
    # test for whitespace (simple)
    echo $?
    seq 1 10 | 2041 speed '      '
    echo $?
    seq 1 10 | 2041 speed '      3q'
    echo $?
    seq 1 10 | 2041 speed '  3q    '
    echo $?
    seq 1 10 | 2041 speed '      3d'
    echo $?
    seq 1 10 | 2041 speed '  3d    '
    echo $?
    seq 1 10 | 2041 speed '      3p'
    echo $?
    seq 1 10 | 2041 speed '  3p    '
    echo $?
    seq 1 10 | 2041 speed '      3s/./q/'
    echo $?
    seq 1 10 | 2041 speed '  3s/./q/    '
    echo $?

    # test for whitespace (ranges)
    seq 1 10 | 2041 speed '      1,3q   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,3q   '
    echo $?
    seq 1 10 | 2041 speed '      /1/   ,  3q   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,/3/q   '
    echo $?
    seq 1 10 | 2041 speed '      /1/  ,   /3/   q   '
    echo $?
    seq 1 10 | 2041 speed '      1,3d   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,3d   '
    echo $?
    seq 1 10 | 2041 speed '      /1/   ,  3d   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,/3/d   '
    echo $?
    seq 1 10 | 2041 speed '      /1/  ,   /3/   d   '
    echo $?
    seq 1 10 | 2041 speed '      1,3p   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,3p   '
    echo $?
    seq 1 10 | 2041 speed '      /1/   ,  3p   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,/3/p   '
    echo $?
    seq 1 10 | 2041 speed '      /1/  ,   /3/   p   '
    echo $?
    seq 1 10 | 2041 speed '      1,3s/./w/   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,3s/./w/   '
    echo $?
    seq 1 10 | 2041 speed '      /1/   ,  3s/./w/   '
    echo $?
    seq 1 10 | 2041 speed '      /1/,/3/s/./w/    '
    echo $?
    seq 1 10 | 2041 speed '      /1/  ,   /3/   s/./w/    '
    echo $?

    # whitespaces in regex is unaffected
    echo "hello world" | 2041 speed '/helloworld/s/e/-/g'
    echo $?
    echo "hello world" | 2041 speed '/hello world/s/e/-/g'
    echo $?
    echo "hello world" | 2041 speed '/hello    world/s/e/-/g'
    echo $?
    echo "hello world" | 2041 speed '/helloworld/p'
    echo $?
    echo "hello world" | 2041 speed '/hello world/p'
    echo $?
    echo "hello world" | 2041 speed '/hello    world/p'
    echo $?
    echo "hello world" | 2041 speed '/helloworld/d'
    echo $?
    echo "hello world" | 2041 speed '/hello world/d'
    echo $?
    echo "hello world" | 2041 speed '/hello    world/d'
    echo $?
    echo "hello world" | 2041 speed '/helloworld/q'
    echo $?
    echo "hello world" | 2041 speed '/hello world/q'
    echo $?
    echo "hello world" | 2041 speed '/hello    world/q'
    echo $?

    # test for whitespace (mulitple commands)
    seq 1 10 | 2041 speed ' /1/  p   ;  
    3 q    '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p   ;  
    3 q    '
    echo $?
    seq 1 10 | 2041 speed ' /1/  p   ;  
    3 p    '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p   ;  
    3 p    '
    echo $?
    seq 1 10 | 2041 speed ' /1/  p   ;  
    3 d    '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p   ;  
    3 d    '
    echo $?
    seq 1 10 | 2041 speed ' /1/  p   ;  
    3 s/./-/    '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p   ;  
    3 s/./-/    '
    echo $?

    # test for comment (simple)
    seq 1 10 | 2041 speed '3p #yo '
    echo $?
    seq 1 10 | 2041 speed '3q #yo '
    echo $?
    seq 1 10 | 2041 speed '3d #yo '
    echo $?
    seq 1 10 | 2041 speed '3s/./@/ #yo '
    echo $?

    # test for comment (mulitple commands)
    seq 1 10 | 2041 speed '3p #yo ; 
    5q #done '
    echo $?
    seq 1 10 | 2041 speed '3p #yo 
     5q #done '
    echo $?
    
    #comment in the wrong place
    seq 1 10 | 2041 speed '#yo 3p' #valid just no command
    echo $?
    seq 1 10 | 2041 speed '3#yop'
    echo $?
    seq 1 10 | 2041 speed '#yo 3d' #valid just no command
    echo $?
    seq 1 10 | 2041 speed '3#yod'
    echo $?
    seq 1 10 | 2041 speed '#yo 3q' #valid just no command
    echo $?
    seq 1 10 | 2041 speed '3#yoq'
    echo $?
    seq 1 10 | 2041 speed '#yo 3s/2/e/' #valid just no command
    echo $?
    seq 1 10 | 2041 speed '3#yops/2/e/'
    echo $?
    seq 1 10 | 2041 speed '2p ; 
    3#yop'
    echo $?
    seq 1 10 | 2041 speed '3#yoq ; 
    2p'
    echo $?

    # commnets and whitespace test
    seq 1 10 | 2041 speed ' /1/  p #apgdfin  ; 
    3 q  #adsg  '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p  #sadg ;  
    3 q   #asdg '
    echo $?
    seq 1 10 | 2041 speed ' /1/  p  #sdg ;  
    3 p  #sdg  '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p  #sdg ;  
    3 p  #FAe  '
    echo $?
    seq 1 10 | 2041 speed ' /1/  p  #adgf ;  
    3 d   #dagf '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p # ASDf  ;  
    3 d  #fsafg   '
    echo $?
    seq 1 10 | 2041 speed ' /1/  p  #agd as gf ;  
    3 s/./-/   #dsag asf  '
    echo $?
    seq 1 10 | 2041 speed ' /1/ , /2/  p # adsf ase  ; 
     3 s/./-/  #a sdfsad fg  '
    echo $?
    
    # test for proper comment detection
    seq 1 10 | 2041 speed 's#.#2#; 
    2p #sgd'
    echo $?
    seq 1 10 | 2041 speed 's#.#2#g'
    echo $?
    seq 1 10 | 2041 speed 's#.#2#   #work plz; 
    3p #asf '
    echo $?
    seq 1 10 | 2041 speed 's#.#2#g  #DH? '
    echo $?

    # only newline ends a comment
    # seq 1 10 | 2041 speed 's/1/4/ #asdf
    # 2p #sgd ; 3q'
) >>"sol.txt" 2>>"sol.txt"
cd ..
NC='\033[0m' # No Color
diff -s "output.txt" "solution/sol.txt" >/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
    GREEN='\033[0;32m';
    echo "Test06 (Comments & White Space) -${GREEN}PASSED${NC}"
    exit 0
else
    RED='\033[0;31m';
    echo "Test06 (Comments & White Space)  -${RED}FAILED${NC}"
    echo "<<<<<< Your answer on the left <<<<<<<                          >>>>>> Solution on the right >>>>>>>>"
    diff -y "output.txt" "solution/sol.txt"
    exit 1
fi
