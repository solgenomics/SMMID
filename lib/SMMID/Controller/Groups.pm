package SMMID::Controller::Groups;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

sub group :Chained('/') :PathPart('groups'){
  my $self = shift;
  my $c = shift;

  $c->stash->{template} = '/groups.mas';
}

# sub add :Chained('groups') :PathPart('new'){
#   my $self = shift;
#   my $c = shift;
#
#   $c->stash->{action} = 'add';
#   $c->stash->{template} = '/groups.mas';
# }

# sub edit :Chained('groups') :PathPart('edit') CaptureArgs(1){
#   my $self = shift;
#   my $c = shift;
#   my $group_id = shift;
#
#   $c->stash->{action} = 'edit';
#   $c->stash->{template} = '/groups.mas';
#   $c->stash->{group_id} = $group_id;
# }

'SMMID::Controller::Groups';
