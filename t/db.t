# envy -*-perl-*-
use strict;
use Test; plan test => 12;
%ENV = (REGRESSION_ENVY_PATH => "./example/area1/etc/envy");
require Envy::DB;
ok 1;

-d 't' or die "Can't find ./t directory";

my %got;
my $db = Envy::DB->new(\%ENV);
ok 2;

$db->envy(0, 'area1');

for ( $db->to_sync()) { $got{$_->[0]} = $_->[1] }
ok join('',$db->warnings(2)), '';
ok $got{ETOP}, './example/area1';

$db->envy(0, 'openwin');

for ( $db->to_sync()) { $got{$_->[0]} = $_->[1] }
ok join('',$db->warnings(2)), '';
ok $got{OPENWINHOME}, '/usr/openwin';
ok grep(/openwin/, split /:+/, $got{PATH}), 1;

$db->envy(0, 'openwin');

for ( $db->to_sync()) { $got{$_->[0]} = $_->[1] }
ok join('',$db->warnings(2)), '';
ok grep(/openwin/, split /:+/, $got{PATH}), 1;

$db->envy(1, 'openwin');

for ( $db->to_sync()) { $got{$_->[0]} = $_->[1] }
ok join('',$db->warnings(2)), '';
ok 0+grep(/openwin/, split /:+/, $got{PATH}), 0;
ok !$got{OPENWINHOME}, 1;
