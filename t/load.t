# -*-perl-*-
use strict;
use Test; plan test => 5;
%ENV = (REGRESSION_ENVY_PATH => "./example/area1/etc/envy");
require Envy::Load;
ok 1;

ok $ENV{ENVY_CONTEXT}, '/perl/';

Envy::Load->import('area1');
ok $ENV{ETOP}, './example/area1';

{
    my $save = Envy::Load->new();
    $save->load('cc-tools');
    ok 0+(grep /ccs/, split(/:+/, $ENV{PATH} || '')), 1;
}

ok 0+(grep /ccs/, split(/:+/, $ENV{PATH} || '')), 0;
