#!/usr/bin/perl -w

# Purpose: Implement a subset of the important Unix/Linux tool Sed.
# Written By Marko Wong (z5309371)
# Date: 18/04/2021

# sudo code: 
# for each line:
#     for each command:
#         address, type = command
#             if type == q:
#                 quit = true
#                 break
#             else if type == p:
#             else if type == s:
#             else if type == d:
#                 deleted = true
#                 break
#     continue if deleted
#     print line
#     break if quit

use Getopt::Long;
use File::Temp qw(tempfile);
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

# Set the speed_command or use command line or input file
if ($option_i != 0 && $option_n != 0 && $option_f != 0){
    $input_file_pos = 4;
    if (defined $arguments[3]) {
        open $f, '<', $arguments[3] or 
        print "speed: couldn't open file $arguments[3]: No such file or directory\n" and exit 1;
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_i != 0 && $option_f != 0){
    $input_file_pos = 3;
    if (defined $arguments[2]) {
        open $f, '<', $arguments[2] or 
        print "speed: couldn't open file $arguments[2]: No such file or directory\n" and exit 1;
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_n != 0 && $option_f != 0){
    $input_file_pos = 3;
    if (defined $arguments[2]) {
        open $f, '<', $arguments[2] or 
        print "speed: couldn't open file $arguments[2]: No such file or directory\n" and exit 1;
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_f != 0){
    $input_file_pos = 2;
    if (defined $arguments[1]) {
        open $f, '<', $arguments[1] or 
        print "speed: couldn't open file $arguments[1]: No such file or directory\n" and exit 1;
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_i != 0 && $option_n != 0){
    $input_file_pos = 3;
    $speed_command = $arguments[2];
}
elsif ($option_i != 0 || $option_n != 0){
    $input_file_pos = 2;
    $speed_command = $arguments[1];
}
else{
    $input_file_pos = 1;
    $speed_command = $arguments[0];
}

# Replace commands if -f option was used
if ($option_f != 0){
    # read the entire contents of file and input into the string speed_command
    my $speed_command = do { local $/; <$f> };
    # split the command(s) into single commands
    @commands = split("[;\n]", $speed_command);
}
else {
    # split the command(s) into single commands
    @commands = split("[;\n]", $speed_command);
}

# Replace STDIN input if input files was provided
if ($input_file_pos <= $#arguments){
    #creates a array of input files name from arguments
    @files = ();
    $current_file = $input_file_pos;
    while ($current_file <= $#arguments){
        push (@files, $arguments[$current_file]);
        $current_file++;
    }
    create_input_file(@files);
    open $inputs, '<', $input_temp_file or print "speed: error\n" and exit 1;
}
else{
    $inputs = "STDIN";
}

# Tracks with line number the program is on
my $line_no = 0;

# variables to control ranges (one for each command to avoid mix up during mulitple commands)
my $p_within_range_no_no = 0;
my $p_within_range_re_no = 0;
my $p_within_range_no_re = 0;
my $p_within_range_re_re = 0;

my $d_within_range_no_no = 0;
my $d_within_range_re_no = 0;
my $d_within_range_no_re = 0;
my $d_within_range_re_re = 0;

my $s_within_range_no_no = 0;
my $s_within_range_re_no = 0;
my $s_within_range_no_re = 0;
my $s_within_range_re_re = 0;
# end found is only used in regex to line number ranges as it is only activated
# once if end is already reached
my $end_found_p = 0;
my $end_found_d = 0;
my $end_found_s = 0;

# For each line passed into speed
while (<$inputs>) {
    my $line = $_;
    $line_no++;

    #0 = false, non-zero = true
    my $quit = 0;
    my $delete = 0;
    # For each command
    foreach my $s_command (@commands) {
        #print "$s_command\n";
        my $print = 0;
        my @info = command_breakdown($s_command);
        #print "command_type = $info[0], address type = $info[1]\n";
        my $command_type = $info[0];
        my $address_type = $info[1];
        
        # For no command
        if ($command_type eq "none"){
        }
        # For quit command
        elsif ($delete == 0 && $command_type eq 'q'){
            if ($address_type eq "none"){
                $quit = 1;
            }
            elsif ($address_type eq "line_no") {
                my $a_line_no = $info[2];
                # change $address to current line number if address = '$' during the last loop
                if ($a_line_no == -1 && eof) {
                    $a_line_no = $line_no;
                }
                if ($a_line_no == $line_no){
                    $quit = 1;
                }
            }
            elsif ($address_type eq "regex") {  
                my $a_regex = $info[2];
                if ($line =~ m/$a_regex/){
                    $quit = 1;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # For print command
        elsif ($quit == 0 && $delete == 0 && $command_type eq 'p'){
            if ($address_type eq "none"){
                $print = 1;
            }
            elsif ($address_type eq "line_no"){
                my $a_line_no = $info[2];
                # change $address to current line number if address = '$' during the last loop
                if ($a_line_no == -1 && eof) {
                    $a_line_no = $line_no;
                }
                if ($a_line_no == $line_no){
                    $print = 1;
                }
            }
            elsif ($address_type eq "regex"){
                my $a_regex = $info[2];
                if ($line =~ m/$a_regex/) {
                    $print = 1;
                }
            }
            elsif ($address_type eq "no_range_no") {
                my $start = $info[2];
                my $end = $info[3];
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command
                if ($p_within_range_no_no == 1){
                    $print =1;
                }
                # activate range
                if ($start == $line_no){
                    $print =1;
                    $p_within_range_no_no = 1;
                }
                # deactivate range
                if ($end == $line_no){
                    $print =1;
                    $p_within_range_no_no = 0;
                }
            }
            elsif ($address_type eq "no_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                # when within range activate command
                if ($p_within_range_no_re == 1){
                    $print =1;
                }
                # activate range
                if ($start == $line_no){
                    $print =1;
                    $p_within_range_no_re = 1;
                }
                # deactivate range
                elsif ($line =~ m/$end/){
                    if ($p_within_range_no_re == 1){
                        $print =1;
                    }
                    $p_within_range_no_re = 0;
                }
            }
            elsif ($address_type eq "re_range_no"){
                my $start = $info[2];
                my $end = $info[3];
                # change $address to current line number if address = '$' during the last loop
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command (only activate once if end is already reached)
                if ($p_within_range_re_no == 1){
                    $print =1;
                }
                # activate range
                if ($line =~ m/$start/){
                    $print = 1;
                    if ($end_found_p != 1){
                        $p_within_range_re_no = 1;
                    }
                }
                # deactivate range
                elsif ($end == $line_no){
                    $print = 1;
                    $end_found_p = 1;
                    $p_within_range_re_no = 0;
                }
            }
            elsif ($address_type eq "re_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                # when within range activate command
                if ($p_within_range_re_re == 1){
                    $print =1;
                }
                # activate range
                if ($line =~ m/$start/){
                    #print "started for $line\n";
                    $print =1;
                    $p_within_range_re_re = 1;
                }
                # deactivate range
                if ($line =~ m/$end/){
                    #print "ended for $line\n";
                    if ($p_within_range_re_re != 0){
                        $print =1;
                    }
                    $p_within_range_re_re = 0;
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
        # For delete command
        elsif ($quit == 0 && $command_type eq 'd'){
            if ($address_type eq "none"){
                $delete = 1;
            }
            elsif ($address_type eq "line_no"){
                my $a_line_no = $info[2];
                # change $address to current line number if address = '$' during the last loop
                if ($a_line_no == -1 && eof) {
                    $a_line_no = $line_no;
                }
                if ($a_line_no == $line_no){
                    $delete = 1;
                }
            }
            elsif ($address_type eq "regex") {
                my $a_regex = $info[2];
                if ($line =~ m/$a_regex/){
                    $delete = 1;
                }
            }
            elsif ($address_type eq "no_range_no") {
                my $start = $info[2];
                my $end = $info[3];
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command
                if ($d_within_range_no_no == 1){
                    $delete = 1;
                }
                # activate range
                if ($start == $line_no){
                    $delete = 1;
                    $d_within_range_no_no = 1;
                }
                # deactivate range
                if ($end == $line_no){
                    $delete = 1;
                    $d_within_range_no_no = 0;
                }
            }
            elsif ($address_type eq "no_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                # when within range activate command
                if ($d_within_range_no_re == 1){
                    $delete = 1;
                }
                # activate range
                if ($start == $line_no){
                    $delete = 1;
                    $d_within_range_no_re = 1;
                }
                # deactivate range
                elsif ($line =~ m/$end/){
                    if ($d_within_range_no_re == 1){
                        $delete = 1;
                    }
                    $d_within_range_no_re = 0;
                }
            }
            elsif ($address_type eq "re_range_no"){
                my $start = $info[2];
                my $end = $info[3];
                # change $address to current line number if address = '$' during the last loop
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command (only activate once if end is already reached)
                if ($d_within_range_re_no == 1){
                    $delete = 1;
                }
                # activate range
                if ($line =~ m/$start/){
                    $delete = 1;
                    if ($end_found_d != 1){
                        $d_within_range_re_no = 1;
                    }
                }
                # deactivate range
                elsif ($end == $line_no){
                    $delete = 1;
                    $end_found_d = 1;
                    $d_within_range_re_no = 0;
                }
            }
            elsif ($address_type eq "re_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                # when within range activate command
                if ($d_within_range_re_re == 1){
                    $delete = 1;
                }
                # activate range
                if ($line =~ m/$start/){
                    #print "started for $line\n";
                    $delete = 1;
                    $d_within_range_re_re = 1;
                }
                # deactivate range
                if ($line =~ m/$end/){
                    #print "ended for $line\n";
                    if ($d_within_range_re_re != 0){
                        $delete = 1;
                    }
                    $d_within_range_re_re = 0;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # For substitute command
        elsif ($quit == 0 && $delete == 0 && $command_type eq 's'){
            my $sub_regex = $info[3];
            my $substitute = $info[4];
            my $modifer = $info[5];
            if ($address_type eq "none"){
                if ($modifer eq 'g'){
                    $line =~ s/$sub_regex/$substitute/g;
                }
                else{
                    $line =~ s/$sub_regex/$substitute/;
                }
            }
            elsif ($address_type eq "line_no") {
                my $a_line_no = $info[2];
                # change $address to current line number if address = '$' during the last loop
                if ($a_line_no == -1 && eof) {
                    $a_line_no = $line_no;
                }
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
                my $a_regex = $info[2];
                if ($line =~ m/$a_regex/){
                    if (defined $modifer && $modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
            }
            elsif ($address_type eq "no_range_no") {
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                # only modify once
                my $modifed = 0;
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command
                if ($s_within_range_no_no == 1){
                    $modifed = 1;
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($start == $line_no && $modifed == 0 ){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $s_within_range_no_no = 1;
                }
                # deactivate range
                if ($end == $line_no){
                    $s_within_range_no_no = 0;
                }
            }
            elsif ($address_type eq "no_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                # keep the orginal line as the modifed lines will make if statements useless
                my $og_line = $line;
                # only modify once
                my $modifed = 0;
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                # when within range activate command
                if ($s_within_range_no_re == 1){
                    $modifed = 1;
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($start == $line_no && $modifed == 0){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $s_within_range_no_re = 1;
                }
                # deactivate range
                elsif ($og_line =~ m/$end/){
                    $s_within_range_no_re = 0;
                }
            }
            elsif ($address_type eq "re_range_no"){
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                # keep the orginal line as the modifed lines will make if statements useless
                my $og_line = $line;
                # only modify once
                my $modifed = 0;
                # change $address to current line number if address = '$' during the last loop
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command (only activate once if end is already reached)
                if ($s_within_range_re_no == 1){
                    $modifed = 1;
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($og_line =~ m/$start/){
                    if ($modifer eq 'g' && $modifed == 0){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    elsif ($modifed == 0){
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    if ($end_found_s != 1){
                        $s_within_range_re_no = 1;
                    }
                }
                # deactivate range
                elsif ($end == $line_no){
                    $end_found_s = 1;
                    $s_within_range_re_no = 0;
                }
            }
            elsif ($address_type eq "re_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                # keep the orginal line as the modifed lines will make if statements useless
                my $og_line = $line;
                # only modify once
                my $modifed = 0;
                # when within range activate command
                if ($s_within_range_re_re == 1){
                    #print "modified\n";
                    $modifed = 1;
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($og_line =~ m/$start/){
                    #print "started for $line\n";
                    if ($modifer eq 'g'&& $modifed == 0){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    elsif ($modifed == 0){
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $s_within_range_re_re = 1;
                }
                # deactivate range
                if ($og_line =~ m/$end/){
                    $s_within_range_re_re = 0;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }

    }
    if ($option_n == 0 && $delete == 0){
        print "$line";
    }
    if ($quit != 0){
        exit 0;
    }
}
if ($option_f != 0){
    close $f;
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
    if ($command =~ m/^\s*$/ || $command eq '' || $command =~ m/^\s*#.*$/){
        @result = ("none", "none");
        return @result;
    }
    # For line_no to line_no range
    elsif ($command =~ m/^\s*([0-9\$]+)\s*,\s*([0-9\$]+)\s*([qpds])\s*(.*)$/) {
        #print "line_no to line_no range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        #if $ is used for line number then there can only be one $
        if ($start =~ m/\$/){
            if ($start ne '$'){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        if ($end =~ m/\$/){
            if ($end ne '$'){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }

        # ranges can't be used on quit
        if ($command_type eq 'q'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        # assign -1 to address of '$'
        if ($start eq '$'){
            $start = -1;
        }
        # assign -1 to address of '$'
        if ($end eq '$'){
            $end = -1;
        }
        
        # for subsitute command
        #print "$command_type\n";

        if ($command_type eq 's'){
            if ($comment =~ m/\Q$delimitor\E(.+?)\Q$delimitor\E(.*?)\Q$delimitor\E(.*)?/){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/ && $modifer !~ m/^#.*$/ && $modifer !~ m/^g$/) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/){
                        $modifer = '';
                    }
                }
                @result = ($command_type, "no_range_no", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
            # invalid subtitute command 
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "no_range_no", $start, $end, );
            return @result;
        }
    }
    # For line_no to regex range
    elsif ($command =~ m/^\s*([0-9\$]+)\s*,\s*\/(.+?)\/\s*([qpds])\s*(.*)$/) {
        #print "line_no to regex range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        #if $ is used for line number then there can only be one $
        if ($start =~ m/\$/){
            if ($start ne '$'){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # ranges can't be used on quit
        if ($command_type eq 'q'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        # assign -1 to address of '$'
        if ($start eq '$'){
            $start = -1;
        }
        if ($command_type eq 's'){
            #print "= $comment\n";
            if ($comment =~ m/\Q$delimitor\E(.+?)\Q$delimitor\E(.*?)\Q$delimitor\E(.*)?/){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/ && $modifer !~ m/^#.*$/ && $modifer !~ m/^g$/) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/){
                        $modifer = '';
                    }
                }
                @result = ($command_type, "no_range_re", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
            # invalid subtitute command 
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # For other commands besides subtitute
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "no_range_re", $start, $end, );
            return @result;
        }
    }
    # For regex to line_no range
    elsif ($command =~ m/^\s*\/(.+?)\/\s*,\s*([0-9\$]+)\s*([qpds])\s*(.*)$/) {
        #print "regex to line_no range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        #if $ is used for line number then there can only be one $
        if ($end =~ m/\$/){
            if ($end ne '$'){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # ranges can't be used on quit
        if ($command_type eq 'q'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        # assign -1 to address of '$'
        if ($end eq '$'){
            $end = -1;
        }
        if ($command_type eq 's'){
            if ($comment =~ m/\Q$delimitor\E(.+?)\Q$delimitor\E(.*?)\Q$delimitor\E(.*)?/){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/ && $modifer !~ m/^#.*$/ && $modifer !~ m/^g$/) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/){
                        $modifer = '';
                    }
                }
                @result = ($command_type, "re_range_no", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
            # invalid subtitute command 
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "re_range_no", $start, $end, );
            return @result;
        }
    }
    # For regex to regex range
    elsif ($command =~ m/^\s*\/(.+?)\/\s*,\s*\/(.+?)\/\s*([qpds])\s*(.*)$/) {
        #print "regex to regex range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        # ranges can't be used on quit
        if ($command_type eq 'q'){
            print "speed: command line: invalid command\n";
            exit 1;
        }
        if ($command_type eq 's'){
            if ($comment =~ m/\Q$delimitor\E(.+?)\Q$delimitor\E(.*?)\Q$delimitor\E(.*)?/){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/ && $modifer !~ m/^#.*$/ && $modifer !~ m/^g$/) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/){
                        $modifer = '';
                    }
                }
                @result = ($command_type, "re_range_re", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
            # invalid subtitute command 
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "re_range_re", $start, $end, );
            return @result;
        }
    }
    # For substitute command type
    elsif ($command =~ m/(.*?)s\Q$delimitor\E(.+?)\Q$delimitor\E(.*?)\Q$delimitor\E(.*)?/){
        my $address = $1;
        my $command_type = 's';
        my $sub_regex = $2;
        my $substitute = $3;
        my $modifer = $4;
        # remove whitespaces from non regex variables
        $command_type = whitespace_remover($command_type);
        $modifer = whitespace_remover($modifer);
        # check for valid comment
        if (defined $modifer && $modifer ne '') {
            if ($modifer !~ m/^g#.*$/ && $modifer !~ m/^#.*$/ && $modifer !~ m/^g$/) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
            elsif ($modifer =~ m/^g$/){
                $modifer = 'g';
            }
            elsif ($modifer =~ m/^g#.*$/){
                $modifer = 'g';
            }
            elsif ($modifer =~ m/^#.*$/){
                $modifer = '';
            }
        }

        # For no address
        if ($address eq '') {
            # result format (command_type, address type, line_no, regex, sub_regex, substitute, modifer)
            @result = ($command_type, "none", "none", $sub_regex, $substitute, $modifer);
            return @result;
        }

        # For regex address
        elsif ($address =~ m/^\s*\/(.+)\/\s*$/){
            my $regex = $1;
            @result = ($command_type, "regex", $regex, $sub_regex, $substitute, $modifer);
            return @result;
          
        }
        # For line_number address
        elsif ($address =~ m/^\s*([0-9\$]*)\s*$/){
            my $line_no = $1;
            #if $ is used for line number then there can only be one $
            if ($line_no =~ m/\$/){
                if ($line_no ne '$'){
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            if ($line_no ne '$' && $line_no <= 0){
                print "speed: command line: invalid command\n";
                exit 1;
            }
            # assign -1 to address of '$'
            if ($line_no eq '$'){
                $line_no = -1;
            }
            @result = ($command_type, "line_no", $line_no, $sub_regex, $substitute, $modifer);
            return @result;
        }
        # For invalid command/format
        else {
            print "speed: command line: invalid command\n";
            exit 1;
        }
    }

    # no address was supplied
    elsif ($command =~ m/^\s*([qdp])(.*)$/){
        my $command_type = $1;
        my $comment = $2;
        # remove whitespaces from comment
        $comment = whitespace_remover($comment);
        # check for valid comment
        if (defined $comment && $comment ne '') {
            if ($comment !~ m/^#.*$/) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        @result = ($command_type, "none");
        return @result;
    }
    # For Regex address
    elsif ($command =~ m/^\s*\/(.+?)\/\s*([qdp])(.*)$/){
        my $regex = $1;
        my $command_type = $2;
        my $comment = $3;
        # remove whitespaces from comment
        $comment = whitespace_remover($comment);
        # check for valid comment
        if (defined $comment && $comment ne '') {
            if ($comment !~ m/^#.*$/) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # return results if the command_type is valid
        @result = ($command_type, "regex", $regex);
        return @result;
    }

    # For line Number address
    elsif ($command =~ m/^\s*([0-9\$]+)\s*([qdp])(.*)$/) {
        my $line_no = $1;
        my $command_type = $2;
        my $comment = $3;
        #if $ is used for line number then there can only be one $
        if ($line_no =~ m/\$/){
            if ($line_no ne '$'){
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # remove whitespaces from comment
        $comment = whitespace_remover($comment);
        # check for valid comment
        if (defined $comment && $comment ne '') {
            if ($comment !~ m/^#.*$/) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }

        # check if line_no is a postive number
        if ($line_no =~ m/^[0-9]*$/){
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

        @result = ($command_type, "line_no", $line_no);
        return @result;

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
    for ($command =~ m/s(.)/){
        $p_delimitor = $_;
        # if character fits into the substitute format then delimitor is found
        if ($command =~ m/s\Q$p_delimitor\E(.*)\Q$p_delimitor\E(.*)\Q$p_delimitor\E(.*)/){
            $delimitor = $p_delimitor;
            last;
        }
    }
    return $delimitor;
}

# Remove all whitespaces from string
sub whitespace_remover {
    ($str1) = @_;
    $str1 =~ tr/ //d;
    $str1 =~ tr/\n//d;
    $str1 =~ tr/\t//d;
    $str1 =~ tr/\f//d;
    $str1 =~ tr/\r//d;
    return $str1;
}

# Takes in a list of files names and append file content into temp file
sub create_input_file {
    ($fh, $input_temp_file) = tempfile( );
    open($file, ">", $input_temp_file) or print "speed: error\n" and exit 1;
    for (@_) {
        #select $file;
        open $fh, '<', $_ or print "speed: error\n" and exit 1;
        while (<$fh>){
            chomp $_;
            print $file "$_\n";
        }
        close $fh;
    }

    close $file;
}