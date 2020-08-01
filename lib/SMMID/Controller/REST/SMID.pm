package SMMID::Controller::REST::SMID;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST' };

use Data::Dumper;

=head1 NAME

SMMID::Controller::Compound - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    #$c->response->body('Matched SMMID::Controller::Compound in Compound.');
}

sub browse :Path('/browse') :Args(0) { 
    my ($self, $c) = @_;

    # generate DataTable here
    

    
}


sub rest : Chained('/') PathPart('rest') CaptureArgs(0) {
}



sub compound :Chained('rest') PathPart('compound') CaptureArgs(1) {
    my $self = shift;
    my $c = shift;

    my $arg = shift;

    if ($arg eq "new") {
	$self->create_smid($c);
    }
    else { 
	$c->stash->{smid_id} = $arg;
    }
}

sub create_smid {
    my $self = shift;
    my $c = shift;

}


sub detail :Chained('compound') PathPart('view') Args(0) {
    my $self = shift;
    my $c = shift;

    my $s = $c->model("SMIDDB")->resultset("compound")->find( { smid_id => $c->stash->{smid_id} });

    if (! $s) {
	$c->stash->{rest} = { error => "Can't find smid with id ".$c->stash->{smid_id}."\n" };
	return;
    }
			      
    $c->stash->{smmid_id} = $s->compound_id();
    $c->stash->{chemical_name}= $s->formula();
    $c->stash->{synonyms} = $s->synonyms();
    $c->stash->{molecular_weight} = $s->molecular_weight();
    $c->stash->{concise_summary} = $s->concise_summary();
    $c->stash->{receptors} = $s->get_receptors();
    @{$c->stash->{receptor_references}} = $s->get_links("RECEPTORS");
    $c->stash->{biosynthesis} = $s->biosynthesis();
    @{$c->stash->{biosynthesis_references}} = $s->links("BIOSYNTHESIS");
    $c->stash->{cas} = $s->get_cas();
    my $formatted_formula= $s->get_molecular_formula();
    $formatted_formula=~s/(\d+)/\<sub\>$1\<\/sub\>/g;
    #print STDERR "FORMATTED FORMULA = $formatted_formula\n";
    $c->stash->{molecular_formula}=$formatted_formula;
    $c->stash->{structure_file}= $c->config->{"smid_structure_dir"}."/".$s->get_structure_file().".png";

    
    @{$c->stash->{links}} = $s->get_links("REFERENCES");

}



=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
