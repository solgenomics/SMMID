
package SMMID::Controller::REST::Results;

use Moose;

use JSON::Any;

BEGIN { extends 'Catalyst::Controller::REST' };

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );



# this experiment store function uses a simplified data model consisting just of
# the experiment table with a data jsonb field that stores the results. The result table
# is not used.
#
sub store_experiment :Path('/rest/experiment/store') Args(0) {
    my $self = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "You need to be logged in to store Dbxrefs." };
	return;
    }

    my $user_id = $c->user()->get_object()->dbuser_id();
    
    my $params = $c->req->params();

    print STDERR "Storing data... :-) ...\n";
    my $data;

    my $description = "";
    
    if ($params->{experiment_type} eq "hplc_ms") {
	$data->{hplc_ms_author} = $params->{hplc_ms_author};
	$data->{hplc_ms_method_type} = $params->{hplc_ms_method_type};
	$data->{hplc_ms_retention_time} = $params->{hplc_ms_retention_time};
	$data->{hplc_ms_ionization_mode} = $params->{hplc_ms_ionization_mode};
	$data->{hplc_ms_adducts_detected} = $params->{hplc_ms_adducts_detected};
	$data->{hplc_ms_scan_number} = $params->{hplc_ms_scan_number};
	$data->{hplc_ms_link} = $params->{hplc_ms_link};
	$description = $params->{hplc_ms_description};
    }

    if ($params->{experiment_type} eq "ms_spectrum") {
	$data->{ms_spectrum_author} = $params->{ms_spectrum_author};
	$data->{ms_spectrum_ionization_mode} = $params->{ms_spectrum_ionization_mode};
	$data->{ms_spectrum_adduct_fragmented} = $params->{ms_spectrum_adduct_fragmented};
	$data->{ms_spectrum_collision_energy} = $params->{ms_spectrum_collision_energy};
	$data->{ms_spectrum_mz_intensity} = $params->{ms_spectrum_mz_intensity};
	$data->{ms_spectrum_link} = $params->{ms_spectrum_author};
	$description = $params->{ms_spectrum_description};
    }

    my $data_json = JSON::Any->encode($data);

    my $experiment_data = {
	compound_id => $params->{compound_id},
	description => $description,
	experiment_type => $params->{experiment_type},
	create_date => 'now()',
	dbuser_id => $user_id,
	operator => $params->{operator},
	data => $data_json,
    };

    eval {
	print STDERR "Inserting row...\n";
	my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->create($experiment_data);
	print STDERR "INSERTED ".$row->experiment_id()."\n";
    };
    
    if ($@) {
	$c->stash->{rest} = { error => "An error occurred! ($@)" }; 
	return;
    }

    $c->stash->{rest} = { success => 1 };
}


"SMMID::Controller::REST::Results";
