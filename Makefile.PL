# don't worry about this file - you should not
# need to edit it at all.

use 5.008;

use ModPerl::MM ();
use Apache::TestMM qw(test clean);
use Apache::TestRunPerl ();

Apache::TestMM::filter_args();

Apache::TestRunPerl->generate_script();

ModPerl::MM::WriteMakefile(
  NAME      => 'Apache2::Instrument',
  VERSION_FROM => 'lib/Apache2/Instrument.pm',
  SIGN => 1,
  PREREQ_PM => {
    'mod_perl'   => '2',
    'Test::More' => '0.47',
  },
);
