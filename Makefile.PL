#-*-perl-*-

use lib '.';
use envy_config;
use ExtUtils::MakeMaker;

warn "*" x 75 . "\n";
warn "Envy cannot simply be installed with CPAN.pm.\n\n";
warn "1. You must tweak envy_config.pm.\n";
warn "2. Set up a few directories and test it with a unix login.\n";
warn "3. Roll it out enterprise wide...\n\n";

my @dot = qw(
bash.inputrc   dot.dtprofile  dot.profile    login.part2
dot.cshrc      dot.login      dot.shrc       profile.part2
);

WriteMakefile(NAME => 'Envy',
	      PREREQ_PM => { File::Recurse => 0,
			     Test::Output => '1.02' },
	      EXE_FILES => [qw(envy.pl wrapper)],
	      MAN1PODS => {}, #nobody reads it anyway
	      MAN3PODS => {},
	      PL_FILES => {'set_defaults.PL' => 'wrapper DB.pm etc/login/dot.profile etc/login/dot.login'},
	      VERSION_FROM => 'DB.IN',
	      PM => {'Envy.pm' => '$(INST_LIBDIR)/Envy.pm',
		     'Load.pm' => '$(INST_LIBDIR)/Envy/Load.pm',
		     'DB.pm' => '$(INST_LIBDIR)/Envy/DB.pm',
		     (map { ("etc/login/$_", "blib/etc/login/$_") } @dot),
		    },
              'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
	      'macro' => {
			  INST_ETC=> '$(INST_LIB)/../etc/login',
			  INSTALLPRIVETC=> '$(INSTALLPRIVLIB)/../../etc/login',
			 },
	      );

sub MY::installbin {
    # Please fix envy_config!
    die "Production perl ($production_perl) not found" if !-x $production_perl;
    package MY;
    my $inherited = shift->SUPER::installbin(@_);
    package main;
    $inherited =~ s/^(FIXIN).*(-MExt.*)$/$1 = $production_perl $2/m;
    $inherited;
}

# hack ETC install
sub MY::postamble {
    my ($self) = @_;
    my $str='';

    while (my($k,$v)=each %$subst_files) {
	$str .= "
$v :: $k".'
	$(PERL) -I$(INST_ARCHLIB) -I$(INST_LIB) -I$(PERL_ARCHLIB) -I$(PERL_LIB) set_defaults.PL'."

clean ::
	-rm -f $v
";
    }

    $str .=
    q{
clean ::
	-rm -f t/*/accept t/*/diffs t/*/out

pure_site_install ::
	}.$self->{NOECHO}.q{$(MOD_INSTALL) \
		read }.$self->catfile('$(SITEARCHEXP)','auto','$(FULLEXT)','.packlist').q{ \
		write }.$self->catfile('$(INSTALLSITEARCH)','auto','$(FULLEXT)','.packlist').q{ \
		$(INST_ETC) $(INSTALLPRIVETC)
};
$str;
}
