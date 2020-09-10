use utf8;
use strict;
use warnings;

use Getopt::Std;
use SMIDDB;
use YAML;

our($opt_t);

getopts('t');

my $file = shift;


my $smid_id;
my $cas;
my $molecular_formula;
my $synonyms;
my $chemical_name;
my $description;
my $organisms;

binmode(STDOUT, "encoding(UTF-8)");
binmode(STDERR, "encoding(UTF-8)");
my $schema = SMIDDB->connect('dbi:Pg:dbname=smid_db;host=breedbase_db;user=postgres;password=postgres');
$schema->storage->debug(1);

my %dbs;
my $db_rs = $schema->resultset("SMIDDB::Result::Db")->search( { } );
while (my $row = $db_rs->next()) {
    $dbs{$row->name()} = $row->db_id();
    print STDERR $row->name()." ".$row->db_id()."\n";
}

open(my $F, "< :encoding(UTF-8)", $file) || die "Can't open file $file. Sorry.";

while (my $line = <$F>) {
    $line =~ s/\r//g;
    chomp($line);

    if ($line =~ m/(.*?)(\s*)\:\s*(.+$)/) {
	my $tag = $1;
	my $info = $3;

	if ($tag eq "SMMID") {
	    if ($smid_id) {

		if ($opt_t) {
		    print STDERR "WOULD INSERT $smid_id, $cas, $molecular_formula, $synonyms, $chemical_name, $description, $organisms\n";
		    
		}
		else { 
		    my $compound_data= {
			smid_id => $smid_id,
			formula => $molecular_formula,
			synonyms => $synonyms,
			iupac_name => $chemical_name,
			smiles => '[not available]',
			description => $description,
			organisms => $organisms,
		    };
		    
		    print STDERR "Inserting compound... ".YAML::Dump($compound_data);
		    
		    my $compound = $schema->resultset("SMIDDB::Result::Compound")->create($compound_data);
		    		    
		    print STDERR "Inserting Dbxref...\n";
		    if ($cas && ($cas ne "TBD")) { 
			my $dbxref = $schema->resultset("SMIDDB::Result::Dbxref")->create(
			    {
				accession => $cas,
				db_id => $dbs{CAS},
				version => 1,
			    });

					
			print STDERR "Inserting CompoundDbxref..\n";
			my $compound_dbxref = $schema->resultset("SMIDDB::Result::CompoundDbxref")->create(
			    {
				dbxref_id => $dbxref->dbxref_id(),
				compound_id => $compound->compound_id(),
			    });
		    }
		}
	    }
	    # reset smmid

	    print STDERR "Setting smid_id to $info...\n";
	    $smid_id = $info;
	    $description = "";
	    $cas = "";
	    $molecular_formula = "";
	    $synonyms = "";
	    $chemical_name = "";
	    $organisms = "";
	}

	elsif ($tag eq "CAS") {
	    $cas = $info;
	}

	elsif ($tag eq "MOLECULAR FORMULA") {
	    $molecular_formula = $info;
	}

	elsif ($tag eq "SYNONYMS") {
	    $synonyms = $info;
	}

	elsif ($tag eq "CONCISE SUMMARY") {
	    $description = $info;
		
	}

	elsif ($tag eq "CHEMICAL NAME") {
	    $chemical_name = $info;
	}

	elsif ($tag eq "ORGANISM") {
	    $organisms = $info;
	}

	else {
	    print STDERR "Not using: $tag ( $info )\n\n";
	    
	}
    }    
}

print STDERR "Done.\n";


