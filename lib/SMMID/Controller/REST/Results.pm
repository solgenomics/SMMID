
package SMMID::Controller::REST::Results;

use Moose;

use JSON::XS;

use Data::Dumper;

use SMMID::Authentication::ViewPermission;

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

    my $data_json = JSON::XS->new()->encode($data);

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
	print STDERR "Storing Experiment for compound $params->{compound_id} $params->{experiment_type}, $description...\n";
	my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->create($experiment_data);
    };

    if ($@) {
	print STDERR "An error occurred storing the experiment.\n";
	$c->stash->{rest} = { error => "An error occurred! ($@)" };
	return;
    }


    $c->stash->{rest} = { message => "Successfully stored experimental results.", success => 1 };
}

sub experiment :Chained('/') :PathPart('rest/experiment') CaptureArgs(1) {
    my $self = shift;
    my $c = shift;

    my $experiment_id = shift;

    my $experiment = $c->model('SMIDDB')->resultset("SMIDDB::Result::Experiment")->find( { experiment_id => $experiment_id } );
    my $smid = $c->model("SMIDDB")->resultset('SMIDDB::Result::Compound')->find({compound_id => $experiment->compound_id()});

    if (!SMMID::Authentication::ViewPermission::can_view_smid($c, $smid)) {
      $c->stash->{rest} = {error => "You do not have permission to view this experiment!"};
      return;
    }

    $c->stash->{experiment} = $experiment;
    $c->stash->{experiment_id} = $experiment_id;


}

sub experiment_detail :Chained('experiment') :PathPart('') Args(0) {
    my $self = shift;
    my $c = shift;

    my $experiment = $c->stash->{experiment};

    ## to do: provide link to compound...

    if (!$experiment) {
	$c->stash->{rest} = { error => "No such experiment." };
	return;
    }


    print STDERR "EXP = $experiment\n";
    my $data_json = $experiment->data();

    my $data = JSON::XS->new()->decode($data_json);

    print STDERR "Data = $data\n";
    $data->{experiment_type} = $experiment->experiment_type();
    $data->{description} = $experiment->description();


    if ($data->{experiment_type} eq "ms_spectrum") {
	my $spectrum_html = "<table border=\"1\">";
	my @spectrum = split /\n/, $data->{ms_spectrum_mz_intensity};
	foreach my $line (@spectrum) {
	    $spectrum_html .= "<tr><td>";
	    $spectrum_html .= join "</td><td>", split /\t/, $line;
	    $spectrum_html .= "</td></tr>";
	}
	$spectrum_html .= "</table>";
	$data->{ms_spectrum_mz_intensity} = $spectrum_html;
    }

    $c->stash->{rest} = { data => $data };
}

sub msms_visual_data : Chained('experiment') PathPart('msms_spectrum') Args(0){
  #Collect, sort, and return data in much the same way as the subroutine above this owned


  print STDERR "Found visualizer!\n";

  my $self = shift;
  my $c = shift;

  my $experiment = $c->stash->{experiment};

  if (!$experiment) {
    $c->stash->{rest} = { error => "No such experiment." };
    return;
  }

  my $data_json = $experiment->data();

  my $data = JSON::XS->new()->decode($data_json);

  #The data collected above needs to be formatted. It will be sorted according to 'x' value, with 'y' and 'ry' values accompanied.
  #The data will be scaled in javascript, local to the place where it is displayed (this is to make sure no time is wasted shuttling data
  #back and forth between the website and here)

    my @spectrum = split /\n/, $data->{ms_spectrum_mz_intensity};
    my @return_spec;
    foreach my $line (@spectrum){
      no strict;
      my @split = split(/\t/, $line);
      push(@return_spec, [$split[0] + 0.0, $split[1] + 0.0, $split[2] + 0.0]);
    }

    print STDERR "++++++++++++++++++++++++++++++++++++++++\n";


    my @return_spec_sorted = sort { $a->[0] <=> $b->[0]}@return_spec;

    #$data = @return_spec_sorted;

   $c->stash->{rest} = { data => \@return_spec_sorted};

}

sub experiment_mz_data : Chained('experiment') :PathPart('mz_data') Args(0) {
    my $self = shift;
    my $c = shift;

    my $data_json = $c->stash->{experiment}->data();

    my $data = JSON::XS->new()->decode($data_json);

    $c->stash->{rest} =  { data => $data->{ms_spectrum_mz_intensity} };
}

sub delete_experiment : Chained('experiment') :PathPart('delete') Args(0) {
    my $self = shift;
    my $c = shift;

    my $experiment_type = $c->stash->{experiment}->experiment_type();
    if ($c->user() && ($c->user->get_object()->dbuser_id() == $c->stash->{experiment}->dbuser_id()) || $c->user()->user_type() eq "curator") {
	$c->stash->{experiment}->delete();
	$c->stash->{rest} = { message => "Successfully deleted experiment.", success => 1, experiment_type => $experiment_type  };
    }
    else {
	$c->stash->{error} = { error => "You don't have the required privileges to delete this entry." };
    }
}

sub get_compound_id_from_experiment : Chained('experiment') Pathpart('get_compound_id_from_experiment') Args(0) {
  my $self = shift;
  my $c = shift;

  my $experiment = $c->stash->{experiment};

  my $compound_id = $experiment->compound_id();

  $c->stash->{rest} = {data => $compound_id};
}



"SMMID::Controller::REST::Results";
