package envy_tester;
use strict;
use lib '.';
use envy_config;
use Test::Output;
use vars qw(@ISA @EXPORT);
@ISA = qw(Test::Output Exporter);
@EXPORT = qw(&envy &wrapper);

%ENV = (PATH => '/bin:/usr/bin:/usr/sbin:/usr/ucb',
	ETOP => './t',
	REGRESSION_PATH => './t/etc/envy');

-d 't' or die "Can't find ./t directory";

my $catenv = "./t/catenv.sh;\n";

sub wrapper {
    delete $ENV{PATH};
    my $cmd = ("./blib/script/wrapper -m ".join(' ', @_).
	       " -s $catenv");
    $cmd;
}

sub envy {
    my $cmd = ("$production_perl -w ./blib/script/envy.pl ".join(' ', @_).
	       " 1>/tmp/env 2>/tmp/stdout; . /tmp/env\n".
	       "cat /tmp/stdout | grep -v Using\n".
	       $catenv
	       );
#    warn $cmd;
    $cmd;
}

1;
