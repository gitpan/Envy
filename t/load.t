#!./perl -w

use lib './t';
use envy_tester;

print "1..1\n";

use Envy::Load qw(objstore reuters);

print($ENV{OS_ROOTDIR} eq '/nw/dist/odi/os/5.0/sunpro' &&
      $ENV{SSLDIR} eq '/Vendor/products/ssl'? "ok 1\n" : "not ok 1\n");
