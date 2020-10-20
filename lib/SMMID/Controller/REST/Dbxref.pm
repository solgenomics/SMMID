
package SMMID::Controller::REST::Dbxref;

use Moose;
use Data::Dumper;

BEGIN{ extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );


sub store_dbxref :Path('/rest/store/dbxref') Args(0) {
    my $self = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "You need to be logged in to store dbxrefs. Sorry." };
	return;
    }

    my $dbuser_id = $c->user()->get_object()->dbuser_id();
    my $compound_id = $c->req->param("compound_id");
    my $db_id = $c->req->param("db_id");
    my $accession = $c->req->param("dbxref_accession");
    my $version = $c->req->param("dbxref_version");
    my $description = $c->req->param("dbxref_description");

    my $errors = "";
    if (! $compound_id) {  $errors .= "Need a compound id. "; }
    if (! $db_id) { $errors .= "Need a db_id. "; }
    if (! $accession) { $errors .= "Need an accession. "; }

    if ($errors) {
	$c->stash->{rest} = { error => $errors };
	return;
    }

    my $row = {
	db_id => $db_id,
	accession => $accession,
	version => $version,
	description => $description,
	dbuser_id => $dbuser_id,
    };

    print STDERR Dumper($row);
    
    my $dbxref_id;
    
    eval { 
	my $dbxref = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbxref")->new($row);
	$dbxref->insert();
	$dbxref_id = $dbxref->dbxref_id();
	
	print STDERR "COMPOUND_ID $compound_id, DBXREF_ID $dbxref_id, DBUSER_ID $dbuser_id\n";
	my $compound_dbxref = $c->model("SMIDDB")->resultset("SMIDDB::Result::CompoundDbxref")->new(
	    {
		compound_id => $compound_id,
		dbxref_id => $dbxref_id,
		dbuser_id => $dbuser_id,
		curation_status => "unverified",
	    });

	my $compound_dbxref_id = $compound_dbxref ->insert();
	
    };
    if ($@) {
	$c->stash->{rest} = { error => $@ };
	return;
    }
    
    $c->stash->{rest} = { success => 1, dbxref_id => $dbxref_id };
}

sub delete_dbxref :Path('/rest/dbxref/delete') Args(0) {
    my $self = shift;
    my $c = shift;

    my $dbxref_id = $c->req->param("dbxref_id");

    print STDERR "delete_dbxref...\n";
    if (! $c->user()) {
	$c->stash->{rest} = { error => "You need to be logged in to delete dbxrefs. Sorry." };
	return;
    }

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::CompoundDbxref")->search( { dbxref_id => $dbxref_id } );

    if ($rs->count() == 0) {
	print STDERR "dbxref with $dbxref_id not found\n";
	$c->stash->{rest} = { error => "No such dbxref_id exists ($dbxref_id)" };
	return;
    }
    
    my $user_id = $c->user()->get_object()->dbuser_id();

    my $row = $rs->next(); # there is only one
    
    if ( ($user_id != $row->dbuser_id()) && ($c->user()->get_object()->user_type() ne "curator") ) {
	print STDERR "Insufficent privileges.\n";
	$c->stash->{rest} = { error => "You are not authorized to delete this entry. Sorry" };
	return;
    }

    eval {
	print STDERR "Deleting dbxref $dbxref_id...\n";
	$rs->delete();
    };

    if ($@) {
	$c->stash->{rest} = { error => "An error occurred. ($@)" };
	return;
    }

    $c->stash->{rest} = { message => "The dbxref entry with the id $dbxref_id has been successfully deleted." };
}


sub get_db_html_select :Path('/rest/db/select') Args(0) {
    my $self = shift;
    my $c = shift;
    my $div_name = $c->req->param('div_name');
    
    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Db")->search( { } );

    my $html = "<select id=\"$div_name\" name=\"$div_name\"  >";
    while (my $row = $rs->next()) {
	$html .= '<option value="'.$row->db_id().'">'.$row->name().'</option>';
    }
    $html .= "</select>";
    
    $c->stash->{rest} = { html => $html };
}
