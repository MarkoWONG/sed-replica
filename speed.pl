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


# Main Code
# USAGE ERROR: No arguments passed
if ($#ARGV == -1) {
    print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
    exit 1;
}

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

# split the command(s) into single commands
@commands = split("[,\n]", $speed_command);

# Tracks with line number the program is on
my $line_no = 0;

# For each line passed into speed
while (<STDIN>) {
    my$line = $_;
    $line_no++;

    # For each command
    foreach my $s_command (@commands) {
        #print "$s_command\n";
        
        my @info = command_breakdown($s_command);
        # info format (command_type, address type, line_no, regex, sub_regex, substitute, modifer)
        #print "command_type = $info[0], address type = $info[1], line_no = $info[2], regex = $info[3], sub_regex = $info[4], substitute = $info[5], modifer = $info[6]\n";
        my $command_type = $info[0];
        my $address_type = $info[1];
        my $a_line_no = $info[2];
        my $a_regex = $info[3];
        my $sub_regex = $info[4];
        my $substitute = $info[5];
        my $modifer = $info[6];
        
        #0 = false, non-zero = true
        $quit = 0;
        $delete = 0;
        $print = 0;

        # change $address to current line number if address = '$' during the last loop
        if ($a_line_no ne "none" && $a_line_no == -1 && eof) {
            $a_line_no = $line_no;
        }
        if ($command_type eq 'q'){
            if ($address_type eq "none"){
                $quit = 1;
            }
            elsif ($address_type eq "line_no") {
                if ($a_line_no == $line_no){
                    $quit = 1;
                }
            }
            elsif ($address_type eq "regex") {
                if ($line =~ m/$a_regex/g){
                    $quit = 1;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        elsif ($command_type eq 'p'){
            if ($address_type eq "none"){
                $print = 1;
            }
            elsif ($address_type eq "line_no"){
                if ($a_line_no == $line_no){
                    $print = 1;
                }
            }
            elsif ($address_type eq "regex"){
                if ($line =~ m/$a_regex/g) {
                    $print = 1;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
            if ($print != 0){
                print "$line";
            }
        }
        elsif ($command_type eq 'd'){
            if ($address_type eq "none"){
                $delete = 1;
            }
            elsif ($address_type eq "line_no"){
                if ($a_line_no == $line_no){
                    $delete = 1;
                }
            }
            elsif ($address_type eq "regex") {
                if ($line =~ m/$a_regex/g){
                    $delete = 1;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        elsif ($command_type eq 's'){
            if ($address_type eq "none"){
                if ($modifer eq 'g'){
                    $line =~ s/$sub_regex/$substitute/g;
                }
                else{
                    $line =~ s/$sub_regex/$substitute/;
                }
            }
            elsif ($address_type eq "line_no") {
                if ($a_line_no == $line_no){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
            }
            elsif ($address_type eq "regex") {
                if ($line =~ m/$a_regex/g){
                    if (defined $modifer && $modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        if ($option_n == 0 && $delete == 0){
            print "$line";
        }
        if ($quit != 0){
            exit 0;
        }
    }
    # for '' command
    if (scalar @commands == 0){
        print "$line";
    }
}

# breaks down a command into command, address's, regex's,
sub command_breakdown {

    # unpack the command passed in
    my ($command) = @_;
    #print "received command was: $command\n";

    # detect the delimitor used
    my $delimitor = get_delimitor($command);
    #print "delimitor is $delimitor\n";

    # Breakdown of speed command into command type and address type
    # For whitespace command
    if ($command =~ m/^ *$/g){
        @result = ("none", "none", "none", "none", "none", "none", "none");
        return @result;
    }

    # For substitute command type
    elsif ($command =~ m/(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
        my $command_type = $1;
        my $sub_regex = $2;
        my $substitute = $3;
        my $modifer = $4;
        #print "command = $command delimitor = $delimitor\n";
        if (defined $modifer && $modifer ne 'g' && $modifer ne ''){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($sub_regex eq ''){
            print "speed: command line: invalid command\n";
            exit 1;
        }

        # For no address
        if ($command_type eq 's') {
            # result format (command_type, address type, line_no, regex, sub_regex, substitute, modifer)
            @result = ($command_type, "none", "none", "none", $sub_regex, $substitute, $modifer);
            return @result;
        }

        # For regex address
        elsif ($command_type =~ m/^\/(.*)\/(.)$/g){
            my $regex = $1;
            $command_type = $2;
            if ($command_type eq 's'){
                @result = ($command_type, "regex", "none", $regex, $sub_regex, $substitute, $modifer);
                return @result;
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
            # print "regex detected was $regex\n";
        }
        # For line_number address
        elsif ($command_type =~ m/^([0-9]*)(.)$/g){
            my $line_no = $1;
            $command_type = $2;
            if ($line_no <= 0){
                print "speed: command line: invalid command\n";
                exit 1;
            }
            if ($command_type eq 's'){
                @result = ($command_type, "line_no", $line_no, "none", $sub_regex, $substitute, $modifer);
                return @result;
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        else {
            print "speed: command line: invalid command\n";
            exit 1;
        }
    }

    # no address was supplied
    elsif ($command =~ m/(^[qdp]$)/g){
        my $command_type = $1;
        @result = ($command_type, "none", "none", "none", "none", "none", "none");
        return @result;
    }
    # For Regex address
    elsif ($command =~ m/^\/(.*)\/(.)$/g){
        my $regex = $1;
        my $command_type = $2;
        # return results if the command_type is valid
        if ($command_type eq 'q' || $command_type eq 'd' || $command_type eq 'p') {
            @result = ($command_type, "regex", "none", $regex, "none", "none", "none");
            return @result;
        }
        else {
            print "speed: command line: invalid command\n";
            exit 1;
        }
    }

    # For line Number address
    elsif ($command =~ m/^([0-9\$]+)(.)$/g) {
        my $line_no = $1;
        my $command_type = $2;

        # check if line_no is a postive number
        if ($line_no =~ m/^[0-9]*$/g){
            if ($line_no <= 0){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # $line_no can either be a +number or '$' only
        elsif ($line_no ne '$'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        # assign -1 to address of '$'
        if ($line_no eq '$'){
            $line_no = -1;
        }

        # return results if the command_type is valid
        if ($command_type eq 'q' || $command_type eq 'd' || $command_type eq 'p') {
            @result = ($command_type, "line_no", $line_no, "none ", "none", "none", "none");
            return @result;
        }
        else {
            print "speed: command line: invalid command\n";
            exit 1;
        }
    }
    else {
        print "speed: command line: invalid command\n";
        exit 1;
    }
}

# Determine the delimitor for substitute function
sub get_delimitor {

    # unpack the command passed in
    ($command) = @_;
    #print "get_delimitor received command was: $command\n";

    # grab the all the charaters after a 's'.
    $delimitor = 'none';
    for ($command =~ m/s(.)/g){
        $p_delimitor = $_;
        # if character fits into the substitute format then delimitor is found
        if ($command =~ m/s\Q$p_delimitor\E(.*)\Q$p_delimitor\E(.*)\Q$p_delimitor\E(.*)/g){
            $delimitor = $p_delimitor;
            last;
        }
    }
    return $delimitor;
}