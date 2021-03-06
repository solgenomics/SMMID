
package AddGroupTables;

use Moose;

extends 'Dbpatch::PatchRoot';

sub init_patch {
    my $self = shift;
    $self->name('AddGroupTables');
    $self->description('Adds dbgroup etc.');

}

sub patch {
    my $self = shift;

    print STDERR "Adding dbgroup table...\n";
    eval { 
	$self->dbh()->do("create table dbgroup ( dbgroup_id serial primary key, name varchar(100), description text)");
    };
    if ($@) { print STDERR "ERROR: $@\n"; }

    eval {
	print STDERR "Adding dbuser_dbgroup table...\n";
	$self->dbh()->do("create table dbuser_dbgroup ( dbuser_dbgroup_id serial primary key, dbuser_id bigint references dbuser, dbgroup_id bigint references dbgroup)");
    };
    if ($@) { print STDERR "ERROR: $@\n"; }

    eval {
	print STDERR "add dbgroup_id column to compound table...\n";
	$self->dbh()->do("alter table compound add column dbgroup_id bigint references dbgroup");
    };
    if ($@) { print STDERR "ERROR: $@\n"; }

    $self->dbh->commit();

}
