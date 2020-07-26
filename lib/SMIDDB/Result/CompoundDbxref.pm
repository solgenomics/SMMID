use utf8;
package SMIDDB::Result::CompoundDbxref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::CompoundDbxref

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<compound_dbxref>

=cut

__PACKAGE__->table("compound_dbxref");

=head1 ACCESSORS

=head2 compound_dbxref_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'compound_dbxref_compound_dbxref_id_seq'

=head2 compound_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 dbxref_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "compound_dbxref_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "compound_dbxref_compound_dbxref_id_seq",
  },
  "compound_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "dbxref_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</compound_dbxref_id>

=back

=cut

__PACKAGE__->set_primary_key("compound_dbxref_id");

=head1 RELATIONS

=head2 compound

Type: belongs_to

Related object: L<SMIDDB::Result::Compound>

=cut

__PACKAGE__->belongs_to(
  "compound",
  "SMIDDB::Result::Compound",
  { compound_id => "compound_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 dbuser

Type: belongs_to

Related object: L<SMIDDB::Result::Dbuser>

=cut

__PACKAGE__->belongs_to(
  "dbuser",
  "SMIDDB::Result::Dbuser",
  { dbuser_id => "dbuser_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 dbxref

Type: belongs_to

Related object: L<SMIDDB::Result::Dbxref>

=cut

__PACKAGE__->belongs_to(
  "dbxref",
  "SMIDDB::Result::Dbxref",
  { dbxref_id => "dbxref_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-07-25 00:15:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vDRd8b/Xv0POt8H8OvXJ0w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
