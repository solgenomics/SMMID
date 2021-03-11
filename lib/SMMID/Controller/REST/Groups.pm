package SMMID::Controller::REST::Groups;

use Moose;
use utf8;
use Unicode::Normalize;
use HTML::Entities;
use SMMID::Login;
use SMMID::Authentication::ViewPermission;

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

sub groups :Chained('/') PathPart('rest/groups') CaptureArgs(1){
  my $self = shift;
  my $c = shift;

  my $group_id = shift;

  print STDERR "Found Groups...\n";

  $c->stash->{group_id} = $group_id;
}

sub group_data :Chained('groups') :PathPart('group_data'){
  my $self = shift;
  my $c = shift;

  my $group_id = $c->stash->{group_id};

  #...
}

sub list_groups :Chained('/') :PathPart('rest/groups/list_groups') {
  my $self = shift;
  my $c = shift;

  print STDERR "Found groups list...\n";

  my $error = "";

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to manage work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

  #my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Groups")->search({}, {order_by => {-asc => 'group_name'}});
  my @data;

  push @data, ["Schroeder Lab", "<button type=\"button\"class=\"btn btn-danger\" disabled onclick=\"\">Delete this Group</button>"];
  push @data, ["Jander Lab", "<button type=\"button\"class=\"btn btn-danger\" disabled onclick=\"\">Delete this Group</button>"];

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

  my $error = "";

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to manage work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

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
    push @data, ["Tyler", "email\@cornell.edu", "BTI", "<button type=\"button\"class=\"btn btn-danger\" disabled onclick=\"\">Remove this User</button>"];
    push @data, ["Frank", "email\@cornell.edu", "BTI", "<button type=\"button\"class=\"btn btn-danger\" disabled onclick=\"\">Remove this User</button>"];
  }
  if ($group_id == 2) {
    push @data, ["Marty", "email\@cornell.edu", "BTI", "<button type=\"button\"class=\"btn btn-danger\" disabled onclick=\"\">Remove this User</button>"];
    push @data, ["Leila", "email\@cornell.edu", "BTI", "<button type=\"button\"class=\"btn btn-danger\" disabled onclick=\"\">Remove this User</button>"];
  }

  $c->stash->{rest} = {data => \@data};

}

sub list_users :Chained('/') :PathPart('rest/groups/list_users') Args(1){
  my $self = shift;
  my $c = shift;
  my $error = "";

  my $tables = shift;

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to manage work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

  print STDERR "Found user list...\n";

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->search( {} );
  my @data;

  my $button;

  while (my $user = $rs->next()){

    my $dbuser_id = $user->dbuser_id;

    if ($tables eq "new"){
      $button = "<button id=\"select_user_$dbuser_id\" onclick=\"push_array_entry($dbuser_id , \'up\' , \'users_to_add_to_new_group\' , \'select_users_for_new_group\' )  \" type=\"button\" class=\"btn btn-primary\"> \x{2191} </button>";
    }
    if ($tables eq "existing"){
      $button = "<button id=\"select_user_$dbuser_id\" onclick=\"push_array_entry($dbuser_id , \'up\' , \'users_to_add_to_existing_group\' , \'select_users_for_existing_group\' )  \" type=\"button\" class=\"btn btn-primary\"> \x{2191} </button>";
    }

    push @data, ["".$user->first_name()." ".$user->last_name(), $user->email(), $user->organization(), $button, $dbuser_id];
  }

  $c->stash->{rest} = {data => \@data};
}

sub add_group :Chained('groups') :PathPart('add_group') Args(0){
  my $self = shift;
  my $c = shift;

  my $error = "";

  my $group_id = $c->stash->{group_id};

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to create new work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

  my @user_list = $self->clean($c->req->param("user_list"));
  my $group_name = $self->clean($c->req->param("group_name"));

  if (!$group_name || $group_name eq ""){
    $error .= "Must have a group name. ";
  }
  if (!@user_list || length(@user_list) == 0){
    $error .= "Must have at least one user in new group. ";
  }

  my $row = {
    users => @user_list,
    group_name => $group_name
  };

  my $new_group;

  eval {
    my $new = $c->model("SMIDDB")->resultset("SMIDDB::Result::Group")->new($row);
    $new->insert();
    $new_group = $new->group_id();
  };

  if ($@) {
    $c->stash->{rest} = { error => "Sorry, an error occurred storing the group ($@)" };
  } else {
    $c->stash->{rest} = {success => "Successfully stored the new work group with id=$new_group"};
  }
}

sub update :Chained('groups') :PathPart('update') Args(0){
  my $self = shift;
  my $c = shift;

  my $group_id = $c->stash->{group_id};

  #Add user ids to group table
  #Add group id to users that are now in the group
}

sub delete :Chained('groups') :PathPart('delete') Args(0){
  my $self = shift;
  my $c = shift;

  my $group_id = $c->stash->{group_id};

  #remove group id from smids and users with that group id listed
  #remove group
}
