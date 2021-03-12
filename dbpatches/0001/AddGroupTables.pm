
package AddGroupTables;

use Moose;

extends 'Dbpatch::PatchRoot';

sub init_patch {
}

sub patch {
    my $self = shift;

    $self->dbh()->do("create table dbgroup ( dbgroup_id serial primary key, name varchar(100), description text)");

    $self->dbh()->do("create table dbuser_dbgroup ( dbuser_dbgroup_id serial primary key, dbuser_id references dbuser, dbgroup_id references dbgroup)");

    $self->dbh()->do("alter table compound add column dbgroup_id bigint references dbgroup");
    
}
