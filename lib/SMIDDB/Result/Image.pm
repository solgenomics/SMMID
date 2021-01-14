use utf8;
package SMIDDB::Result::Image;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Image

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<image>

=cut

__PACKAGE__->table("image");

=head1 ACCESSORS

=head2 image_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'image_image_id_seq'

=head2 image_location

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1


=head2 md5sum


=head2 image_taken_timestamp



=head2 copyright

  data_type: 'Str',
  is_foreign_key: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "image_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "image_image_id_seq",
  },
  "image_location",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "name",
    { data_type => "varchar", is_nullable => 1, size => 100 },
    "file_ext",
    { date_type => "varchar", size => 20, is_nullable => 1},
  "description",
  { data_type => "text", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "dbuser_id",
    { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },

    "md5sum",
    {data_type => "varchar", size => 100, is_nullable => 0},
    "original_filename",
    { date_type => "varchar", size => 255, is_nullable => 0},
    "image_taken_timestamp",
    { data_type => "varchar", size=> 100,  is_nullable => 0 },

    "copyright",
    { data_type => "text", is_nullable => 1 },
    "dbuser_id",
    { data_type => "Int", is_nullable => 0 },
    "create_date",
    { data_type => "Str", is_nullable => 0 },
    "modified_date",
    { data_type => "Str", is_nullable => 0},
    "obsolete",
    { data_type => 'boolean', is_nullable => 0 }
);

=head1 PRIMARY KEY

=over 4

=item * L</image_id>

=back

=cut

__PACKAGE__->set_primary_key("image_id");

=head1 RELATIONS

=head2 compound_images

Type: has_many

Related object: L<SMIDDB::Result::CompoundImage>

=cut

__PACKAGE__->has_many(
  "compound_images",
  "SMIDDB::Result::CompoundImage",
  { "foreign.image_id" => "self.image_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8kkKhFsniESwsIY2aeD38w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
