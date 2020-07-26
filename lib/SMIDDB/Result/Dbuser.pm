use utf8;
package SMIDDB::Result::Dbuser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SMIDDB::Result::Dbuser

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

=head1 TABLE: C<dbuser>

=cut

__PACKAGE__->table("dbuser");

=head1 ACCESSORS

=head2 dbuser_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'dbuser_dbuser_id_seq'

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 organization

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address

  data_type: 'text'
  is_nullable: 1

=head2 phone_number

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 registration_email

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 cookie_string

  data_type: 'text'
  is_nullable: 1

=head2 last_access_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 user_type

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 creation_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 last_modified_date

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "dbuser_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "dbuser_dbuser_id_seq",
  },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "organization",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address",
  { data_type => "text", is_nullable => 1 },
  "phone_number",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "registration_email",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "cookie_string",
  { data_type => "text", is_nullable => 1 },
  "last_access_time",
  { data_type => "timestamp", is_nullable => 1 },
  "user_type",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "creation_date",
  { data_type => "timestamp", is_nullable => 1 },
  "last_modified_date",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</dbuser_id>

=back

=cut

__PACKAGE__->set_primary_key("dbuser_id");

=head1 RELATIONS

=head2 compound_curators

Type: has_many

Related object: L<SMIDDB::Result::Compound>

=cut

__PACKAGE__->has_many(
  "compound_curators",
  "SMIDDB::Result::Compound",
  { "foreign.curator_id" => "self.dbuser_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 compound_dbusers

Type: has_many

Related object: L<SMIDDB::Result::Compound>

=cut

__PACKAGE__->has_many(
  "compound_dbusers",
  "SMIDDB::Result::Compound",
  { "foreign.dbuser_id" => "self.dbuser_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 compound_dbxrefs

Type: has_many

Related object: L<SMIDDB::Result::CompoundDbxref>

=cut

__PACKAGE__->has_many(
  "compound_dbxrefs",
  "SMIDDB::Result::CompoundDbxref",
  { "foreign.dbuser_id" => "self.dbuser_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 experiments

Type: has_many

Related object: L<SMIDDB::Result::Experiment>

=cut

__PACKAGE__->has_many(
  "experiments",
  "SMIDDB::Result::Experiment",
  { "foreign.user_id" => "self.dbuser_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 results

Type: has_many

Related object: L<SMIDDB::Result::Result>

=cut

__PACKAGE__->has_many(
  "results",
  "SMIDDB::Result::Result",
  { "foreign.dbuser_id" => "self.dbuser_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-07-25 00:15:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ljSSGqu5Am1oesPSIu6RRw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
