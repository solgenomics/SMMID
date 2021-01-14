use utf8;
package SMIDDB::Result::Result;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Result

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

=head1 TABLE: C<result>

=cut

__PACKAGE__->table("result");

=head1 ACCESSORS

=head2 result_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'result_result_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 method_type

  data_type: varchar(100)
  is_nullable: 0

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 data

  data_type: 'jsonb'
  is_nullable: 0

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 create_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 modified_date

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "result_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "result_result_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "description",
    { data_type => "text", is_nullable => 1 },
    "method_type",
    { data_type => "varchar", is_nullable => 0, size => 100},
    
  "notes",
  { data_type => "text", is_nullable => 1 },
  "data",
  { data_type => "jsonb", is_nullable => 0 },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "create_date",
  { data_type => "timestamp", is_nullable => 1 },
  "modified_date",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</result_id>

=back

=cut

__PACKAGE__->set_primary_key("result_id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-07-25 00:15:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zWhfNnWmEbgBvB1P5AC8xA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
