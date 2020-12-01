package SMMID::Controller::REST::SMID;

use Moose;
use utf8;
use Unicode::Normalize;
use Chemistry::Mol;
use Chemistry::File::SMILES;
use JSON::XS;
use Chemistry::MolecularMass;

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

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search( {}, { order_by => { -asc => 'smid_id' } } );

    my @data;
    while (my $r = $rs->next()) {

      my $cur_char = "<p style=\"color:green\"><b>\x{2713}</b></p>";
      if(!defined($r->curation_status()) || $r->curation_status() eq "unverified"){$cur_char = "<p style=\"color:red\">Unverified</p>";}
      elsif($r->curation_status() eq "review"){$cur_char = "<p style=\"color:blue\">Marked for Review</p>";}

	push @data, ["<a href=\"/smid/".$r->compound_id()."\">".$r->smid_id()."</a>", $r->formula(), $r->molecular_weight(), $cur_char ];
    }

    $c->stash->{rest} = { data => \@data };
}


#Inserting a subroutine for the curator interface. At first, it will be a clone of the browse tab.
sub curator : Chained('rest') PathPart('curator') Args(0) {
  my ($self, $c) = @_;

  if (! $c->user() || $c->user()->get_object()->user_type() ne "curator") {
$c->stash->{rest} = { error => "Curator login required to access curation tool." };
return;
  }

  print STDERR "found rest/curator...\n";

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search({}, { order_by => { -asc => 'smid_id'}});
  my @data;
  while (my $r = $rs->next()) {

    my $button = "<button id=\"unverify_".$r->compound_id()."\" onclick=\"mark_smid_for_review(".$r->compound_id().")\" type=\"button\" class=\"btn btn-primary\">Mark for Review</button>";
    my $cur_status = "<p style=\"color:green\"><b>\x{2713}</b></p>";
    my $disabled = "";
    my $advice = "Approve and Curate";
    my @missing;

    my $hplcexperiments = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->search({compound_id => $r->compound_id(), experiment_type => "hplc_ms"});
    my $msmsexperiments = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->search({compound_id => $r->compound_id(), experiment_type => "ms_spectrum"});

    if (!$r->organisms()){push(@missing, "organisms");}
    if (!$r->formula()){push(@missing, "Molecular Formula");}
    if (!$r->smid_id()){push(@missing, "SMID ID");}
    # ...requirement for HPLC-MS and MS/MS data
    if (!$hplcexperiments->next()){push(@missing, "HPLC-MS Data");}
    if (!$msmsexperiments->next()){push(@missing, "MS/MS Data");}

    my $missinglist = "(Missing: ";
    $missinglist .= join(", ", @missing);
    $missinglist .= ")";
    if ($missinglist eq "(Missing: )"){$missinglist = "";} else {$advice = "Curation not Reccommended"; $disabled = "disabled";}

    if(!defined($r->curation_status()) || $r->curation_status() eq "unverified"){
      $cur_status = "<p style=\"color:red\">Unverified $missinglist </p>";
      $button = "<button id=\"curate_".$r->compound_id()."\" onclick=\"curate_smid(".$r->compound_id().")\" type=\"button\" class=\"btn btn-primary\" $disabled>$advice</button>";
    }
    elsif($r->curation_status() eq "review"){
      $cur_status = "<p style=\"color:blue\">Marked for Review $missinglist </p> ";
      $button = "<button id=\"curate_".$r->compound_id()."\" onclick=\"curate_smid(".$r->compound_id().")\" type=\"button\" class=\"btn btn-primary\" $disabled>$advice</button>";
    }

push @data, [ $r->compound_id(), "<a href=\"/smid/".$r->compound_id()."\">".$r->smid_id()."</a>", $r->formula(), $r->smiles(), $button, $cur_status];
  }

  $c->stash->{rest} = { data => \@data };

}

