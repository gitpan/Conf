# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 8;
BEGIN { 
	use_ok('Conf');
	use_ok('Conf::SQL');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

### Regular tests

my $DSN=$ENV{"DSN"};
my $DBUSER=$ENV{"DBUSER"};
my $PASS=$ENV{"DBPASS"};
my $TABLE="test_conf";

if (not $DSN) {
    die "You need to set proper values for \$DSN, \$DBUSER and \$DBPASS\n".
        "environment variables set these  variables to proper values.";
}

my $conf=new Conf(new Conf::SQL(DSN => $DSN,DBUSER => $DBUSER,DBPASS => $PASS, TABLE => $TABLE));

$conf->set("test","HI=Yes");
$conf->set("test1","NO!");
$conf->set("test2","Here's a problem");

ok($conf->get("test") eq "HI=Yes", "initial conf in \$string -> test=HI=Yes");
ok($conf->get("test1") eq "NO!", "initial conf in \$string -> test1=NO!");
ok($conf->get("test2") eq "Here's a problem", "initial conf in \$string -> test2=Here's a problem");

$conf->set("oesterhol","account");
ok($conf->get("oesterhol") eq "account", "initial conf in \$string -> oesterhol=account");


### Look up all variables

my %e;
$e{"test"}=0;
$e{"test1"}=0;
$e{"test2"}=0;
$e{"oesterhol"}=0;

my @vars=$conf->variables();
for my $var (@vars) {
	$e{$var}+=1;
}

my $all=1;
for my $k (keys %e) {
	if ($e{$k}==0) { $all=0; }
}

ok($all==1,"variables: --> all variables are there");

### Reset conf item

$conf->set("oesterhol","HI!");
ok($conf->get("oesterhol") eq "HI!", "initial conf in \$string -> oesterhol=HI!");

### Cleanup

my $dbh=DBI->connect($DSN,$DBUSER,$DBPASS);
my $driver=lc($dbh->{Driver}->{Name});

if ($driver eq "pg") {
  $dbh->do("DROP INDEX $TABLE"."_idx");
  $dbh->do("DROP TABLE $TABLE");
} elsif ($driver eq "mysql") {
  $dbh->do("DROP INDEX $TABLE"."_idx ON $TABLE");
  $dbh->do("DROP TABLE $TABLE");
} elsif ($driver eq "sqlite") {
  $dbh->do("DROP INDEX $TABLE"."_idx");
  $dbh->do("DROP TABLE $TABLE");
} else { # Hope for the best
  $self->{"dbh"}->{"PrintError"}=0;
  $dbh->do("DROP INDEX $TABLE"."_idx");
  $dbh->do("DROP TABLE $TABLE");
}

$dbh->disconnect();


