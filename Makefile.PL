use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $no_sql=0;
for my $arg (@ARGV) {
  if ($arg eq "--no-sql") {
    $no_sql=1;
    print "Leaving out Conf::SQL support\n";
  }
}

$TESTS='t/1.t t/2.t t/3.t';

%pm;
$pm{'Conf.pm'}='$(INST_LIBDIR)/Conf.pm';
$pm{'Conf/File.pm'}='$(INST_LIBDIR)/Conf/File.pm';
$pm{'Conf/String.pm'}='$(INST_LIBDIR)/Conf/String.pm';
if (not $no_sql) {
  $pm{'Conf/SQL.pm'}='$(INST_LIBDIR)/Conf/SQL.pm';
  $TESTS.=' t/4.t';
}

WriteMakefile(
    'NAME'		=> 'Conf',
    'VERSION_FROM'	=> 'Conf.pm',
    'PREREQ_PM'		=> ($no_sql) ? {} : { DBI => 1.3 },
    'ABSTRACT_FROM'     => 'Conf.pm',
    'AUTHOR'            => 'Hans Oesterholt-Dijkema <oesterhol@cpan.org>',
    'PM'                => \%pm,
    'test'             => { 'TESTS' => $TESTS },
);

