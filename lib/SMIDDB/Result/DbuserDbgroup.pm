use utf8;
package SMIDDB::Result::DbuserDbgroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::DbuserDbgroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<dbuser_dbgroup>

=cut

__PACKAGE__->table("dbuser_dbgroup");

=head1 ACCESSORS

=head2 dbuser_dbgroup_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'dbuser_dbgroup_dbuser_dbgroup_id_seq'

=head2 dbuser

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 dbgroup

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "dbuser_dbgroup_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "dbuser_dbgroup_dbuser_dbgroup_id_seq",
  },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "dbgroup_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</dbuser_dbgroup_id>

=back

=cut

__PACKAGE__->set_primary_key("dbuser_dbgroup_id");

=head1 RELATIONS

=head2 dbgroup

Type: belongs_to

Related object: L<SMIDDB::Result::Dbgroup>

=cut

__PACKAGE__->belongs_to(
  "dbgroup",
  "SMIDDB::Result::Dbgroup",
  { group_id => "dbgroup_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 dbuser

Type: belongs_to

Related object: L<SMIDDB::Result::Dbuser>

=cut

__PACKAGE__->belongs_to(
  "dbuser",
  "SMIDDB::Result::Dbuser",
  { dbuser_id => "dbuser_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-03-07 20:24:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cTStEQjKUMRImFUgzRvmYA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
