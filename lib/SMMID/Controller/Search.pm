
package SMMID::Controller::Search;

use Moose;
use Data::Dumper;
use JSON::XS;

BEGIN { extends 'Catalyst::Controller'; }

sub search : Path('/search') Args(0) {
    my $self = shift;
    my $c = shift;

    my $search_term = $c->req->param("term");
    my $retention_time = $c->req->param("retention_time");
    my $retention_time_range = $c->req->param("retention_time_range");
    my $molecular_weight = $c->req->param("molecular_weight");
    my $molecular_weight_range = $c->req->param("molecular_weight_range");

    

    
    my $rs = $c->model('SMIDDB')->resultset("SMIDDB::Result::Compound")->search( { -or => [ smid_id => { ilike => '%'.$search_term.'%' }, formula => { ilike => '%'.$search_term.'%'}, smiles => { ilike => '%'.$search_term.'%' } ] });

    my @results;
    while (my $row = $rs->next()) {
	my $compound_id = $row->compound_id();
	my $smid_id = $row->smid_id();
	my $formula = $row->formula();
	my $smiles = $row->smiles();

	my $smid_link = '<a href=\"/smid/'.$compound_id.'\">'.$smid_id."</a>";
	push @results, [ $smid_link, $formula, $smiles ];

    }
    

    print STDERR Dumper(\@results);
  
    $c->stash->{data} = encode_json(\@results);

    print STDERR "JSON: ".$c->stash->{data}."\n";
    
    $c->stash->{template} = '/search/results.mas';

}


1;
