use strict;
use lib "./t";
use envy_tester;

my $d = new envy_tester("./t/basic");

system(envy("load gems-prod").
       envy("un gems-prod"))==0 or die "br";

$d->harness_report(1);
