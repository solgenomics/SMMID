package SMMID::Controller::REST::Groups;

use Moose;
use utf8;
use Unicode::Normalize;
use HTML::Entities;
use SMMID::Login;

BEGIN { extends 'Catalyst::Controller::REST' };

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );


sub clean {
   my $self = shift;
   my $str = shift;

   # remove script tags
   $str =~ s/\<script\>//gi;
   $str =~ s/\<\/script\>//gi;

   return $str;
}

sub groups :Chained('/') :PathPart('rest/groups'){
  my $self = shift;
  my $c = shift;

  my $error = "";

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to manage work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Groups")->search({}, {order_by => {-asc => 'group_name'}});
  my @data;

  # while (my $r = $rs->next()){
  #   push @data
  # }

}

sub group_list :Chained('groups') :PathPart('') CaptureArgs(1){
  my $self = shift;
  my $c = shift;

  my $group_id = shift;

  #query db for users in this group

  my $r = $c->model("SMIDDB")->resultset("SMIDDB")->find({group_id => $group_id});
  my @data;

  if (!$r){
    $c->stash->{rest} = {error => "Sorry, this team does not exist."};
    return;
  }

  while (my $user = $r->user_list()->next()){
    push @data ["<a href=\"/user/".$user->dbuser_id()."/profile\">".$user->first_name()." ".$user->last_name()."</a>", $user->email(), $user->organization()];
  }

  $c->stash->{rest} = {data => \@data};

}

sub add_group :Chained('groups') :PathPart('add_group') Args(0){

}

sub update :Chained('groups') :PathPart('update') CaptureArgs(1){

}

sub delete :Chained('groups') :PathPart('delete') CaptureArgs(1){

}
