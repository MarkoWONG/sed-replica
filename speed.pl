#!/usr/bin/perl -w 

# sudo code: (from tut)

# mulitple commands and order of execution

# p,q,d,s///

# for each line:
#     for each command:
#         address, type = command
#         if address matches or is empty:
#             if type == q:
#                 quit = true
#                 break
#             else if type == p:
#             else if type starts with s:
#                 sed the using the type
#             else if type == d:
#                 deleted = true
#                 break
#     continue if deleted
#     print line
#     break if quit

# USAGE ERROR: No arguments passed
if ($#ARGV == -1) {
    print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
    exit 1;
}

@valid_commands = ("a", "b", "c", "d", "i", "p", "q", "s", "t", "none");

if ($ARGV[0] =~ m/ */g){
    $command = "none";
}
# Generate a list of commands base on args
# if there is a / / then there is a regex match
$valid = 1;
if ($ARGV[0] =~ m/\/(.*)\/(.*)/g){
    $regex = $1;
    $command = $2;
    print "regex detected was $regex\n";
}
# else there is an adress
else { 
    $ARGV[0] =~ m/(.)(.*)/g;
    $first_cap = $1;
    $second_cap = $2;
    if ($first_cap =~ m/[a-zA-Z]/g){
        # -1 = no address found
        $address = -1;
        $command = $first_cap;
        print "command detected was $command\n";
    }
    elsif ($first_cap =~ m/[0-9]/g){
        $address = $first_cap;
        $command = $second_cap;
        print "address detected was $address\n";
        print "command detected was $command\n";
    }
    else {
        for (@valid_commands){
            if ($ARGV[0] eq $_){
                $valid = 0;   
                last; #break
            }
        }
        if ($valid != 0){
            print "speed: command line: invalid command\n";
            exit 1;
        }
    }
}

# Tracks with line number the program is on
$line_no = 0;

# 0 = true, non-zero = false
$quit = 1; 
# Main Driver Code: For each line passed into speed
while (<STDIN>) {
    $line = $_;
    $line_no++;

    if ($command eq 'q'){
        if ($address == -1 || $address == $line_no){
            $quit = 0;
        }
    }
    print "$line";
    if ($quit == 0){
        exit 0;
    }
}