#!/usr/local/bin/perl -w
use FindBin;
use Cwd;

# We need to be extra careful to make sure envy.pl picks-up the right
# version of Envy::DB.

eval { require "$FindBin::Bin/../lib/perl5/site_perl/Envy/DB.pm" }
  if !defined $ {"Envy::DB::VERSION"};
eval { require "$FindBin::Bin/../lib/Envy/DB.pm" } #blib
  if !defined $ {"Envy::DB::VERSION"};
eval { require Envy::DB }
  if !defined $ {"Envy::DB::VERSION"};

die "Can't find Envy::DB: $@"
  if !defined $ {"Envy::DB::VERSION"};

use strict;

my $is_csh=0;
my $debug=0;
my $is_showing=0;

sub sync_env {
    my ($db) = @_;
    for ($db->warnings) { print }
    my $old = select STDOUT if !$is_showing;
    for my $z ($db->to_sync()) {
	my ($k,$v) = @$z;
	if (defined $v) {
	    if ($is_csh) {
		print "setenv $k $v\n";
	    } else {
		print "$k=$v ; export $k\n";
	    }
	} else {
	    if ($is_csh) {
		print "unsetenv $k\n";
	    } else {
		print "unset $k\n";
	    }
	}
    }
    select $old if !$is_showing;
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
    while (@ARGV and $ARGV[0] =~ m/^\-/) {
	$is_csh=1 if $ARGV[0] =~ m/^\-csh$/;
	$debug=1 if $ARGV[0] =~ m/^\-debug$/;
	shift @ARGV;
    }
    
    my $db = new Envy::DB(\%ENV);
    $db->debug($debug);
    
    my $cmd = cmd_2re(shift @ARGV);
    
    # STDOUT goes the shell eval
    select STDERR;
    
    if ($cmd eq "load" or $cmd eq "reload" or $cmd eq "show") {
	&HELP if @ARGV < 1;
	$is_showing = $cmd eq 'show';
	$db->do_log(!$is_showing);
	while (@ARGV) {
	    $db->do_envy(shift @ARGV, 0);
	}
	sync_env($db);
	
    } elsif ($cmd eq "un" or $cmd eq "unload") {
	my ($ign, $loaded) = $db->status();
	push(@ARGV, 'all') if @ARGV == 0;
	if (@ARGV == 1 and $ARGV[0] eq 'all') {
	    $db->unload_all();
	} else {
	    while (@ARGV) { $db->do_envy(shift @ARGV, 1); }
	}
	sync_env($db);
	
    } elsif ($cmd eq "list") {
	$cmd = cmd_2re(shift @ARGV);
	my ($mo, $ld) = $db->status();
	for ($db->warnings) { print }
	my %loaded;
	for (@$ld) { $loaded{$_}=1 }
	my $l=0;
	my @mo = sort grep(/$cmd/i, keys %$mo);
	for my $m (@mo) { $l = length $m if $l < length $m; }
	print "All envys currently available ($Envy::DB::VERSION):\n\n";
	for my $m (@mo) {
	    my $file = $mo->{$m};
#	    while (-l $file) { $file = readlink($file) or die "readlink: $!" }
	    print $loaded{$m}? " x ":"   ";
	    print $m . ' 'x(1 + $l - length $m) . $file . "\n";
	}
	print "\n** Type 'envy help' for usage information. **\n";
	
    } elsif ($cmd eq "help") {
	&HELP;
	
    } else {
	my ($mo, $ld) = $db->status();
	my %loaded;
	for (@$ld) { $loaded{$_}=1 }
	my @mo = sort grep(/$cmd/i, keys %$mo);
	if (@mo > 1) {
	    my @exact = sort grep(/^$cmd$/i, keys %$mo);
	    @mo = @exact if @exact == 1;
	}
	if (@mo == 0) {
	    print "Envy '$cmd' not found.\n";
	} elsif (@mo == 1) {
	    $db->fuzzy(1);
	    $db->do_envy(shift @mo, 0);
	    sync_env($db);
	    return;
	}
	for ($db->warnings) { print }
	@mo = grep(/^[^.]/, @mo); # hide dot files
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

sub HELP {
    print
"envy $Envy::DB::VERSION

1] USAGE
   envy list                    - Extra-wide listing.
   load <envy> [<envy> ...]     - (Re)loads <envy> environments.
   show <envy> [<envy> ...]     - Dumps action to stdout.
   un <envy> [<envy> ...]       - Unloads <envy> environments.
   unload all                   - Unloads all loaded envys.
   <str>                        - Lists/loads envys that match <str>.
                                  DO NOT USE NON-INTERACTIVELY!
   help                         - Not implemented.

   These options must be first on the command line:
   -csh                         - csh mode.
   -debug                       - Show search of envy path.

2] EXAMPLE 'java.env'

   require objstore                  # Causes objstore to be loaded.
   dimension java-version            # Declares membership in dimension.
   depreciated                       # Screams when loaded.

   JAVA_HOME=/nw/prod/usr            # Sets environment variable.
   PATH+=/nw/prod/odi/osji/5.0/bin   # Prepended to colin separated list.
   MYTOP=\$ENVY_BASE                  # Real path to envy without etc/envy/.
   MYTOP=\$ENVY_LINKBASE              # Path to envy without etc/envy/.

3] ENVIRONMENT VARIABLES

   \$ENVY_PATH      - Colin separated search path. Envys are typically
                     installed under \$ETOP/env/envy/.
   \$ENVY_STATE     - Keeps track of which modules are loaded & dependencies.
   \$ENVY_DIMENSION - Keeps track of dimensions.
   \$ENVY_VERSION   - Envy state protocol version.
";
exit;
}
&GO;
