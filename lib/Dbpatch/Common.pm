
package Dbpatch::Common;

use Moose;

with 'MooseX::Getopt';
with 'MooseX::Runnable';


has 'dbhost' => (
    isa => 'Str',
    is => 'rw',
    required      => 0,
    traits        => ['Getopt'],
    cmd_aliases   => 'H',
    documentation => 'required, database host',
    default => 'smid_db_postgres',
    );

has 'dbname' => (
    isa => 'Str',
    is => 'rw',
    required      => 0,
    traits        => ['Getopt'],
    cmd_aliases   => 'D',
    documentation => 'required, database name',
    default => 'smid_db',
    );

has 'dbpass' => (
    isa => 'Str',
    is => 'rw',
    required      => 0,
    traits        => ['Getopt'],
    cmd_aliases   => 'p',
    documentation => 'required, database password',
    default => 'postgres',
    );

has 'dbuser' => (
    isa => 'Str',
    is => 'rw',
    required      => 0,
    default => 'postgres', 
    traits        => ['Getopt'],
    cmd_aliases   => 'x',
    documentation => 'required, dbuser name',
    );

has 'username' => (
    isa => 'Str',
    is => 'rw',
    required      => 0,
    traits        => ['Getopt'],
    cmd_aliases   => 'u',
    documentation => 'required postgres username (default postgres), ',
    );

has "prereq" => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 0,
    traits   => ['NoGetopt'],
    default  => sub { [] }
);

has 'force' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 0,
    default     => 0,
    traits      => ['Getopt'],
    cmd_aliases => 'F',
    documentation =>
      'force apply, ignoring prereqs and possible duplicate application',
);

has 'test_mode' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 0,
    default     => 0,
    traits      => ['Getopt'],
    cmd_aliases => 't',
    documentation =>
      'Test run. Rollback the transaction.',
);


has 'dbh' => (
    is => 'rw',
    isa => 'Ref',
    );

has 'schema' => (
    is => 'rw',
    isa => 'Ref',
    );

sub run {
}

1;
