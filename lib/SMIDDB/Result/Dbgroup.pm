use utf8;
package SMIDDB::Result::Dbgroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Dbgroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<dbgroup>

=cut

__PACKAGE__->table("dbgroup");

=head1 ACCESSORS

=head2 group_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'dbgroup_group_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "dbgroup_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "dbgroup_group_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</group_id>

=back

=cut

__PACKAGE__->set_primary_key("dbgroup_id");

=head1 RELATIONS

=head2 compounds

Type: has_many

Related object: L<SMIDDB::Result::Compound>

=cut

__PACKAGE__->has_many(
  "compounds",
  "SMIDDB::Result::Compound",
  { "foreign.dbgroup_id" => "self.group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 dbuser_dbgroups

Type: has_many

Related object: L<SMIDDB::Result::DbuserDbgroup>

=cut

__PACKAGE__->has_many(
  "dbuser_dbgroups",
  "SMIDDB::Result::DbuserDbgroup",
  { "foreign.dbgroup" => "self.group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-03-07 20:24:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GWVxrfGjWvMAJhywy7FtdQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
