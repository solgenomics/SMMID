package SMMID::Controller::REST::SMID;

use Moose;
use utf8;
use Unicode::Normalize;

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

      my $cur_char = "\x{2713}";
      if($r->curation_status() == undef){$cur_char = "Unverified";}

	push @data, [ $r->compound_id(), "<a href=\"/smid/".$r->compound_id()."\">".$r->smid_id()."</a>", $r->formula(), molecular_weight($r->formula()), $cur_char ];
    }

    $c->stash->{rest} = { data => \@data };
}

sub molecular_weight {
  #...
  #The default variable will be used as the chemical Formula
  $_ = shift(@_);

  my %elements = ("H" => 1.01, "C" => 12.01, "O" => 16.0, "N" => 14.01, "P" => 30.97, "S" => 32.06);
  my $weight = 0;

  my @pairs = /([CHONPS][0-9]*)/g;
  foreach my $pair (@pairs){
    if (length($pair)==1){
      $weight += $elements{substr($pair, 0, 1)};
    }else{
      $weight += $elements{substr($pair, 0, 1)}*substr($pair, 1);
    }
  }
  return $weight;
}

#Inserting a subroutine for the curator interface. At first, it will be a clone of the browse tab.
sub curator : Chained('rest') PathPart('curator') Args(0) {
  my ($self, $c) = @_;

  print STDERR "found rest/curator...\n";

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search({curation_status => undef});

  my @data;
  while (my $r = $rs->next()) {
push @data, [ $r->compound_id(), "<a href=\"/smid/".$r->compound_id()."\">".$r->smid_id()."</a>", $r->formula(), $r->smiles(), "<button id=\"curate_smid\" disabled=\"false\" class=\"btn btn-primary\">Approve and Curate</button>"];
  }

  $c->stash->{rest} = { data => \@data };

}

#If I am correct, this subroutine formats the data, while the above subroutine collects the data
sub curator_format :Chained('rest') PathPart('curator') Args(1) {
    my $self = shift;
    my $c = shift;
    my $format = shift;

    $self->curator($c);

    if ($format eq "html") {

      print STDERR "found the curator html...\n";

	     my $html = "<table border=\"1\" width=\"100%\" cellpadding=\"10\" >\n
	      <thead><th>SMID ID</th><th>Formula</th><th>SMILES</th><th><a width=\"50\"></a>Status</th></thead>\n";

	     foreach my $smid (@{$c->stash->{rest}->{data}}) {
	        $html .= "<tr><td><a href=\"/smid/$smid->[0]\">$smid->[1]</a></td><td>$smid->[2]</td><td>$smid->[3]</td><td><button id=\"curate_smid\" disabled=\"false\" class=\"btn btn-primary\">Approve and Curate</button></td></tr>\n";
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
  #my @cols = ["{title: \"Compound ID\"}\n", "{title: \"SMID ID\"}\n", "{title: \"Formula\"}\n", "{title: \"SMILES\"}\n", "{title: \"Curation Status\"}\n"];
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

    print STDERR "IUPAC name = $iupac_name\n";
    my $smiles_string = $self->clean($c->req->param("smiles_string"));

    print STDERR "SMILES = $smiles_string\n";
    
    my $formula = $self->clean($c->req->param("formula"));
    my $organisms = $self->clean($c->req->param("organisms"));
    my $description = $self->clean($c->req->param("description"));
    my $synonyms = $self->clean($c->req->param("synonyms"));
    my $curation_status = $self->clean($c->req->param("curation_status"));

    my $molecular_weight = molecular_weight($formula);
    
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
    my $molecular_weight = molecular_weight($formula);
    
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
    $data->{description} = $s->description();
    $data->{synonyms} = $s->synonyms();
    $data->{molecular_weight} = $s->molecular_weight();

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
	    my $hash = JSON::Any->decode($json);
	    push @data, [ $hash->{hplc_ms_author}, $hash->{hplc_ms_method_type}, $hash->{hplc_ms_retention_time}, $hash->{hplc_ms_ionization_mode}, $hash->{hplc_ms_adducts_detected}, $hash->{hplc_ms_scan_number}, $hash->{hplc_ms_link}, $delete_link ];
	}
	if ($experiment_type eq "ms_spectrum") {
	    my $json = $row->data();
	    my $hash = JSON::Any->decode($json);
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
