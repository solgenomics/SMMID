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

sub groups :Chained('/') PathPart('rest/groups') {
  my $self = shift;
  my $c = shift;

  print STDERR "Found Groups...\n";

  my $error = "";

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to manage work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

  $c->stash->{rest} = {success => "Has valid login. "};
}

sub list_groups :Chained('/') :PathPart('rest/groups/list_groups') {
  my $self = shift;
  my $c = shift;

  print STDERR "Found groups list...\n";

  my $error = "";

  #my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Groups")->search({}, {order_by => {-asc => 'group_name'}});
  my @data;

  push @data, ["Schroeder Lab", "X"];
  push @data, ["Jander Lab", "X"];

  my $html ="<option value=0 selected=\"selected\"><i>Select Group to Display</i></option>
            <option value=1>Schroeder Lab</option>
            <option value=2>Jander Lab</option>";

  $c->stash->{rest} = {data => \@data, html => $html};

  # while (my $r = $rs->next()){
  #   push @data, $r->group_name();
  # }

}

sub list_group_users :Chained('/') :PathPart('rest/groups/list_group_users') Args(1){
  my $self = shift;
  my $c = shift;

  my $group_id = shift;

  print STDERR "Listing users in the selected group...\n";

  #query db for users in this group

  # my $r = $c->model("SMIDDB")->resultset("SMIDDB")->find({group_id => $group_id});
  # my @data;
  #
  # if (!$r){
  #   $c->stash->{rest} = {error => "Sorry, this team does not exist."};
  #   return;
  # }
  #
  # while (my $user = $r->user_list()->next()){
  #   push @data, ["<a href=\"/user/".$user->dbuser_id()."/profile\">".$user->first_name()." ".$user->last_name()."</a>", $user->email(), $user->organization()];
  # }

  #$c->stash->{rest} = {data => \@data};

  my @data;
  if ($group_id == 1){
    push @data, ["Tyler", "email\@cornell.edu", "BTI", "X"];
    push @data, ["Frank", "email\@cornell.edu", "BTI", "X"];
  }
  if ($group_id == 2) {
    push @data, ["Marty", "email\@cornell.edu", "BTI", "X"];
    push @data, ["Leila", "email\@cornell.edu", "BTI", "X"];
  }

  $c->stash->{rest} = {data => \@data};

}

sub list_users :Chained('/') :PathPart('rest/groups/list_users') {
  my $self = shift;
  my $c = shift;
  my $error = "";

  print STDERR "Found user list...\n";

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->search( {} );
  my @data;

  while (my $user = $rs->next()){
    my $dbuser_id = $user->dbuser_id;
    push @data, ["".$user->first_name()." ".$user->last_name(), $user->email(), $user->organization(), "<button id=\"select_user_$dbuser_id\" onclick=\"push_array_entry($dbuser_id , \'up\' )  \" type=\"button\" class=\"btn btn-primary\"> \x{2191} </button>", $dbuser_id];
  }

  $c->stash->{rest} = {data => \@data};
}

sub add_group :Chained('groups') :PathPart('add_group') {

}

sub update :Chained('groups') :PathPart('update') CaptureArgs(1){

}

sub delete :Chained('groups') :PathPart('delete') CaptureArgs(1){

}