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
use Getopt::Long;
# USAGE ERROR: No arguments passed
if ($#ARGV == -1) {
    print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
    exit 1;
}

# there is a split command in perl. use for ; when mulitple command

# Save the agruments as the static scope replaces the @ARGV
@arguments = @ARGV;

# Determine the options used
$option_i = 0;
$option_n = 0;
$option_f = 0;
{
    # remove warning generated inside this static scope
    local $SIG{__WARN__} = sub { };
    if (GetOptions ('i' => \$option_i, 'n' => \$option_n, 'f' => \$option_f) == 0){
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}

# Set the speed_command
if ($option_i != 0 && $option_n != 0){
    $speed_command = $arguments[2];
}
elsif ($option_i != 0 || $option_n != 0){
    $speed_command = $arguments[1];
}
else{
    $speed_command = $arguments[0];
}
# Determine the delimitor for substitute function
# grab the all the charaters after a 's'. 
$delimitor = 'none';
for ($speed_command =~ m/s(.)/g){
    $p_delimitor = $_;
    # if character fits into the substitute format then delimitor is found
    if ($speed_command =~ m/s$p_delimitor(.*)$p_delimitor(.*)$p_delimitor(.*)/g){
        $delimitor = $p_delimitor;
        last;
    }
}

# Breakdown of speed command into command type and address type
if ($speed_command =~ m/^ *$/g){
    $command = "none";
    $address = -3;
}
# for regex to regex range
elsif ($speed_command =~ m/^\/(.*)\/,\/(.*)\/(.)$/g){
    $regex = $1;
    $rRegex2 = $2;
    $command = $3;
    $address = -2;
}
# for substitute command
elsif ($speed_command =~ m/(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
    $command = $1;
    $sub_regex = $2;
    $substitute = $3;
    $modifer = $4;
    #print "command = $command delimitor = $delimitor\n";
    if ($command eq 's') {
        $regex = "\$a";
        $address = -3; # -3 for not having a specified line to apply the sub command
    }
    # for regex to regex range
    elsif ($command =~ m/\/(.*)\/,\/(.*)\/(.)/g){
        $command = $3;
        $regex = $1;
        $rRegex2 = $2;
        $address = -2;
        #print "command = $command regex = $regex rRegex2 = $rRegex2 substitute = $substitute\n";
    }

    # for regex to line number range
    elsif ($command =~ m/\/(.*)\/,([0-9]*)(.)/g){
        $regex = $1;
        $rAddress2 = $2;
        $command = $3;
        $address = -2;
        #print "regex = $regex address = $address command = $command \n";
    }
    # for line number to regex range
    elsif ($command =~ m/([0-9]*),\/(.*)\/(.)/g){
        $address = $1;
        $rRegex2 = $2;
        $command = $3;
        #print "regex = $regex address = $address command = $command \n";
    }
    #for regex address
    elsif ($command =~ m/^\/(.*)\/(.)/g){
        $regex = $1;
        $command = $2;
        $address = -2; # -2 for using regex instead of address
        if ($command ne 's'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        # print "regex detected was $regex\n";
    }
    #for line_number address
    elsif ($command =~ m/^([0-9]*)(.)/g){
        $address = $1;
        $command = $2;
        if ($command ne 's'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        if ($address <= 0){
            print "speed: command line: invalid command\n";
            exit 1;
        }
    }
    else{
        print "speed: command line: invalid command\n";
        exit 1;
    }
    # print "command detected was $command\n";
    #print "sub_regex detected was $sub_regex\n";
    # print "sub detected was $substitute\n";
    #print "modifer detected was $modifer\n";

    if (defined $modifer && $modifer ne 'g' && $modifer ne ''){
        #print "modifer detected was $modifer\n";
        print "speed: command line: invalid command\n";
        exit 1;
    }
    if ($sub_regex eq ''){
        print "speed: command line: invalid command\n";
        exit 1;
    }
    #print "address dectected was $address\n";
}

# for regex matches
elsif ($speed_command =~ m/(.*)\/(.*)\/(.*)/g){
    $address = $1;
    $regex = $2;
    $command = $3;
    #$address = -2; # -2 for using regex instead of address
    #print "command = $command regex = $regex address = $address\n";
    #if ($address ne ''){
    # For line_number, regex (e.g '3,/2/d')
    if ($address =~ m/^([0-9]*),$/g){
        $address = $1;
        $rRegex2 = $regex;
        $regex = "\$a"; # this mathes an 'a' after end of line so it never matches
        #print "= $address\n";
    }
    # For regex, line numeber (e.g '/2/,4d')
    elsif ($command =~ m/,([0-9]*)(.)/g){
        $address = -2;
        $rAddress2 = $1;
        $command = $2;
    }
    #print "command = $command regex = $regex address = $address\n";

    #}
    else{
        $address = -2; # -2 for using regex instead of address
    }
    if ($command ne 'q' && $command ne 'd' && $command ne 'p' && $command ne 's') {
        print "speed: command line: invalid command\n";
        exit 1;
    }
}

# address is a line number
else { 
    $regex = "\$a"; # this mathes an 'a' after end of line so it never matches
    $speed_command =~ m/^([0-9\$,]*)(.)$/g;
    $first_cap = $1;
    $second_cap = $2;
    #print "first_cap = $first_cap second_cap = $second_cap\n";

    # no address was supplied
    if (defined $first_cap && $first_cap eq ''){
        $address = -3; # -3 for not having a specified line to apply the sub command
        $command = $second_cap;
        #print "command detected was $command\n";
    }

    # address was supplied
    elsif (defined $first_cap && $first_cap =~ m/[0-9\$,]/g){
        $address = $first_cap;
        $command = $second_cap;
        # check if address number is a postive number
        if ($address =~ m/^[0-9]*$/g){
            if ($address <= 0){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        elsif ($address =~ m/([0-9\$]*),([0-9\$]*)/g){
            $address = $1;
            $rAddress2 = $2;
            #print "1 = $address and 2 = $rAddress2\n";
        }
        # address can either be a number or '$' only
        elsif ($address ne '$'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        # assign -1 to address of '$'
        if ($address eq '$'){
            $address = -1;
        }
        # print "address detected was $address\n";
        # print "command detected was $command\n";
    }
    else {
        print "speed: command line: invalid command\n";
        exit 1;
    }
}

# Tracks with line number the program is on
$line_no = 0;

# for ',' range operation
$withinrange = 0;

# Main Driver Code: For each line passed into speed
while (<STDIN>) {
    $line = $_;
    $line_no++;
    # 0 = false, non-zero = true
    $quit = 0; 
    $delete = 0;
    $print = 0;
    $modified = 0;
    # change $address to current line number if address = '$' during the last loop
    if ($address =~ m/^-?[0-9]$/ && $address == -1 && eof) {
        $address = $line_no;
    }
    if ($command eq 'q'){
        if ($line =~ m/$regex/g || $address == -3 || $address == $line_no){
            $quit = 1;
        }
    }
    elsif ($command eq 'p'){
        if ($line =~ m/$regex/g || $address == -3 || $address == $line_no){
            $print = 1;           
            if (defined $rAddress2){
                $address = $rAddress2;
                $withinrange++;
            }
            elsif (defined $rRegex2){
                $rRegex1 = $regex;
                $regex = $rRegex2;
                $rRegex2 = $rRegex1;
                $withinrange++;
            }
        }
        elsif ($withinrange % 2 != 0){
            $print = 1; 
        }
        if ($print != 0){
            print "$line";
        }
    }
    elsif ($command eq 'd'){
        if ($line =~ m/$regex/g || $address == -3 || $address == $line_no){
            $delete = 1;
            if (defined $rAddress2){
                $address = $rAddress2;
                $withinrange++;
            }
            elsif (defined $rRegex2){
                $rRegex1 = $regex;
                $regex = $rRegex2;
                $rRegex2 = $rRegex1;
                $withinrange++;
            }
        }
        elsif ($withinrange % 2 != 0){
            $delete = 1;
        }
    }
    elsif ($command eq 's'){
        if (!defined $sub_regex){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        #print "line = $line with address = $address regex = $regex\n";
        if ($address == -3 || # no address provided so apply to every line
        ($line_no == $address) || # for using a regex match as address
        ($address == -2 && $line =~ m/$regex/g) # for using a line_number as address
        ){
            $modified = 1;
            if (defined $modifer && $modifer eq 'g'){
                $line =~ s/$sub_regex/$substitute/g;
            }
            else{
                $line =~ s/$sub_regex/$substitute/;
            }
            if (defined $rAddress2){
                $address = $rAddress2;
                #$regex = '\$a';
                $withinrange++;
            }
            elsif (defined $rRegex2){
                $rRegex1 = $regex;
                $regex = $rRegex2;
                $rRegex2 = $rRegex1;
                #$address = -2;
                $withinrange++;
            }
        }
        elsif ($withinrange % 2 != 0){
            $modified = 1;
            if (defined $modifer && $modifer eq 'g'){
                $line =~ s/$sub_regex/$substitute/g;
            }
            else{
                $line =~ s/$sub_regex/$substitute/;
            }
        }
    }
    # if ($delete == 0 && ($option_n == 0 && $modified != 0)){
    #     print "$line";
    # }
    # if ($delete == 0){
    #     if ($option_n == 0 && $modified != 0){
    #         print "$line";
    #     }
    # }
    if ($option_n == 0 && $delete == 0){
        print "$line";
    }
    # elsif ($option_n != 0){
    #     if ($modified != 0 && $delete == 0){
    #         print "$line";
    #     }
    # }
    if ($quit != 0){
        exit 0;
    }
}