#If I am correct, this subroutine formats the data, while the above subroutine collects the data
sub curator_format :Chained('rest') PathPart('curator') Args(1) {
    my $self = shift;
    my $c = shift;
    my $format = shift;

    if (! $c->user() || $c->user()->get_object()->user_type() ne "curator") {
  $c->stash->{rest} = { error => "Curator login required to access curation tool." };
  return;
    }

    $self->curator($c);

    if ($format eq "html") {

      print STDERR "found the curator html...\n";

	     my $html = "<table border=\"1\" width=\"100%\" cellpadding=\"10\" >\n
	      <thead><th>SMID ID</th><th>Formula</th><th>SMILES</th><th><a width=\"50\"></a>Status</th></thead>\n";

	     foreach my $smid (@{$c->stash->{rest}->{data}}) {
	        $html .= "<tr><td><a href=\"/smid/$smid->[0]\">$smid->[1]</a></td><td>$smid->[2]</td><td>$smid->[3]</td><td><button id=\"curate_smid".$smid->compound_id()."\" disabled=\"false\" class=\"btn btn-primary\">Approve and Curate</button></td></tr>\n";
	       }
	     $html .= "</table>\n";

	     $c->stash->{rest} = { html => $html };
    }

    if ($format eq "datatable") {
	    #...
      print STDERR "found the curator data...\n";

      my @data = $c->stash->{rest}->{data};
    }
}

sub browse_format :Chained('rest') PathPart('browse') Args(1) {
    my $self = shift;
    my $c = shift;
    my $format = shift;

    $self->browse($c);

    if ($format eq "html") {
	my $html = "<table border=\"1\" width=\"100%\" cellpadding=\"10\" >\n
	<thead><th>SMID ID</th><th>Formula</th><th>SMILES</th></thead>\n";

	foreach my $smid (@{$c->stash->{rest}->{data}}) {
	    $html .= "<tr><td><a href=\"/smid/$smid->[0]\">$smid->[1]</a></td><td>$smid->[2]</td><td>$smid->[3]</td></tr>\n";
	}
	$html .= "</table>\n";

	$c->stash->{rest} = { html => $html };
    }

    if ($format eq "datatable") {
	#...

  print STDERR "found the browse data...\n";

  my @data = $c->stash->{rest}->{data};
    }


}

sub clean {
    my $self = shift;
    my $str = shift;

    # remove script tags
    $str =~ s/\<script\>//gi;
    $str =~ s/\<\/script\>//gi;

    return $str;
}


sub store :Chained('rest') PathPart('smid/store') Args(0) {
    my $self  = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "Login required for updating SMIDs." };
	return;
    }

    my $user_id = $c->user()->get_object()->dbuser_id();

    my $smid_id = $self->clean($c->req->param("smid_id"));
    my $iupac_name = $self->clean($c->req->param("iupac_name"));
    my $smiles_string = $self->clean($c->req->param("smiles_string"));
    my $formula = $self->clean($c->req->param("formula"));
    my $organisms = $self->clean($c->req->param("organisms"));
    my $description = $self->clean($c->req->param("description"));
    my $synonyms = $self->clean($c->req->param("synonyms"));
    my $curation_status = $self->clean($c->req->param("curation_status"));
    my $doi = $self->clean($c->req->param("doi"));

    my $molecular_weight = Chemistry::MolecularMass::molecular_mass($formula);

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
	doi => $doi,
	iupac_name => $iupac_name,
	curation_status => $curation_status,
	dbuser_id => $user_id,
	description => $description,
	synonyms => $synonyms,
	create_date => 'now()',
	molecular_weight => $molecular_weight,
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

