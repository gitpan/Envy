#!/usr/local/bin/perl -w

use strict;
use lib "./t";
use envy_tester;

my $d = new envy_tester("./t/path");

system(envy("load gems-1.9").
       envy("load gems-dev").
       envy("").
       envy("load gems-1.9").
       envy("").
       envy("un gems-1.9.1").
       envy("load gems-1.9").
       envy("").
       envy("un").
       envy("")
       )==0 or die "br";

$d->harness_report(1);
