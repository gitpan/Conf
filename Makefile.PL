use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'		=> 'Conf',
    'VERSION_FROM'	=> 'Conf.pm',
    'PREREQ_PM'		=> { },
    'ABSTRACT_FROM'     => 'Conf.pm',
    'AUTHOR'            => 'Hans Oesterholt-Dijkema <oesterhol@cpan.org>',
    'test'             => { 'TESTS' => $TESTS },
);

