use strict;
package Envy::Config;
require Exporter;
use Config;
use vars qw(@ISA @EXPORT_OK
	    $prefix $init_env $default_path $envy $default_startup);
@ISA = ('Exporter');
@EXPORT_OK = qw($prefix $init_env $default_path $envy $default_startup);

$prefix = $ENV{PERL5PREFIX} || $Config{prefix};

### where profile/login can find envy.pl
$envy = "$prefix/bin/envy.pl";

### These environment variables are hardcoded into dot.(profile|login)
my @perl;
if (exists $ENV{PERL5PREFIX}) {
    my $p = $Config{sitelib};
    $p =~ s/$Config{prefix}/$ENV{PERL5PREFIX}/;
    @perl = (PERL5LIB => $p);
}
$init_env = {
	     PATH => '/usr/bin:/usr/sbin:/usr/ucb',
	     MANPATH => '/usr/man',
	     LD_LIBRARY_PATH => '/usr/lib',
	     EDITOR => 'vi',
	     @perl,
	    };

### The default ENVY_PATH
my @path = split /:+/, $ENV{ENVY_PATH} if exists $ENV{ENVY_PATH};
unshift @path, "$prefix/etc/envy"
    if !@path || exists $ENV{PERL5PREFIX};

$default_path = "qw(".join(' ', @path).")";

### The default envy to load upon login
if (exists $ENV{ENVY_DIMENSION}) {
    my @first = grep /^First\,/, split /:+/, $ENV{ENVY_DIMENSION};
    $default_startup = (split /,/, $first[0])[1]
	if @first;
}

$default_startup ||= 'test';

1;
