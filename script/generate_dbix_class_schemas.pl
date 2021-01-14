
use strict;

my $target_dir = shift;
my $username = shift;
my $password = shift;

`/home/production/cxgn/local-lib/bin/dbicdump -o dump_directory=$target_dir  -o debug=1 SMIDDB 'dbi:Pg:dbname=smid_db;host=breedbase_db;user=$username;password=$password' `
    
