
package InstallDbPatchTables;

use Moose;
use Dbpatch::PatchRoot;

extends 'Dbpatch::PatchRoot';

sub init_patch {
    my $self = shift;

    $self->name('InstallDbPatchTables');
    $self->description('Install the dbpatch tables.');

}

sub patch {
    my $self = shift;

    print STDERR "HELLO WORLD!\n";
    # do nothing, the db patch tables should be installed automatically
    # if not already installed.

}

1;
