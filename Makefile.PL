#-*-perl-*-

use lib '.';
use envy_config;
use ExtUtils::MakeMaker;

warn "-" x 75 . "\n";
warn "
Envy is a comprehensive, multidimensional environment manager.
Installation is going to take some work beyond simply typing 'make'.

1. Use the most 'production' perl at your site to create the Makefile.

2. Tweak envy_config.pm according to your preference.  If you are a
first time user and want a test drive:

- Put the top level tree (\$ETOP) under your home directory.

- Envy will generate dot.(profile|login) files.  Symlink them into the
top of your home directory so your shell will read them at login.

- Logout and login.  Type 'envy list' or 'envy help'.

3. Explore.  Get a feel for it and get other people to try it.  NYC
was not built in a day.

Thanks and good luck!

";

my @dot = qw(
bash.inputrc   dot.dtprofile  dot.profile    login.part2
dot.cshrc      dot.login      dot.shrc       profile.part2
);

WriteMakefile(NAME => 'Envy',
	      PREREQ_PM => { File::Recurse => 0,
			     Test => '1.00', Test::Output => '1.02' },
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
