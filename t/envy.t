#!./perl -w

use Test;
BEGIN { plan tests => 1 }
use lib './t';
use envy_tester;

use Envy qw(objstore reuters);

ok($ENV{OS_ROOTDIR} eq '/nw/dist/odi/os/5.0/sunpro' and
   $ENV{SSLDIR} eq '/Vendor/products/ssl');