sub delete_smid :Chained('smid') PathPart('delete') Args(0) {
    my $self = shift;
    my $c = shift;

    print STDERR "DELETE SMID: ".$c->stash->{compound_id}." role = ".$c->user()->check_roles("curator")."\n";
    
    my $error = "";
    
    if ( ($c->user()) && ($c->user()->check_roles("curator"))) {

	print STDERR "Deleting compound with id $c->stash->{compound_id} and associated metadata...\n";
	
	my $exp_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->search( { compound_id => $c->stash->{compound_id} });

	while (my $exp = $exp_rs->next()) { 
	    $exp->delete();
	}

	my $image_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::CompoundImage")->search( { compound_id => $c->stash->{compound_id} });
	while (my $image = $image_rs->next()) {
	    $image->delete();
	}

	my $dbxref_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::CompoundDbxref")->search( { compound_id => $c->stash->{compound_id} });

	while (my $dbxref = $dbxref_rs->next()) {
	    $dbxref->delete();
	}

	my $compound_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search( { compound_id => $c->stash->{compound_id} });
	while (my $compound = $compound_rs->next()) {
	    $compound->delete();
	}

    }
    else {
	$error = "Not enough privileges to delete a compound.";
    }

    if ($error) {
	$c->stash->{rest} = { error => $error };
    }

    else {
	$c->stash->{rest} = { success => 1 };
    }
    

}


#This is where the backend function will go to curate a smid. Use buttons modeled on smid_detail.js for help
#Note that this function will both curate a smid and mark it as unverified depending on the parameters sent!

sub curate_smid :Chained('smid') PathPart('curate_smid') Args(0){

    my $self = shift;
    my $c = shift;

    if (! $c->user() || $c->user()->get_object()->user_type() ne "curator") {
  $c->stash->{rest} = { error => "Curator login required to verify a SMID." };
  return;
    }

    my $curation_status = $self->clean($c->req->param("curation_status"));
    my $compound_id = $c->stash->{compound_id};
    my $curator_id = $c->user()->get_object()->dbuser_id();
    my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $compound_id} );

      if (!$row){
        $c->stash->{rest} = { error => "The SMID with id $compound_id does not exist." };
      	return;
      }

      my $smid_id = $row->smid_id();

       my $data = {
  	 smid_id => $smid_id,

  	 curation_status => $curation_status,

  	 last_modified_date => 'now()',

     last_curated_time => 'now()',

     curator_id => $curator_id
       };

      eval{
        $row->update($data);
      };

      $c->stash->{rest} ={
  	message => "Successfully updated the curation status of smid $smid_id"
      };

    print STDERR "Smid ".$smid_id." curation status updated to $curation_status\n";
    return;
}


sub mark_for_review : Chained('smid') PathPart('mark_for_review') Args(0) {

  my $self = shift;
  my $c = shift;

  if(! $c->user()){
    $c->stash->{rest} = {error => "Must be logged in to request a review of a smid."};
    return;
  }

  my $curation_status = $self->clean($c->req->param("curation_status"));
  my $compound_id = $c->stash->{compound_id};
  my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $compound_id} );

    if (!$row){
      $c->stash->{rest} = { error => "The SMID with id $compound_id does not exist." };
      return;
    }

    my $smid_id = $row->smid_id();

     my $data = {
   smid_id => $smid_id,
   curation_status => $curation_status,
   last_modified_date => 'now()'
     };

    eval{
      $row->update($data);
    };

    $c->stash->{rest} ={
  message => "Successfully updated the curation status of smid $smid_id"
    };

  print STDERR "Smid ".$smid_id." curation status updated to $curation_status\n";
  return;
}

sub mark_unverified :Chained('smid') PathPart('mark_unverified') Args(0){

    my $self = shift;
    my $c = shift;

    if (! $c->user() || $c->user()->get_object()->user_type() ne "curator") {
  $c->stash->{rest} = { error => "Curator login required to verify a SMID." };
  return;
    }

    my $curation_status = $self->clean($c->req->param("curation_status"));
    my $compound_id = $c->stash->{compound_id};
    my $curator_id = $c->user()->get_object()->dbuser_id();
    my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $compound_id} );

      if (!$row){
        $c->stash->{rest} = { error => "The SMID with id $compound_id does not exist." };
      	return;
      }

      my $smid_id = $row->smid_id();

       my $data = {
  	 smid_id => $smid_id,

  	 curation_status => $curation_status,

  	 last_modified_date => 'now()',

     last_curated_time => 'now()',

     curator_id => $curator_id
       };

      eval{
        $row->update($data);
      };

      $c->stash->{rest} ={
  	message => "Successfully updated the curation status of smid $smid_id"
      };

    print STDERR "Smid ".$smid_id." curation status updated to $curation_status\n";
    return;
}

