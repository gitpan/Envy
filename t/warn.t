#!./perl -w
use strict;
use Test; plan test => 2;

require Envy::DB;
my $db = Envy::DB->new(\%ENV);

$db->e('error');
$db->w('warn');
$db->n('noisy');
$db->d('debug');

$db->commit;

my @w = $db->warnings(4);
ok @w, 4;
chop @w;
ok join(' ',sort @w),'debug error noisy warn';
