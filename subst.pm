# These are the files on which we do substitutions...
use vars qw($subst_files);
$subst_files = {
		'wrapper.IN' => 'wrapper',
		'DB.IN' => 'DB.pm',
		'test.IN' => 'test.env',
		'profile.IN' => 'etc/login/dot.profile',
		'login.IN' => 'etc/login/dot.login',
	    };

1;
