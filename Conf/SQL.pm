package Conf::SQL;

use 5.006;
use strict;
use DBI;

sub new {
  my $class=shift;
  my $dsn=shift;
  my $user=shift;
  my $pass=shift;
  my $self;

  # Read in config

  $self->{"dbh"}=DBI->connect($dsn,$user,$pass);
  $self->{"dbh"}->{"PrintError"}=0;

  # Table exists?

  my $sth=$self->{"dbh"}->prepare("SELECT COUNT(var) FROM conf_table");
  $sth->execute();
  if ($sth->rows() lt 0) {
    $sth->finish();

    my $dbh=$self->{"dbh"};
    my $driver=lc($dbh->{Driver}->{Name});

    if ($driver eq "pg") { # PostgreSQL
      $dbh->do("CREATE TABLE conf_table(uid varchar,var varchar,value varchar)");
      $dbh->do("CREATE INDEX conf_table_idx ON conf_table(uid, var)");
    }
    elsif ($driver eq "mysql") { # mysql
      $dbh->do("CREATE TABLE conf_table(uid varchar(250),var varchar(250),value mediumtext)");
      $dbh->do("CREATE INDEX conf_table_idx ON conf_table(uid, var)");
    }
    elsif ($driver eq "sqlite") { # sqlite
      $dbh->do("CREATE TABLE conf_table(uid varchar(250),var varchar(1024),value text)");
      $dbh->do("CREATE INDEX conf_table_idx ON conf_table(uid, var)");
    }
    else {
      die "Cannot create table CREATE TABLE conf_table(uid varchar(250),var varchar(1024),value text)\n".
          "and index           CREATE INDEX conf_table_idx ON conf_table(uid, var)\n".
	  "I don't know this database system '$driver'";
    }
  }
  else {
    $sth->finish();
  }

  # Get USER ID

  $self->{"user"}=getlogin() || getpwuid( $< ) || 
                  $ENV{ LOGNAME } || $ENV{ USER } ||
                  $ENV{ USERNAME } || 'unknown';

  # bless

  bless $self,$class;

return $self;
}

sub DESTROY {
  my $self=shift;
  $self->{"dbh"}->disconnect();
}

sub set {
  my $self=shift;
  my $var=shift;
  my $val=shift;

  my $user=$self->{"user"};
  my $dbh=$self->{"dbh"};

  # Update or insert?

  my $sth=$dbh->prepare("SELECT COUNT(var) FROM conf_table WHERE uid='$user' AND var='$var'");
  $sth->execute();
  my ($count)=$sth->fetchrow_array();
  $sth->finish();

  if ($count==0) {
    $dbh->do("INSERT INTO conf_table (var,uid,value) VALUES (".$dbh->quote($var).",".$dbh->quote($user).",".$dbh->quote($val).")");
  }
  else {
    $dbh->do("UPDATE conf_table SET value=".$dbh->quote($val)." WHERE uid=".$dbh->quote($user)." AND var=".$dbh->quote($var));
  }
}

sub get {
  my $self=shift;
  my $var=shift;

  my $user=$self->{"user"};
  my $dbh=$self->{"dbh"};
  
  # get

  my $val=undef;
  my $sth=$dbh->prepare("SELECT value FROM conf_table WHERE uid=".$dbh->quote($user)." AND var=".$dbh->quote($var));
  $sth->execute();
  if ($sth->rows()!=0) {
    ($val)=$sth->fetchrow_array();
  }
  $sth->finish();

return $val;
}

sub variables {
  my $self=shift;

  my $user=$self->{"user"};
  my $dbh=$self->{"dbh"};

  # get variables

  my @vars;
  my $sth=$dbh->prepare("SELECT var FROM conf_table WHERE uid='$user'");
  $sth->execute();
  for (1..$sth->rows()) {
    my ($var)=$sth->fetchrow_array();
    push @vars,$var;
  }
  $sth->finish();

return @vars;
}

1;
__END__

=head1 Name

Conf::SQL - The file backend for Conf.

=head1 Abstract

C<Conf::SQL> is an SQL  backend for Conf. It handles
a table C<conf_table> with identifiers that are 
assigned values. The identifiers are specified on
a per user basis. C<Conf::SQL> tries to get the user
account of the user self.

=head1 Note

This module can be ommitted from the C<Conf> bundle.
One can optionally neclegt it's existence by using
C<perl Makefile.PL --no-sql>.

=head1 Description

Each call C<set()> will immediately result in a commit 
to the database.

=head2 C<new(DSN,USER,PASS)> --E<gt> Conf::SQL

Invoked with a valid C<DSN>, C<USER> and C<PASS> combination,
will return a Conf::SQL object that is connected to
the database. 

This function will try to create a C<conf_table>
table in the given C<DSN>, if it does not exist.

=head3 Creating the table conf_table in your database

If it cannot create a table for you, because it doesn't know
the database you are using, you can create your own. 
The table used has following form:

  CREATE TABLE conf_table(uid varchar,var varchar,value varchar)

The form presented here is a C<PostgreSQL> form. You will want
at least following specifications for uid, var and value:

   uid    varchar(250)
   var    varchar(250)
   value  text, bigtext, mediumtext, varchar(1000000000), etc.

You may also want an index on conf_table, like this one:

   CREATE INDEX conf_table_idx ON conf_table(uid, var)

=head2 DESTROY()

This function will disconnect from the database.

=head2 C<set(var,value) --E<gt> void>

Sets config key var to value. 

=head2 C<get(var) --E<gt> string>

Reads var from config. Returns C<undef>, if var does not
exist. Returns the value of configuration item C<var>,
otherwise.

=head2 C<variables() --E<gt> list of strings>

Returns all variables in the configuraton backend.

=head1 SEE ALSO

L<Conf::String | Conf::String>, L<Conf::SQL | Conf::SQL>, L<Conf::File | Conf::File>.

=head1 AUTHOR

Hans Oesterholt-Dijkema, E<lt>oesterhol@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Hans Oesterholt-Dijkema

This library is free software; you can redistribute it and/or modify
it under LGPL. 

=cut



