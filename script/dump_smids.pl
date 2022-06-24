
use strict;
use Getopt::Std;
use SMIDDB;
use JSON::XS;

our($opt_H, $opt_D, $opt_p);
getopts('H:D:p:');

my $schema = SMIDDB->connect("dbi:Pg:host=$opt_H;dbname=$opt_D;user=postgres;password=$opt_p");

my $rs = $schema->resultset("SMIDDB::Result::Compound")
    ->search(
    {   'me.compound_id' => { '>' => 0 }, 
	'experiments.experiment_type' => 'ms_spectrum'
    },
    { join => 'experiments',
      '+select' => [ 'experiments.data' ],
      '+as' => [ 'data' ]
	  
	  
	  
    }
    );

while (my $row = $rs->next()) {
    my $data_json = $row->get_column('data');
    #    print STDERR $data_json;

    my $data = undef;
    if ($data_json) { 
	$data = JSON::XS->new->decode($data_json);
    }
    
    my $spectrum = $data->{ms_spectrum_mz_intensity};
    my $adduct = $data->{ms_spectrum_adduct_fragmented};

    
    
    print join("\t", $row->smid_id(), $row->smiles(), $adduct)."\n";

    if (ref($spectrum) eq "ARRAY") { 
	foreach my $line (@$spectrum) {
	    print $line;
	}
    }
  



    

}
