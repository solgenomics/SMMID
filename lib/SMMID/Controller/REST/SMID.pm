package SMMID::Controller::REST::SMID;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST' };

use Data::Dumper;

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );


=head1 NAME

SMMID::Controller::REST::SMID - REST-based controller to manage SMIDs

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub rest : Chained('/') PathPart('rest') CaptureArgs(0) {
    print STDERR "found rest...\n";
}

sub browse :Chained('rest') PathPart('browse') Args(0) { 
    my ($self, $c) = @_;

    print STDERR "found rest/browse...\n";

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search();

    my @data;
    while (my $r = $rs->next()) {
	push @data, [ $r->compound_id(), $r->smid_id(), $r->formula(), $r->smiles() ];
    }

    $c->stash->{rest} = { data => \@data };
}

sub browse_format :Chained('rest') PathPart('browse') Args(1) {
    my $self = shift;
    my $c = shift;
    my $format = shift;

    $self->browse($c);

    if ($format eq "html") {
	my $html = "<table border=\"1\" width=\"100%\" cellpadding=\"10\" >\n";
	foreach my $smid (@{$c->stash->{rest}->{data}}) {
	    $html .= "<tr><td><a href=\"/smid/$smid->[0]\">$smid->[1]</a></td><td>$smid->[2]</td><td>$smid->[3]</td></tr>\n";
	}
	$html .= "</table>\n";

	$c->stash->{rest} = { html => $html };
    }

    if ($format eq "datatable") {
	#...
    }
    

}

sub store :Chained('rest') PathPart('smid/store') Args(0) {
    my $self  = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "Login required for updating SMIDs." };
	return;
    }
    
    my $smid_id = $c->req->param("smid_id");
    my $iupac_name = $c->req->param("iupac_name");
    my $smiles_string = $c->req->param("smiles_string");
    my $formula = $c->req->param("formula");
    my $organisms = $c->req->param("organisms");
    my $curation_status = $c->req->param("curation_status");

    my $errors = "";
    if (!$smid_id) { $errors .= "Need smid id. "; }
    if (!$iupac_name) { $errors .= "Need a IUPAC name. "; }
    if (!$smiles_string) { $errors .= "Need smiles_string. "; }
    if (!$formula) { $errors .= "Need formula. "; }

    if ($errors) {
	$c->stash->{rest} = { error => $errors };
	return;
    }
    
    my $row = {
	smid_id => $smid_id,
	formula => $formula,
	smiles => $smiles_string,
	organisms => $organisms,
	iupac_name => $iupac_name,
	curation_status => $curation_status,
	create_date => 'now()',
	last_modified_date => 'now()',
	
    };

    my $compound_id;
    eval { 
	my $new = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->new($row);
	$new->insert();
	$compound_id = $new->compound_id();
    };

    if ($@) {
	$c->stash->{rest} = { error => "Sorry, an error occurred storing the smid ($@)" };
	return;
    }

    $c->stash->{rest} = {
	compound_id => $compound_id,
	message => "Successfully stored the smid $smid_id"
    };
    
}

sub smid :Chained('rest') PathPart('smid') CaptureArgs(1) {
    my $self = shift;
    my $c = shift;

    my $compound_id = shift;

    $c->stash->{compound_id} = $compound_id;
}


sub update :Chained('smid') PathPart('update') Args(0) {
    my $self = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "Login required for updating SMIDs." };
	return;
    }
    
    my $compound_id = $c->stash->{compound_id};
    my $smid_id = $c->req->param("smid_id");
    my $smiles_string = $c->req->param("smiles_string");
    my $formula = $c->req->param("formula");
    my $organisms = $c->req->param("organisms");
    my $iupac_name = $c->req->param("iupac_name");
    my $curation_status = $c->req->param("curation_status");

    my $errors = "";
    if (!$compound_id) {  $errors .= "Need compound id. "; }
    if (!$iupac_name) { $errors .= "Need IUPAC name. "; }
    if (!$smid_id) { $errors .= "Need smid id. "; }
    if (!$smiles_string) { $errors .= "Need smiles_string. "; }
    if (!$formula) { $errors .= "Need formula. "; }

    if ($errors) {
	$c->stash->{rest} = { error => $errors };
	return;
    }
    
    my $data = {
	smid_id => $smid_id,
	formula => $formula,
	smiles => $smiles_string,
	organisms => $organisms,
	iupac_name => $iupac_name,
	curation_status => $curation_status,
	last_modified_date => 'now()',
    };

    eval { 
	my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $compound_id });
	$row->update($data);
    };

    if ($@) {
	$c->stash->{rest} = { error => "Sorry, an error occurred storing the smid ($@)" };
	return;
    }

    $c->stash->{rest} ={ message => "Successfully stored the smid $smid_id" };
    
}


sub detail :Chained('smid') PathPart('details') Args(0) {
    my $self = shift;
    my $c = shift;

    my $s = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $c->stash->{compound_id} });

    if (! $s) {
	$c->stash->{rest} = { error => "Can't find smid with id ".$c->stash->{compound_id}."\n" };
	return;
    }

    my $data;
    $data->{smid_id} = $s->smid_id();
    $data->{compound_id} = $s->compound_id();
    $data->{formula}= $s->formula();
    $data->{organisms} = $s->organisms();
    $data->{iupac_name} = $s->iupac_name();
    $data->{smiles_string} = $s->smiles();
    $data->{curation_status} = $s->curation_status();
    $data->{last_modified_date} = $s->last_modified_date();
    $data->{create_date} = $s->create_date();
    $data->{curator_id} = $s->curator_id();
    $data->{last_curated_time} = $s->last_curated_time();

    $c->stash->{rest} = { data => $data };
}


sub smid_dbxref :Chained('smid') PathPart('dbxrefs') Args(0) {
    my $self = shift;
    my $c = shift;

    my $rs;
    if ($c->stash->{compound_id}) { 
	$rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbxref")->search(  { 'compound_dbxrefs.compound_id' => $c->stash->{compound_id} }, { join => 'compound_dbxrefs' , { join => 'db'  }});
    }
    else {
	$c->stash->{rest} = { data => [] };
	return;
    }
    
    my $data = [];

    my $delete_link = "<font color=\"red\">X</font>";
    while (my $dbxref = $rs->next()) {
	print STDERR "Retrieved: ". $dbxref->dbxref_id()."...\n";
	push @$data, [ $dbxref->db->name(), $dbxref->accession(), join("",  $dbxref->db->urlprefix(), $dbxref->db->url(), $dbxref->accession()), $delete_link ];
    }
    $c->stash->{rest} = { data => $data};
}


=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
