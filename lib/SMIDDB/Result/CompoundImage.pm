use utf8;
package SMIDDB::Result::CompoundImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::CompoundImage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<compound_image>

=cut

__PACKAGE__->table("compound_image");

=head1 ACCESSORS

=head2 compound_image_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'compound_image_compound_image_id_seq'

=head2 compound_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 image_id

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

=head2 curation_status

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "compound_image_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "compound_image_compound_image_id_seq",
  },
  "compound_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "image_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "curator_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "last_curated_time",
  { data_type => "timestamp", is_nullable => 1 },
  "curation_status",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</compound_image_id>

=back

=cut

__PACKAGE__->set_primary_key("compound_image_id");

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

=head2 image

Type: belongs_to

Related object: L<SMIDDB::Result::Image>

=cut

__PACKAGE__->belongs_to(
  "image",
  "SMIDDB::Result::Image",
  { image_id => "image_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-09-04 17:41:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JEJgqKe/iPnnjx7Re2inew


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
