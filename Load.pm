package Envy::Load;
use Carp;
use FindBin;

# We need to be extra careful to make sure we pick-up the right
# version of Envy::DB.

eval { require "$FindBin::Bin/../lib/perl5/site_perl/Envy/DB.pm" }
  if !defined $ {"Envy::DB::VERSION"};
eval { require "$FindBin::Bin/../lib/Envy/DB.pm" } #blib
  if !defined $ {"Envy::DB::VERSION"};
eval { require Envy::DB }
  if !defined $ {"Envy::DB::VERSION"};

die "Can't find Envy::DB: $@"
  if !defined $ {"Envy::DB::VERSION"};

$ENV{ENVY_CONTEXT} = $^X;

sub import {
    my ($me, @imports) = @_;
    my $db = new Envy::DB(\%ENV);
    for my $pkg (@imports) {
	$db->do_envy($pkg, 0);
    }
    for ($db->warnings) { print STDERR $_; }
    for my $z ($db->to_sync()) {
	my ($k,$v) = @$z;
	$ENV{$k} = $v;
    }
}

1;

=head1 NAME

Envy::Load - Load Envy Files

=head1 SYNOPSIS

    use Envy::Load qw(dev objstore);

=head1 DESCRIPTION

Similar to `envy load ...`.

=cut
