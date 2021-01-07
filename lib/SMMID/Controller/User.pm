
package SMMID::Controller::User;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

sub user :Chained('/') PathPart('user') CaptureArgs(1){
  my $self = shift;
  my $c = shift;
  $c->stash->{dbuser_id} = shift;
}

sub profile :Chained('user') PathPart(''){
  my $self = shift;
  my $c = shift;

  $c->stash->{template} = '/user.mas';
}

'SMMID::Controller::User';
