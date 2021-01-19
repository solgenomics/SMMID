
package SMMID::Controller::User;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

sub user :Chained('/') PathPart('user') CaptureArgs(1){
  my $self = shift;
  my $c = shift;
  $c->stash->{dbuser_id} = shift;
}

sub profile :Chained('user') PathPart('profile'){
  my $self = shift;
  my $c = shift;

  if ($c->user()){
    $c->stash->{sp_person_id} = $c->user()->dbuser_id();
  } else {
      $c->stash->{sp_person_id} = undef;
  }
  $c->stash->{template} = '/user.mas';
}

'SMMID::Controller::User';
