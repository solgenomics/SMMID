
package SMMID::Controller::Search;

use Moose;
use Data::Dumper;
use JSON::XS;

BEGIN { extends 'Catalyst::Controller'; }

sub search : Path('/search') Args(0) {
    my $self = shift;
    my $c = shift;

    $c->stash->{template} = '/search.mas';
}

sub search_results :Path('/search/results') Args(0) {
    my $self = shift;
    my $c = shift;
	
    my $search_term = $c->req->param("term");
    my $smid_id = $c->req->param("smid_id");
    my $formula = $c->req->param("formula");
    my $retention_time = $c->req->param("retention_time");
    my $retention_time_range = $c->req->param("retention_time_range");
    my $molecular_weight = $c->req->param("molecular_weight");
    my $molecular_weight_range = $c->req->param("molecular_weight_range") || 0;
    my $smiles = $c->req->param('smiles');

    my $rs;
    if ($search_term) { # simple search
	print STDERR "Searching simple search with search term '$search_term'\n";
	$rs = $c->model('SMIDDB')->resultset("SMIDDB::Result::Compound")->search( { -or => [ smid_id => { ilike => '%'.$search_term.'%' }, formula => { ilike => '%'.$search_term.'%'}, smiles => { ilike => '%'.$search_term.'%' } ] } );
	
    }
    else {
	print STDERR "Complex search...\n";
	$rs = $c->model('SMIDDB')->resultset("SMIDDB::Result::Compound")->search( {}, { join => 'experiments'}  );

	print STDERR "Currently matched ".$rs->count()." smids...\n";

	if ($smid_id) { 
	    $rs = $rs->search( { smid_id => { ilike => '%'.$smid_id.'%' }} );
	    print STDERR "With parameter smid_id = $smid_id matched ".$rs->count()." smids...\n";
	    
	}
	if ($formula) {
	    $rs = $rs->search( { formula => { ilike => '%'.$formula.'%'} });
	    print STDERR "Currently matched ".$rs->count()." smids...\n";

	}
	if ($smiles) {
	    $rs = $rs->search( { smiles => { ilike => '%'.$smiles.'%' } });
	    print STDERR "Currently matched ".$rs->count()." smids...\n";

	}

	if ($molecular_weight) {
	    $rs = $rs->search(
		{ -and => [ molecular_weight => { '>' =>  ($molecular_weight - $molecular_weight_range) },
			    molecular_weight => { '<' => ($molecular_weight + $molecular_weight_range) } ] }  );
	    print STDERR "after MW currently matched ".$rs->count()." smids...\n";    
	}
	
	if ($retention_time) {


	}
    }
	
    my @results;
    while (my $row = $rs->next()) {
	my $compound_id = $row->compound_id();
	my $smid_id = $row->smid_id();
	my $formula = $row->formula();
	my $smiles = $row->smiles();

	my $smid_link = '<a href=\"/smid/'.$compound_id.'\">'.$smid_id."</a>";
	push @results, [ $smid_link, $formula, $smiles ];

    }
    

    #print STDERR Dumper(\@results);
  
    $c->stash->{data} = encode_json(\@results);

    #print STDERR "JSON: ".$c->stash->{data}."\n";
    
    $c->stash->{template} = '/search/results.mas';

}


1;
