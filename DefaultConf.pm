use strict;
package Envy::DefaultConf;
require Exporter;
use Config;
use vars qw(@ISA @EXPORT_OK
	    %env0 $startup $prefix @path);
@ISA = ('Exporter');
@EXPORT_OK = qw(%env0 $startup $prefix @path);

$prefix = $ENV{PERL5PREFIX} || $Config{prefix};

### These environment variables are hardcoded into dot.(profile|login)
my @perl;
if (exists $ENV{PERL5PREFIX}) {
    my $p = $Config{sitelib};
    $p =~ s/$Config{prefix}/$ENV{PERL5PREFIX}/;
    @perl = (PERL5LIB => $p);
}

%env0 = (
	 PATH => '/usr/bin:/usr/sbin:/usr/ucb',
	 MANPATH => '/usr/man',
	 LD_LIBRARY_PATH => '/usr/lib',
	 EDITOR => 'vi',
	 @perl,
	 );

### The default envy to load upon login
if (exists $ENV{ENVY_DIMENSION}) {
    my @first = grep /^First\,/, split /:+/, $ENV{ENVY_DIMENSION};
    $startup = (split /,/, $first[0])[1]
	if @first;
}
$startup ||= 'test';

### The default ENVY_PATH
my @p = split /:+/, $ENV{ENVY_PATH} if exists $ENV{ENVY_PATH};
unshift @p, "$prefix/etc/envy"
    if !@p || exists $ENV{PERL5PREFIX};

my %path_ok;
for (@p) {
    next if exists $path_ok{$_};
    push @path, $_;
    $path_ok{$_} = 1;
}

1;
