use utf8;
package SMIDDB::Result::Dbpatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Dbpatch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<dbpatch>

=cut

__PACKAGE__->table("dbpatch");

=head1 ACCESSORS

=head2 dbpatch_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'dbpatch_dbpatch_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 run_timestamp

  data_type: 'timestamp'
  is_nullable: 1

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "dbpatch_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "dbpatch_dbpatch_id_seq",
  },
  "name",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "run_timestamp",
  { data_type => "timestamp", is_nullable => 1 },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</dbpatch_id>

=back

=cut

__PACKAGE__->set_primary_key("dbpatch_id");

=head1 RELATIONS

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pXp8jVCiydZ7wzDhlbDwAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
