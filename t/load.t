#!./perl -w

use Test;
BEGIN { plan tests => 4 }
use lib './t';
use envy_tester;

use Envy::Load qw(objstore reuters);

ok($ENV{OS_ROOTDIR} eq '/nw/dist/odi/os/5.0/sunpro' and
   $ENV{SSLDIR} eq '/Vendor/products/ssl');

ok(!defined $ENV{SYBASE});
{
    my $e = new Envy::Load();
    $e->load('sybase');
    ok($ENV{SYBASE} eq '/usr/sybase');
}
ok(!defined $ENV{SYBASE}) or warn $ENV{SYBASE};