sub update :Chained('smid') PathPart('update') Args(0) {
    my $self = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "Login required for updating SMIDs." };
	return;
    }

    my $compound_id = $c->stash->{compound_id};
    my $smid_row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $compound_id } );

    if (! $smid_row) {
	$c->stash->{rest} = { error => "The SMID with id $compound_id does not exist." };
	return;
    }

    my $user_id = $c->user()->get_object()->dbuser_id();
    my $smid_owner_id = $smid_row->dbuser_id();


    if ( ($user_id != $smid_owner_id) && ($c->user->get_object()->user_type() ne "curator") )  {
	$c->stash->{rest} = { error => "The SMID with id $compound_id is (owned by $smid_owner_id) not owned by you ($user_id) and you cannot modify it." };
	return;
    }

    my $smid_id = $self->clean($c->req->param("smid_id"));
    my $smiles_string = $self->clean($c->req->param("smiles_string"));
    my $formula = $self->clean($c->req->param("formula"));
    my $organisms = $self->clean($c->req->param("organisms"));
    my $iupac_name = $self->clean($c->req->param("iupac_name"));
    my $curation_status = $self->clean($c->req->param("curation_status"));
    my $synonyms = $self->clean($c->req->param("synonyms"));
    my $description = $self->clean($c->req->param("description"));
    my $molecular_weight= Chemistry::MolecularMass::molecular_mass($formula);
    my $doi = $self->clean($c->req->param("doi"));

    my $errors = "";
    if (!$compound_id) {  $errors .= "Need compound id. "; }
    if (!$iupac_name) { $errors .= "Need IUPAC name. "; }
    if (!$smid_id) { $errors .= "Need smid id. "; }
    #if (!$smiles_string) { $errors .= "Need smiles_string. "; }
    if (!$formula) { $errors .= "Need formula. "; }

    if (my $smiles_error = $self->check_smiles($smiles_string)) {
	$errors .= $smiles_error;
    }

    if ($errors) {
	$c->stash->{rest} = { error => $errors };
	return;
    }

    my $data = {
	smid_id => $smid_id,
	formula => $formula,
	smiles => $smiles_string,
	organisms => $organisms,
	doi => $doi,
	iupac_name => $iupac_name,
	curation_status => $curation_status,
	description => $description,
	synonyms => $synonyms,
	molecular_weight => $molecular_weight,
	last_modified_date => 'now()',
    };

    eval {
	$smid_row->update($data);
    };

    if ($@) {
	$c->stash->{rest} = { error => "Sorry, an error occurred storing the smid ($@)" };
	return;
    }

    $c->stash->{rest} ={
	compound_id => $compound_id,
	message => "Successfully stored the smid $smid_id"
    };

}

sub check_smiles {
    my $self = shift;
    my $smiles = shift;

    eval {
	Chemistry::Mol->parse($smiles, format => 'smiles');
    };

    my $error;
    if ($@) {
	$error = $@;
    }

    return $error;
}



