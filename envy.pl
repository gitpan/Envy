#!/nw/dist/prod/bin/perl -w
use strict;
use vars qw($running_under_some_shell);
use Envy::DB qw(@DefaultPath);

# If you want to reuse any of the code in this file, let me
# know and I'll move it to Envy::UI or somesuch.  Thanks!

my $warnlevel = $ENV{ENVY_VERBOSE} || 1;
my $is_unload=0;
my $is_csh=0;
my $is_showing=0;

sub sync_env {
    my ($db) = @_;
    $db->commit;
    for ($db->warnings($warnlevel)) { print }
    $db->write_log if !$is_showing;
    my $old = select STDOUT if !$is_showing;
    for my $z ($db->to_sync()) {
	my ($k,$v) = @$z;
	if (defined $v) {
	    if ($is_csh) {
		print "setenv $k '$v';\n";
	    } else {
		print "$k='$v'; export $k;\n";
	    }
	} else {
	    if ($is_csh) {
		print "unsetenv $k;\n";
	    } else {
		print "unset $k;\n";
	    }
	}
    }
    select $old if $old;
}

sub cmd_2re {
    my $cmd = shift;
    $cmd ||= '*';
    $cmd =~ tr [\[\]\{\}\(\)\|\$\#\?] //d;
    $cmd =~ s/\./'\.'/eg;
    $cmd =~ s/\*/'.*'/eg;
    $cmd;
}

sub GO() {
    my $db = Envy::DB->new(\%ENV);

    while (@ARGV and $ARGV[0] =~ m/^\-/) {
	my $arg = shift @ARGV;
	if ($arg =~ m/^\-csh$/) { $is_csh=1 }
	elsif ($arg =~ m/^\-un$/) { $is_unload=1 }
	elsif ($arg =~ m/^-q(uiet)?$/) { $warnlevel = 0 }
	elsif ($arg =~ m/^\-debug$/)   { $warnlevel = 5 }
	elsif ($arg =~ m/^-v$/)        { ++$warnlevel }
	elsif ($arg =~ m/^-v(\d+)?/)   { $warnlevel = length $1? $1 : 2; }
	else {
	    warn "option '$arg' ignored\n"
	}
    }
    
    my $cmd = cmd_2re(shift @ARGV);
    
    select STDERR;    # STDOUT goes the shell eval
    
    if ($cmd eq 'show' and @ARGV >= 1 and $ARGV[0] eq 'paths') {
	print "[Just use 'paths' instead of 'show paths'.]\n\n";
	shift @ARGV;
	$cmd = 'paths';
    }

    if ($cmd eq 'paths') {
	# horrifying amount of code duplication GACK! XXX
	$cmd = cmd_2re(shift @ARGV);
	my ($mo, $ld) = $db->status();
	for ($db->warnings($warnlevel)) { print }
	my %loaded;
	for (@$ld) { $loaded{$_}=1 }
	my $l=0;
	my @mo = sort grep(((/$cmd/i) && ($mo->{$_} !~ /\.priv/)), keys %$mo);
	for my $m (@mo) { $l = length $m if $l < length $m; }
	
	print "Location of envies source code:\n\n";
	for my $m (@mo) {
	    next if $mo->{$m} =~ /\.priv/; # Hide files in .priv directory
	    my $NumSpaces = 1 + $l - length $m;
	    my $desc = $mo->{$m};
	    print(($loaded{$m}? " x ":"   ").
		  $m . ' 'x($NumSpaces-1) . " $desc\n");
	}
	Huh();
    }
    elsif ($cmd eq "load" or $cmd eq "reload") {
	Huh("Unenvy load means what?")
	    if $is_unload;
	&Help if @ARGV < 1;
	while (@ARGV) {
	    $db->envy(1, shift @ARGV)
		if $cmd eq 'reload';
	    $db->envy(0, shift @ARGV);
	}
	sync_env($db);
	
    } elsif ($cmd eq "show") {
	&Help if @ARGV < 1;
	$is_showing = 1;
	while (@ARGV) { $db->envy($is_unload, shift @ARGV); }
	sync_env($db);
	
    } elsif ($cmd eq "un" or $cmd eq "unload") {
	Huh("Unenvy unload doesn't mean what?")
	    if $is_unload;
	my ($ign, $loaded) = $db->status();
	push @ARGV, $db->{first} if @ARGV == 0;
	while (@ARGV) { $db->envy(1, shift @ARGV); }
	sync_env($db);
	
    } elsif ($cmd eq "list") {
	$cmd = cmd_2re(shift @ARGV);
	my ($mo, $ld) = $db->status();
	for ($db->warnings($warnlevel)) { print }
	my %loaded;
	for (@$ld) { $loaded{$_}=1 }
	my $l=0;
	my @mo = sort grep(((/$cmd/i) && ($mo->{$_} !~ /\.priv/)), keys %$mo);
	for my $m (@mo) { $l = length $m if $l < length $m; }
	if($cmd eq ".*"){
	    print "All available envies:\n\n";
	}else{
	    print "Available envies matching '$cmd':\n\n";
	}
	for my $m (@mo) {
	    next if $mo->{$m} =~ /\.priv/; # Hide files in .priv directory
	    my $NumSpaces = 1 + $l - length $m;
	    my $padding = "\n" . ' 'x($l+4);
	    my $desc = $db->description($m) || $mo->{$m};
	    $desc =~ s/\n/$padding/g;
	    print(($loaded{$m}? " x ":"   ").
		  $m . ' 'x($NumSpaces-1) . " $desc\n");
	}
	Huh();
	
    } elsif ($cmd eq "help") {
	&Help(shift @ARGV);
	
    } else {
	my ($mo, $ld) = $db->status();
	my %loaded;
	for (@$ld) { $loaded{$_}=1 }
	my @mo;
	foreach (sort keys %$mo){
	    push(@mo,$_) if($mo->{$_} !~ /\.priv/); # hide .priv directory files
	}
	if (@mo > 1) {
	    my @exact = sort grep(/^$cmd$/i, keys %$mo);
	    if (@exact == 1) {
		@mo = @exact;
	    } else {
		@mo = sort grep(((/$cmd/i) && ($mo->{$_} !~ /\.priv/)), keys %$mo);
	    }
	}
	if (@mo == 0) {
	    print "Envy '$cmd' not found.\n";
	} elsif (@mo == 1) {
	    my $mo = $mo[0];
	    $db->check_fuzzy($mo);
	    $db->envy($is_unload, $mo);
	    sync_env($db);
	    return;
	}
	for ($db->warnings($warnlevel)) { print }
	@mo = grep(!/^\./, @mo); # hide dot files
	use integer;
	my $mid = (1+@mo)/2;
	for (my $i=0; $i < $mid; $i++) {
	    my $m = $mo[$i];
	    print $loaded{$m}? " x " : "   ";
	    print $m.' 'x(34-length $m);
	    if ($mo[$i+$mid]) {
		my $m = $mo[$i+$mid];
		print $loaded{$m}? " x " : "   ";
		print $m;
	    }
	    print "\n";
	}
    }
}

sub Huh {
    my ($why) = @_;
    if ($why) {
	print "** $why\n";
    } else {
	print "\n";
    }
    print "** Type 'envy help' for usage information. **\n";
    exit;
}

sub Help {
    my $page = shift;
    if (!$page) {
	print "
  Envy $Envy::DB::VERSION -- Environment Dimension Manager

  Try:

     envy help usage    for command line arguments
     envy help custom   for a description of \$HOME/.custom/ files
     envy help author   for help writing .env files
     envy help path     for an explaination of search paths
     envy help env      for a list of envy specific environment variables
     envy help copy     for licensing information

  Send email to envy\@listbox.com for support.  Thanks!

";
    } elsif ($page eq 'usage') {
	print "
   list [<envy>]                - See descriptions
   paths [<envy>]               - Location of source files
   load <envy> [<envy> ...]     - (Re)loads <envy> environments
   show <envy> [<envy> ...]     - Dumps action to stdout
   un <envy> [<envy> ...]       - Unloads <envy> environments
   unload all                   - Unloads all loaded envys
   <str>                        - Lists/loads envys that match <str>
                                  AVOID IN SCRIPTS; CMD-LINE ONLY

   These options must be first on the command line:
   -csh                         - csh mode
   -quiet                       - Only report errors
   -v\\d                         - Set verbose level to parameter
   -debug                       - Maximum verbosity

";
    } elsif ($page eq 'custom') {
	require Envy::Conf;
	# avoid silly warning
	my $startup = $Envy::Conf::startup = $Envy::Conf::startup;
	print '
   The following files can be found in $HOME/.custom/...

     startup     - Your startup envy (default: '.$startup.')
     win.name    - Your window manager setup

   Bourne Shell:
     profile     - Sourced once upon login
     shrc        - Sourced for each new shell instance

   C-Shell:
     login       - Sourced once upon login
     cshrc       - Sourced for each new shell instance

';

    } elsif ($page eq 'author') {
	print "
   require Envy 2.16
   dimension java-version            # Declares dimension membership
   echo Java is really neat.  I like it.
   alpha                             # Notify is alpha software
   beta                              # Notify is beta software
   depreciated                       # Notify is depreciated
   error Java is no longer available.  Sorry.

   require objstore                  # Insures objstore is loaded
   JAVA_HOME=/nw/prod/usr            # Sets environment variable
   JAVA_HOME:=\$HOME/java             # Overrides environment variable
   PATH+=\$JAVA_HOME/bin              # Prepend to colin separated list
   PATH=+\$JAVA_HOME/bin              # Append to colin separated list
   MYTOP=\$ENVY_BASE                  # Real path to .env file's tree top
   MYTOP=\$ENVY_LINKBASE              # Path to .env file's tree top

";
    } elsif ($page eq 'path') {
	my $w=0;
	my %def;
	my @cur = split /:+/, $ENV{ENVY_PATH};
	for (@cur) { $w = length if length > $w }
	for (@DefaultPath) { $def{$_} = 1 }
	@cur = map { sprintf("%-$ {w}s  %s", $_, $def{$_}? '#default':'') } @cur;
	print "
   Current search path (order is observed):
     ".join("\n     ", @cur)."

   All search paths also include the .priv directory (if found).

   Envy also looks in \$HOME/.envy/ for .env files.  You can
   use this to test new stuff.

";
    } elsif ($page eq 'env') {
	print "
   \$ETOP           - Prefix for login scripts.
   \$ENVY_PATH      - Colin separated search path.  Envies are typically
                     installed in \$ETOP/env/envy.  See 'envy help path' too.
   \$ENVY_STATE     - Keeps track of which modules are loaded & dependencies.
   \$ENVY_DIMENSION - Keeps track of dimensions.
   \$ENVY_VERSION   - Envy protocol version.
   \$ENVY_VERBOSE   - Default verbosity level.

";
    } elsif ($page eq 'copy') {
	print q[
   Copyright © 1997-1998 Joshua Nathaniel Pritikin.  All rights reserved.

   This package is free software and is provided "as is" without express
   or implied warranty.  It may be used, redistributed and/or modified
   under the terms of the Perl Artistic License (see
   http://www.perl.com/perl/misc/Artistic.html)

   ('Envy' is not an acronym.  Pronounced: 'n-v')

];
    } else {
	print "No help for $page.  Sorry.\n";
    }
    exit;
}
&GO;
