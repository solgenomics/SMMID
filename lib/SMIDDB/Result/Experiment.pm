use utf8;
package SMIDDB::Result::Experiment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Experiment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<experiment>

=cut

__PACKAGE__->table("experiment");

=head1 ACCESSORS

=head2 experiment_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'experiment_experiment_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 experiment_type

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 run_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 create_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 dbuser_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 operator

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 data

  data_type: 'jsonb'
  is_nullable: 1

=head2 compound_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 curation_status

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 curator_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 last_curatated_time

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "experiment_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "experiment_experiment_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "experiment_type",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "run_date",
  { data_type => "timestamp", is_nullable => 1 },
  "create_date",
  { data_type => "timestamp", is_nullable => 1 },
  "dbuser_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "operator",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "data",
  { data_type => "jsonb", is_nullable => 1 },
  "compound_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "curation_status",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "curator_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "last_curatated_time",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</experiment_id>

=back

=cut

__PACKAGE__->set_primary_key("experiment_id");

=head1 RELATIONS

=head2 compound

Type: belongs_to

Related object: L<SMIDDB::Result::Compound>

=cut

__PACKAGE__->belongs_to(
  "compound",
  "SMIDDB::Result::Compound",
  { compound_id => "compound_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-09-04 17:41:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oTwvRvD4NDuvalbtiOQ2WQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
