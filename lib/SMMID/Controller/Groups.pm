package SMMID::Controller::Groups;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

sub groups_manage :Chained('/') :PathPart('groups/manage'){
  my $self = shift;
  my $c = shift;

  $c->stash->{template} = 'groups/groups_manage.mas';
}


'SMMID::Controller::Groups';
