#-*-perl-*-

use ExtUtils::MakeMaker;

warn q[
       Please read ./INSTALL unless you know what you're doing!

];

unlink "./example/area1/etc/envy/area2.env";
symlink "../../../../example/area2/etc/envy/area2.env",
    "./example/area1/etc/envy/area2.env" or warn $!;
unlink "./example/area2/etc/envy/area1.env";
symlink "../../../../example/area1/etc/envy/area1.env",
    "./example/area2/etc/envy/area1.env" or warn $!;

my @dot = qw(
  dot.profile profile.part2 dot.shrc
  dot.cshrc dot.login login.part2
  bash.inputrc dot.dtprofile
);

my @prefix = (PREFIX => $ENV{PERL5PREFIX})
    if exists $ENV{PERL5PREFIX};

my @test = ('test.env' => '$(INST_ETC)/envy/test.env')
    if exists $ENV{PERL5PREFIX};

WriteMakefile(@prefix,
	      NAME => 'Envy',
	      PREREQ_PM => { Test => 1 },
	      EXE_FILES => [qw(envy.pl wrapper envied)],
	      MAN1PODS => {}, # MANPATH might be unset!
	      MAN3PODS => {},
	      PL_FILES => {'set_defaults.PL' => join(' ', values %$subst_files) },
	      VERSION_FROM => 'DB.IN',
	      PM => {
		     'Config.pm' => '$(INST_LIBDIR)/Envy/Config.pm',
		     'Load.pm' => '$(INST_LIBDIR)/Envy/Load.pm',
		     'DB.pm' => '$(INST_LIBDIR)/Envy/DB.pm',
		     @test,
		     (map { ("etc/login/$_", '$(INST_ETC)/login/'.$_) } @dot),
		    },
	      'macro' => {
			  INST_ETC=> 'blib/etc',
			  INSTALLPRIVETC=> '$(PREFIX)/etc',
			 },
	      );

# hack ETC install
sub MY::postamble {
    require "./subst.pm";
    my ($self) = @_;
    my $str='';

    while (my($k,$v)=each %$subst_files) {
	$str .= "
$v :: $k set_defaults.PL Config.pm".'
	$(PERL) -I$(INST_ARCHLIB) -I$(INST_LIB) -I$(PERL_ARCHLIB) -I$(PERL_LIB) set_defaults.PL'."\n";
    }
    $str .= "
clean ::
	rm -f ".join(' ', values %$subst_files)."\n";
    
    $str .=
    q{

set_defaults.PL :: Config.pm

pure_site_install ::
	}.$self->{NOECHO}.q{$(MOD_INSTALL) \
		read }.$self->catfile('$(SITEARCHEXP)','auto','$(FULLEXT)','.packlist').q{ \
		write }.$self->catfile('$(INSTALLSITEARCH)','auto','$(FULLEXT)','.packlist').q{ \
		$(INST_ETC) $(INSTALLPRIVETC)
};
$str;
}