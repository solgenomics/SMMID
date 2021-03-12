
use strict;

package dbpatch;

use Moose;

extends 'Dbpatch::PatchRoot';

my $dbpatch = dbpatch->new_with_options();

$dbpatch->run();




