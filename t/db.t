# envy -*-perl-*-
use strict;
use Test; plan test => 21;
%ENV = (REGRESSION_ENVY_PATH => "./example/area1/etc/envy");
require Envy::DB;
ok 1;

-d 't' or die "Can't find ./t directory";

my %got;
my @w;
my $db = Envy::DB->new(\%ENV);
ok 2;

sub envy {
    $db->envy(@_);
    for ( $db->to_sync()) { $got{$_->[0]} = $_->[1] }
    @w = $db->warnings(2);
}

envy(0, 'area1');
ok @w, 0;
ok $got{ETOP}, './example/area1';

envy(0, 'openwin');
ok @w, 0;
ok $got{OPENWINHOME}, '/usr/openwin';
ok grep(/openwin/, split /:+/, $got{PATH}), 1;

envy(0, 'openwin');
ok @w, 0;
ok grep(/openwin/, split /:+/, $got{PATH}), 1;

envy(1, 'openwin');
ok @w, 0;
ok 0+grep(/openwin/, split /:+/, $got{PATH}), 0;
ok !$got{OPENWINHOME}, 1;

envy(0, 'insure');
ok @w, 0;

my @p = split(/:+/, $got{PATH});
ok @p, 3;
ok $p[0], '/bin.solaris/';
ok $p[2], '/ccs/';

envy(0, 'append');
envy(0, 'append');
ok @w, 0;
@p = split /:+/, $got{PATH};
ok @p, 4;
ok $p[3], 'appended';

envy(1, 'append');
envy(0, 'insure-4.0');
ok @w, 1;
ok $w[0], '/Swapping insure/';

#warn join(' ', %got);
