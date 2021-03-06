
package SMMID::Controller::Experiment;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

sub experiment :Chained('/') PathPart('experiment') CaptureArgs(1) {
    my $self = shift;
    my $c = shift;

    $c->stash->{experiment_id} = shift;

}

sub experiment_detail :Chained('experiment') PathPart('') Args(0) {
    my $self = shift;
    my $c = shift;

    $c->stash->{template} = '/experiment.mas';
}

sub msms_visual_data :Chained('experiment') PathPart('msms_spectrum') Args(0){
    my $self = shift;
    my $c = shift;

    $c->stash->{template} = '/msms_visualizer.mas';
}


1;
