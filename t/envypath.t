# envy -*-perl-*-
use strict;
use Test; plan test => 3;
%ENV = (REGRESSION_ENVY_PATH => "./example/area1/etc/envy");
require Envy::DB;

-d 't' or die "Can't find ./t directory";

my $db = Envy::DB->new(\%ENV);

my %got;
sub envy {
    $db->begin;
    $db->envy(@_);
    $db->commit;
    for ( $db->to_sync()) {
	if (defined $_->[1]) {
	    $got{$_->[0]} = $_->[1]
	} else {
	    delete $got{$_->[0]};
	}
    }
}

envy(0, 'area1');
my @P = split(/:+/, $got{ENVY_PATH});
ok @P, 1;

envy(0, 'pathtest');
my $save = $got{ENVY_PATH};

envy(1, 'pathtest');
ok $got{ENVY_PATH}, $save;
ok $save, '/somewhere/';
