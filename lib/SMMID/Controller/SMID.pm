
package SMMID::Controller::SMID;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }


sub browse :Path('/browse') Args(0) {
    my $self = shift;
    my $c = shift;
}

sub smid :Chained('/') PathPart('smid') CaptureArgs(1) {
    my $self = shift;
    my $c = shift;
    $c->stash->{compound_id} = shift;
}

sub detail :Chained('smid') PathPart('') Args(0) {
    my $self = shift;
    my $c = shift;

    $c->stash->{template} = '/smid/detail.mas';
}

sub add :Path('/smid') Args(0) {
    my $self  = shift;
    my $c = shift;

    $c->stash->{action} = 'new';
    $c->stash->{compound_id} = 0;
    $c->stash->{template} = '/smid/detail.mas';
    
}

sub edit :Chained('smid') PathPart('edit') Args(0) {
    my $self = shift;
    my $c = shift;

    $c->stash->{action} = "edit";
    $c->stash->{template} = '/smid/detail.mas';
}

sub add_image :Chained('smid') PathPart('image') Args(0) {
    my $self = shift;
    my $c = shift;

    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::CompoundImage")->search( { compound_id => $c->stash->{compound_id} });

    my @image_ids;
    while (my $row = $rs->next()) {
	push @image_ids, $row->image_id();
    }
    
    $c->stash->{image_ids} = \@image_ids;
    $c->stash->{template} = '/image/index.mas';
}


'SMMID::Controller::SMID';
