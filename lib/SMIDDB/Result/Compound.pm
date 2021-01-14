use utf8;
package SMIDDB::Result::Compound;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Compound

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<compound>

=cut

__PACKAGE__->table("compound");

=head1 ACCESSORS

=head2 compound_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'compound_compound_id_seq'

=head2 formula

  data_type: 'text'
  is_nullable: 0

=head2 organisms

  data_type: 'text'
  is_nullable: 1

=head2 smid_id

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 smiles

  data_type: 'text'
  is_nullable: 0

=head2 curation_status

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 curator_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 last_curated_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 create_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 last_modified_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 iupac_name

  data_type: 'text'
  is_nullable: 0

=head2 synonyms

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 molecular_weight
   
   data_type: 'real'
   is_nullable: 0

=head2 doi

    data_type: varchar(255);
    is_nullable 1

=cut

__PACKAGE__->add_columns(
  "compound_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "compound_compound_id_seq",
  },
  "formula",
  { data_type => "text", is_nullable => 0 },
  "organisms",
  { data_type => "text", is_nullable => 1 },
  "smid_id",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "smiles",
  { data_type => "text", is_nullable => 0 },
  "curation_status",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "curator_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "last_curated_time",
  { data_type => "timestamp", is_nullable => 1 },
  "create_date",
  { data_type => "timestamp", is_nullable => 1 },
  "last_modified_date",
  { data_type => "timestamp", is_nullable => 1 },
  "iupac_name",
  { data_type => "text", is_nullable => 0 },
  "synonyms",
  { data_type => "text", is_nullable => 1 },
  "description",
    { data_type => "text", is_nullable => 1 },
    "molecular_weight",
    { data_type => "real", is_nullable => 0 },
    "doi",
    { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</compound_id>

=back

=cut

__PACKAGE__->set_primary_key("compound_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<compound_formula_key>

=over 4

=item * L</formula>

=back

=cut

__PACKAGE__->add_unique_constraint("compound_formula_key", ["formula"]);

=head2 C<compound_smid_id_key>

=over 4

=item * L</smid_id>

=back

=cut

__PACKAGE__->add_unique_constraint("compound_smid_id_key", ["smid_id"]);

=head2 C<compound_smiles_key>

=over 4

=item * L</smiles>

=back

=cut

__PACKAGE__->add_unique_constraint("compound_smiles_key", ["smiles"]);

=head1 RELATIONS

=head2 compound_dbxrefs

Type: has_many

Related object: L<SMIDDB::Result::CompoundDbxref>

=cut

__PACKAGE__->has_many(
  "compound_dbxrefs",
  "SMIDDB::Result::CompoundDbxref",
  { "foreign.compound_id" => "self.compound_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 compound_images

Type: has_many

Related object: L<SMIDDB::Result::CompoundImage>

=cut

__PACKAGE__->has_many(
  "compound_images",
  "SMIDDB::Result::CompoundImage",
  { "foreign.compound_id" => "self.compound_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 curator

Type: belongs_to

Related object: L<SMIDDB::Result::Dbuser>

=cut

__PACKAGE__->belongs_to(
  "curator",
  "SMIDDB::Result::Dbuser",
  { dbuser_id => "curator_id" },
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

=head2 experiments

Type: has_many

Related object: L<SMIDDB::Result::Experiment>

=cut

__PACKAGE__->has_many(
  "experiments",
  "SMIDDB::Result::Experiment",
  { "foreign.compound_id" => "self.compound_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-09-04 17:41:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+HeVslA836wmXQLRmozVVQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
