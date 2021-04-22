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

# Set the speed_command or use command line or input file
if ($option_i != 0 && $option_n != 0 && $option_f != 0){
    if (defined $arguments[3]) {
        open $f, '<', $arguments[3] or 
        die "speed: couldn't open file commands.speed: No such file or directory\n";
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_i != 0 && $option_f != 0){
    if (defined $arguments[2]) {
        open $f, '<', $arguments[2] or 
        die "speed: couldn't open file commands.speed: No such file or directory\n";
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_n != 0 && $option_f != 0){
    if (defined $arguments[2]) {
        open $f, '<', $arguments[2] or 
        die "speed: couldn't open file commands.speed: No such file or directory\n";
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_f != 0){
    if (defined $arguments[1]) {
        open $f, '<', $arguments[1] or 
        die "speed: couldn't open file commands.speed: No such file or directory\n";
    }
    else {
        print "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
}
elsif ($option_i != 0 && $option_n != 0){
    $speed_command = $arguments[2];
}
elsif ($option_i != 0 || $option_n != 0){
    $speed_command = $arguments[1];
}
else{
    $speed_command = $arguments[0];
}

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
$inputs = "STDIN";

# Tracks with line number the program is on
my $line_no = 0;
my $within_range = 0;
# For each line passed into speed
while (<$inputs>) {
    my $line = $_;
    $line_no++;

    #0 = false, non-zero = true
    my $quit = 0;
    my $delete = 0;
    my $print = 0;
    # For each command
    foreach my $s_command (@commands) {
        #print "$s_command\n";
        
        my @info = command_breakdown($s_command);
        #print "command_type = $info[0], address type = $info[1]\n";
        my $command_type = $info[0];
        my $address_type = $info[1];
        
        # For no command
        if ($command_type eq "none"){
        }
        # For quit command
        elsif ($command_type eq 'q'){
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
                if ($line =~ m/$a_regex/g){
                    $quit = 1;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # For print command
        elsif ($command_type eq 'p'){
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
                if ($line =~ m/$a_regex/g) {
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
                if ($within_range == 1){
                    $print =1;
                }
                # activate range
                if ($start == $line_no){
                    $print =1;
                    $within_range = 1;
                }
                # deactivate range
                if ($end == $line_no){
                    $print =1;
                    $within_range = 0;
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
                if ($within_range == 1){
                    $print =1;
                }
                # activate range
                if ($start == $line_no){
                    $print =1;
                    $within_range = 1;
                }
                # deactivate range
                elsif ($line =~ m/$end/g){
                    if ($within_range == 1){
                        $print =1;
                    }
                    $within_range = 0;
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
                if ($within_range == 1){
                    $print =1;
                }
                # activate range
                if ($line =~ m/$start/g){
                    $print =1;
                    if ($within_range != 1){ #(only activate once if end is already reached)
                        $within_range++;
                    }
                }
                # deactivate range
                elsif ($end == $line_no){
                    $print =1;
                    $within_range = 0;
                }
            }
            elsif ($address_type eq "re_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                # when within range activate command
                if ($within_range == 1){
                    $print =1;
                }
                # activate range
                if ($line =~ m/$start/g){
                    #print "started for $line\n";
                    $print =1;
                    $within_range = 1;
                }
                # deactivate range
                if ($line =~ m/$end/g){
                    #print "ended for $line\n";
                    if ($within_range != 0){
                        $print =1;
                    }
                    $within_range = 0;
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
        elsif ($command_type eq 'd'){
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
                if ($line =~ m/$a_regex/g){
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
                if ($within_range == 1){
                    $delete = 1;
                }
                # activate range
                if ($start == $line_no){
                    $delete = 1;
                    $within_range = 1;
                }
                # deactivate range
                if ($end == $line_no){
                    $delete = 1;
                    $within_range = 0;
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
                if ($within_range == 1){
                    $delete = 1;
                }
                # activate range
                if ($start == $line_no){
                    $delete = 1;
                    $within_range = 1;
                }
                # deactivate range
                elsif ($line =~ m/$end/g){
                    if ($within_range == 1){
                        $delete = 1;
                    }
                    $within_range = 0;
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
                if ($within_range == 1){
                    $delete = 1;
                }
                # activate range
                if ($line =~ m/$start/g){
                    $delete = 1;
                    if ($within_range != 1){ #(only activate once if end is already reached)
                        $within_range++;
                    }
                }
                # deactivate range
                elsif ($end == $line_no){
                    $delete = 1;
                    $within_range = 0;
                }
            }
            elsif ($address_type eq "re_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                # when within range activate command
                if ($within_range == 1){
                    $delete = 1;
                }
                # activate range
                if ($line =~ m/$start/g){
                    #print "started for $line\n";
                    $delete = 1;
                    $within_range = 1;
                }
                # deactivate range
                if ($line =~ m/$end/g){
                    #print "ended for $line\n";
                    if ($within_range != 0){
                        $delete = 1;
                    }
                    $within_range = 0;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # For substitute command
        elsif ($command_type eq 's'){
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
                if ($line =~ m/$a_regex/g){
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
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command
                if ($within_range == 1){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($start == $line_no){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $within_range = 1;
                }
                # deactivate range
                if ($end == $line_no){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $within_range = 0;
                }
            }
            elsif ($address_type eq "no_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                # change $address to current line number if address = '$' during the last loop
                if ($start == -1 && eof) {
                    $start = $line_no;
                }
                # when within range activate command
                if ($within_range == 1){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($start == $line_no){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $within_range = 1;
                }
                # deactivate range
                elsif ($line =~ m/$end/g){
                    if ($within_range == 1){
                        if ($modifer eq 'g'){
                            $line =~ s/$sub_regex/$substitute/g;
                        }
                        else{
                            $line =~ s/$sub_regex/$substitute/;
                        }
                    }
                    $within_range = 0;
                }
            }
            elsif ($address_type eq "re_range_no"){
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                # change $address to current line number if address = '$' during the last loop
                if ($end == -1 && eof) {
                    $end = $line_no;
                }
                # when within range activate command (only activate once if end is already reached)
                if ($within_range == 1){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($line =~ m/$start/g){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    if ($within_range != 1){ #(only activate once if end is already reached)
                        $within_range++;
                    }
                }
                # deactivate range
                elsif ($end == $line_no){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $within_range = 0;
                }
            }
            elsif ($address_type eq "re_range_re"){
                my $start = $info[2];
                my $end = $info[3];
                my $sub_regex = $info[4];
                my $substitute = $info[5];
                my $modifer = $info[6];
                #print "start = $start end=$end\n";
                # when within range activate command
                if ($within_range == 1){
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                }
                # activate range
                if ($line =~ m/$start/g){
                    #print "started for $line\n";
                    if ($modifer eq 'g'){
                        $line =~ s/$sub_regex/$substitute/g;
                    }
                    else{
                        $line =~ s/$sub_regex/$substitute/;
                    }
                    $within_range = 1;
                }
                # deactivate range
                if ($line =~ m/$end/g){
                    #print "ended for $line\n";
                    if ($within_range != 0){
                        if ($modifer eq 'g'){
                            $line =~ s/$sub_regex/$substitute/g;
                        }
                        else{
                            $line =~ s/$sub_regex/$substitute/;
                        }
                    }
                    $within_range = 0;
                }
            }
            else {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        else{
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
    if ($command =~ m/^\s*$/g || $command eq ''){
        @result = ("none", "none");
        return @result;
    }
    # For line_no to line_no range
    elsif ($command =~ m/^\s*([0-9\$]+)\s*,\s*([0-9\$]+)\s*([pds])\s*(.*)$/g) {
        #print "line_no to line_no range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
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
            if ($comment =~ m/\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/g && $modifer !~ m/^#.*$/g && $modifer !~ m/^g$/g) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/g){
                        $modifer = '';
                    }
                }
                #check for valid sub_regex
                if ($sub_regex eq ''){
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
                @result = ($command_type, "no_range_no", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/g) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "no_range_no", $start, $end, );
            return @result;
        }
    }
    # For line_no to regex range
    elsif ($command =~ m/^\s*([0-9\$]+)\s*,\s*\/(.+)\/\s*([pds])\s*(.*)$/g) {
        #print "line_no to regex range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        # assign -1 to address of '$'
        if ($start eq '$'){
            $start = -1;
        }
        if ($command_type eq 's'){
            if ($comment =~ m/\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/g && $modifer !~ m/^#.*$/g && $modifer !~ m/^g$/g) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/g){
                        $modifer = '';
                    }
                }
                #check for valid sub_regex
                if ($sub_regex eq ''){
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
                @result = ($command_type, "no_range_re", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/g) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "no_range_re", $start, $end, );
            return @result;
        }
    }
    # For regex to line_no range
    elsif ($command =~ m/^\s*\/(.+)\/\s*,\s*([0-9\$]+)\s*([pds])\s*(.*)$/g) {
        #print "regex to line_no range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        # assign -1 to address of '$'
        if ($end eq '$'){
            $end = -1;
        }
        if ($command_type eq 's'){
            if ($comment =~ m/\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/g && $modifer !~ m/^#.*$/g && $modifer !~ m/^g$/g) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/g){
                        $modifer = '';
                    }
                }
                #check for valid sub_regex
                if ($sub_regex eq ''){
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
                @result = ($command_type, "re_range_no", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/g) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "re_range_no", $start, $end, );
            return @result;
        }
    }
    # For regex to regex range
    elsif ($command =~ m/^\s*\/(.+)\/\s*,\s*\/(.+)\/\s*([pds])\s*(.*)$/g) {
        #print "regex to regex range\n";
        $start = $1;
        $end = $2;
        $command_type = $3;
        $comment = $4;
        if ($command_type eq 's'){
            if ($comment =~ m/\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
                my $sub_regex = $1;
                my $substitute = $2;
                my $modifer = $3;
                # remove whitespaces from non regex variables
                $command_type = whitespace_remover($command_type);
                $modifer = whitespace_remover($modifer);
                # check for valid comment
                if (defined $modifer && $modifer ne '') {
                    if ($modifer !~ m/^g#.*$/g && $modifer !~ m/^#.*$/g && $modifer !~ m/^g$/g) {
                        print "speed: command line: invalid command\n";
                        exit 1;
                    }
                    elsif ($modifer =~ m/^g$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^g#.*$/g){
                        $modifer = 'g';
                    }
                    elsif ($modifer =~ m/^#.*$/g){
                        $modifer = '';
                    }
                }
                #check for valid sub_regex
                if ($sub_regex eq ''){
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
                @result = ($command_type, "re_range_re", $start, $end, $sub_regex, $substitute, $modifer);
                return @result;
            }
        }
        else {
            # remove whitespaces from comment
            $comment = whitespace_remover($comment);
            # check for valid comment
            if (defined $comment && $comment ne '') {
                if ($comment !~ m/^#.*$/g) {
                    print "speed: command line: invalid command\n";
                    exit 1;
                }
            }
            @result = ($command_type, "re_range_re", $start, $end, );
            return @result;
        }
    }
    # For substitute command type
    elsif ($command =~ m/(.*)s\Q$delimitor\E(.*)\Q$delimitor\E(.*)\Q$delimitor\E(.*)?/g){
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
            if ($modifer !~ m/^g#.*$/g && $modifer !~ m/^#.*$/g && $modifer !~ m/^g$/g) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
            elsif ($modifer =~ m/^g$/g){
                $modifer = 'g';
            }
            elsif ($modifer =~ m/^g#.*$/g){
                $modifer = 'g';
            }
            elsif ($modifer =~ m/^#.*$/g){
                $modifer = '';
            }
        }

        #check for valid sub_regex
        if ($sub_regex eq ''){
            print "speed: command line: invalid command\n";
            exit 1;
        }

        # For no address
        if ($address eq '') {
            # result format (command_type, address type, line_no, regex, sub_regex, substitute, modifer)
            @result = ($command_type, "none", "none", $sub_regex, $substitute, $modifer);
            return @result;
        }

        # For regex address
        elsif ($address =~ m/^\s*\/(.+)\/\s*$/g){
            my $regex = $1;
            @result = ($command_type, "regex", $regex, $sub_regex, $substitute, $modifer);
            return @result;
          
        }
        # For line_number address
        elsif ($address =~ m/^\s*([0-9\$]*)\s*$/g){
            my $line_no = $1;
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
    elsif ($command =~ m/^\s*([qdp])(.*)$/g){
        my $command_type = $1;
        my $comment = $2;
        # remove whitespaces from comment
        $comment = whitespace_remover($comment);
        # check for valid comment
        if (defined $comment && $comment ne '') {
            if ($comment !~ m/^#.*$/g) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        @result = ($command_type, "none");
        return @result;
    }
    # For Regex address
    elsif ($command =~ m/^\s*\/(.+)\/\s*([qdp])(.*)$/g){
        my $regex = $1;
        my $command_type = $2;
        my $comment = $3;
        # remove whitespaces from comment
        $comment = whitespace_remover($comment);
        # check for valid comment
        if (defined $comment && $comment ne '') {
            if ($comment !~ m/^#.*$/g) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }
        # return results if the command_type is valid
        @result = ($command_type, "regex", $regex);
        return @result;
    }

    # For line Number address
    elsif ($command =~ m/^\s*([0-9\$]+)\s*([qdp])(.*)$/g) {
        my $line_no = $1;
        my $command_type = $2;
        my $comment = $3;
        # remove whitespaces from comment
        $comment = whitespace_remover($comment);
        # check for valid comment
        if (defined $comment && $comment ne '') {
            if ($comment !~ m/^#.*$/g) {
                print "speed: command line: invalid command\n";
                exit 1;
            }
        }

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