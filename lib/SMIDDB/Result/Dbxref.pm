use utf8;
package SMIDDB::Result::Dbxref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Dbxref

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<dbxref>

=cut

__PACKAGE__->table("dbxref");

=head1 ACCESSORS

=head2 dbxref_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'dbxref_dbxref_id_seq'

=head2 db_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 accession

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 version

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "dbxref_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "dbxref_dbxref_id_seq",
  },
  "db_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "accession",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "version",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</dbxref_id>

=back

=cut

__PACKAGE__->set_primary_key("dbxref_id");

=head1 RELATIONS

=head2 compound_dbxrefs

Type: has_many

Related object: L<SMIDDB::Result::CompoundDbxref>

=cut

__PACKAGE__->has_many(
  "compound_dbxrefs",
  "SMIDDB::Result::CompoundDbxref",
  { "foreign.dbxref_id" => "self.dbxref_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 db

Type: belongs_to

Related object: L<SMIDDB::Result::Db>

=cut

__PACKAGE__->belongs_to(
  "db",
  "SMIDDB::Result::Db",
  { db_id => "db_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-09-04 17:41:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6Znxhl85Z19ZtuLqj3Sy4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
