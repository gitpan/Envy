# depreciated - use Envy::Load instead

package Envy;
use Carp;
use FindBin;

# We need to be extra careful to make sure we pick-up the right
# version of Envy::DB.

eval { require "$FindBin::Bin/../lib/perl5/site_perl/Envy/DB.pm" }
  if !defined $ {"Envy::DB::VERSION"};
eval { require Envy::DB }
  if !defined $ {"Envy::DB::VERSION"};
eval { require "$FindBin::Bin/../lib/Envy/DB.pm" } #blib
  if !defined $ {"Envy::DB::VERSION"};
die "Can't load Envy::DB: $@"
  if !defined $ {"Envy::DB::VERSION"};

warn "Please use Envy::Load instead of Envy\n";

my $db = new Envy::DB(\%ENV);

sub import {
    my ($me, @imports) = @_;
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

Envy - Load Envy Files

=head1 SYNOPSIS

    use Envy qw(dev objstore);

=head1 DESCRIPTION

Similar to `envy load ...`.

=cut
