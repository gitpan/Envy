use lib "./t";
use envy_tester;

my $d = new envy_tester("./t/wrap");

system(wrapper('sybase objstore'))==0 or die 1;

$d->harness_report(1);
