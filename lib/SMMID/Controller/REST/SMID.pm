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

SMMID::Controller::Compound - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;

    #$c->response->body('Matched SMMID::Controller::Compound in Compound.');
#}



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



sub compound :Chained('rest') PathPart('compound') CaptureArgs(1) {
    my $self = shift;
    my $c = shift;

    my $smid_id = shift;

    $c->stash->{smid_id} = $smid_id;
}

#sub create_smid {
 #   my $self = shift;
  #  my $c = shift;
   # $c->stash->{template} = 
#}


sub detail :Chained('compound') PathPart('details') Args(0) {
    my $self = shift;
    my $c = shift;

    my $s = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->find( { compound_id => $c->stash->{smid_id} });

    if (! $s) {
	$c->stash->{rest} = { error => "Can't find smid with id ".$c->stash->{smid_id}."\n" };
	return;
    }

    my $data;
    $data->{smid_id} = $s->smid_id();
    $data->{compound_id} = $s->compound_id();
    $data->{formula}= $s->formula();
    #$data->{synonyms} = $s->synonyms();
    #$data->{molecular_weight} = $s->molecular_weight();
    $data->{SMILES} = $s->smiles();
    $data->{curation_status} = $s->curation_status();

    #my $formatted_formula= $s->get_molecular_formula();
    #$formatted_formula=~s/(\d+)/\<sub\>$1\<\/sub\>/g;
    #print STDERR "FORMATTED FORMULA = $formatted_formula\n";

    $c->stash->{rest} = { data => $data };

}


sub compound_dbxref :Chained('compound') PathPart('dbxrefs') Args(0) {
    my $self = shift;
    my $c = shift;

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbxref")->search(  { 'compound_dbxrefs.compound_id' => $c->stash->{smid_id} }, { join => 'compound_dbxrefs' , { join => 'db'  }});

    my $data = undef;
    
    while (my $dbxref = $rs->next()) {
	print STDERR "Retrieved: ". $dbxref->dbxref_id()."...\n";
	push @$data, [ $dbxref->db->name(), $dbxref->accession(), join("",  $dbxref->db->urlprefix(), $dbxref->db->url(), $dbxref->accession()) ];
    }
    $c->stash->{rest} = { data => $data};
}

sub compound_results : Chained('detail') PathPart('results') Args(0) {
    my $self = shift;
    my $c = shift;

    $c->stash->{rest} = { data => "soon" };
}

=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
