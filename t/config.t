# -*-perl-*-

use strict;
use Test; plan test => 2;

$ENV{ENVY_PATH} = join(':', '/my/site/path/bin', '/my/custom/path/bin');
$ENV{ENVY_DIMENSION} = join(':', 'First,qsg','objstore,objstore');

require './Config.pm';

package Envy::Config;
use vars qw($default_startup $default_path);
use Test;

ok join(':',eval $default_path), $ENV{ENVY_PATH}, $@;
ok $default_startup, 'qsg';

