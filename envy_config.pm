# These are the last paths you'll ever have to hardcode anywhere!

package envy_config;
require Exporter;
*import = \&Exporter::import;

@EXPORT = qw($ETOP $init_env $default_envy_path $production_envy
	     $production_perl $subst_files);

# This is the top of your production tree.

$ETOP = "/nw/dist/prod";

# These environment variables are hardcoded into dot.(profile|login).
# They should be the minimum reasonable set of variables necessary
# to run envy.pl.

$init_env = {
	     PATH => '/usr/bin:/usr/sbin:/usr/ucb',
	     MANPATH => '/usr/man',
	     LD_LIBRARY_PATH => '/usr/lib',
	     EDITOR => 'vi',
	    };

$default_envy_path = 
    "qw(/nw/prod/usr/etc/envy $ETOP/etc/envy $ETOP/etc $ETOP/mo)";

# used to rewrite #!perl
$production_perl = "$ETOP/bin/perl";

# where profile/login can find production envy.pl
$production_envy = "$ETOP/bin/envy.pl";

#----------------------------------------------------------------------
# YOU SHOULDN'T NEED TO EDIT BELOW HERE -------------------------------
#----------------------------------------------------------------------

# These are the files on which we do substitutions...
$subst_files = {
	     'wrapper.IN' => 'wrapper',
	     'DB.IN' => 'DB.pm',
	     'profile.IN' => 'etc/login/dot.profile',
	     'login.IN' => 'etc/login/dot.login',
	    };