sub detail :Chained('smid') PathPart('details') Args(0) {
    my $self = shift;
    my $c = shift;

    my $s = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $c->stash->{compound_id} }, { join => "dbuser" } );

    if (! $s) {
	$c->stash->{rest} = { error => "Can't find smid with id ".$c->stash->{compound_id}."\n" };
	return;
    }

    my $data;
    $data->{smid_id} = $s->smid_id();
    $data->{compound_id} = $s->compound_id();
    $data->{formula}= $s->formula();
    $data->{organisms} = $s->organisms();
    $data->{doi} = $s->doi();
    $data->{iupac_name} = $s->iupac_name();
    $data->{smiles_string} = $s->smiles();
    $data->{curation_status} = $s->curation_status();
    $data->{last_modified_date} = $s->last_modified_date();
    $data->{create_date} = $s->create_date();
    $data->{curator_id} = $s->curator_id();
    $data->{last_curated_time} = $s->last_curated_time();
    $data->{description} = $s->description();
    $data->{synonyms} = $s->synonyms();
    $data->{molecular_weight} = $s->molecular_weight();

    if (! $s->dbuser()) {
	$data->{author} = "unknown";
    }
    else { 
	$data->{author} = $s->dbuser->first_name()." ".$s->dbuser->last_name();
    }
    $c->stash->{rest} = { data => $data };

    print STDERR "Found smid details...\n";
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

    while (my $dbxref = $rs->next()) {
	print STDERR "Retrieved: ". $dbxref->dbxref_id()."...\n";

	my $db_name = "";
	my $display_url = "";

	if ($dbxref->db()) {
	    $db_name = $dbxref->db->name();
	    my $url = $dbxref->db->url();
	    my $urlprefix = $dbxref->db->urlprefix();
	    $display_url = join("",  $urlprefix, $url, $dbxref->accession());
	}

	my $delete_link = "X";

	if ($c->user()) {
	    $delete_link = "<a href=\"javascript:delete_dbxref(".$dbxref->dbxref_id().")\" ><font color=\"red\">X</font></a>";
	}
	push @$data, [ $db_name, $dbxref->accession(), $display_url , $delete_link ];
    }
    $c->stash->{rest} = { data => $data };
}

sub results : Chained('smid') PathPart('results') Args(0) {
    my $self = shift;
    my $c = shift;

    my $experiment_type = $c->req->param("experiment_type");

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->search( { compound_id => $c->stash->{compound_id}, experiment_type => $experiment_type } );

    print STDERR "Retrieved ".$rs->count()." rows...\n";
    my @data;

    my $delete_link = "X";
    while (my $row = $rs->next()) {
	my $experiment_id = $row->experiment_id();
	if ($c->user()) {
	    $delete_link = "<a href=\"javascript:delete_experiment($experiment_id)\"><font color=\"red\">X</font></a>";
	}

	if ($experiment_type eq "hplc_ms") {
	    my $json = $row->data();
	    my $hash = JSON::XS->new()->decode($json);
	    push @data, [ $hash->{hplc_ms_author}, $hash->{hplc_ms_method_type}, $hash->{hplc_ms_retention_time}, $hash->{hplc_ms_ionization_mode}, $hash->{hplc_ms_adducts_detected}, $hash->{hplc_ms_scan_number}, $hash->{hplc_ms_link}, $delete_link ];
	}
	if ($experiment_type eq "ms_spectrum") {
	    my $json = $row->data();
	    my $hash = JSON::XS->new()->decode($json);
	    push @data, [ $hash->{ms_spectrum_author}, $hash->{ms_spectrum_ionization_mode}, $hash->{ms_spectrum_collision_energy}, $hash->{ms_spectrum_adduct_fragmented}, "<a href=\"/experiment/".$row->experiment_id()."\">Details</a>", $hash->{ms_spectrum_link},  $delete_link ];
	}
    }

    $c->stash->{rest} = { data => \@data };
}


sub compound_images :Chained('smid') PathPart('images') Args(1) {
    my $self = shift;
    my $c = shift;
    my $size = shift;

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::CompoundImage")->search( { compound_id => $c->stash->{compound_id} });

    my @source_tags;
    while (my $row = $rs->next()) {
	my $image = SMMID::Image->new( { schema => $c->model("SMIDDB"), image_id => $row->image_id() });

	my $delete_link = "";
	if ($c->user()) {
	    $delete_link = "<a href=\"javascript:delete_image(".$row->image_id().", ".$c->stash->{compound_id}.")\">X</a>";
	}


	my $file = "medium";
	if ($size =~ m/thumbnail|small|medium|large/) { $file = $size.".png"; }
	my $image_full_url =  "/".$c->config->{image_url}."/".$image->image_subpath()."/".$file;
	push @source_tags, "<img src=\"$image_full_url\" />$delete_link";
    }
    print STDERR "returning images for compound ".$c->stash->{compound_id} ." with size $size.\n";
    $c->stash->{rest} = { html => \@source_tags };
}

=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
