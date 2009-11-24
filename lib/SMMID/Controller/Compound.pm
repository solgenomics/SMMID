package SMMID::Controller::Compound;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use SMMID;

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

    my @all_smmids = SMMIDDb->all_smmids($c->path_to("root", "static", "data", "SMMID_list.txt"));
    
    print STDERR "NOW DEALING WITH REQUEST...\n";
    foreach my $s (@all_smmids) { print STDERR "SMMID: ".$s->get_smmid()."\n"; }
    $c->stash->{all_smmids} = \@all_smmids;

    $c->stash->{example_array} = [ 0..50 ];

    
}

sub detail :Path('/detail') {
    my ($self , $c, $smmid) = @_;

    my $file = $c->path_to("root", "static", "data", "SMMID_list.txt");
    my $s = SMMIDDb->new($file, $smmid);

    $c->stash->{smmid}=$s->get_smmid();
    $c->stash->{name}=$s->get_name();
    $c->stash->{synonyms} = $s->get_synonyms();
    $c->stash->{molecular_weight}=$s->get_molecular_weight();
    my $formatted_formula=$s->get_molecular_formula();
    $formatted_formula=~s/(\d+)/\<sub\>$1\<\/sub\>/g;
    print STDERR "FORMATTED FORMULA = $formatted_formula\n";
    $c->stash->{molecular_formula}=$formatted_formula;
    $c->stash->{structure_file}= '/static/structures/'.$s->get_structure_file().".gif";

    
    @{$c->stash->{links}} = $s->get_links();

}



=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
