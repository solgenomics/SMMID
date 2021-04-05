package SMMID::Controller::REST::Groups;

use Moose;
use utf8;
use Unicode::Normalize;
use HTML::Entities;
use SMMID::Login;
use SMMID::Authentication::ViewPermission;
use JSON::XS;
use Data::Dumper;

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

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbgroup")->search({});
  my @data;
  my $html = "<option value=0 selected=\"selected\"><i>Select Group to Display</i></option>";

  if (!$rs){
    @data = [];
    $c->stash->{rest} = {data => \@data, html => $html};
    return;
  }

  while(my $r = $rs->next()){
    my $group_id = $r->dbgroup_id();
    my $group_name = $r->name();
    push @data, [$group_name, $r->description(), "<button id=\"delete_group_$group_id\" type=\"button\" class=\"btn btn-danger\" onclick=\"delete_group($group_id)\">Delete this Group</button>"];
    $html .= "<option id=\"group_$group_id\" value=$group_id>$group_name</option>";
  }

  $c->stash->{rest} = {data => \@data, html => $html};

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

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->search({dbgroup_id => $group_id});
  my @data;

  if (!$rs){
    $c->stash->{rest} = {error => "Sorry, this team does not exist."};
    return;
  }

  while (my $row = $rs->next()){
    my $user = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find({dbuser_id => $row->dbuser_id()});
    push @data, ["<a href=\"/user/".$user->dbuser_id()."/profile\">".$user->first_name()." ".$user->last_name()."</a>", $user->email(), $user->organization(), "<button type=\"button\" id=\"remove_user".$user->dbuser_id()."\" class=\"btn btn-danger\" onclick=\"remove_user_from_group($group_id,".$user->dbuser_id().")\">Remove this User</button>"];
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

sub add_group :Chained('/') :PathPart('rest/groups/add_group') Args(0){
  my $self = shift;
  my $c = shift;

  my $error = "";

  my $group_id = $c->stash->{group_id};

  if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
    $error .= "You must be logged in as a curator to create new work groups.";
    $c->stash->{rest} = {error => $error};
    return;
  }

  my $user_ids = $self->clean($c->req->param('user_list'));

  my @user_list = split("\t", $user_ids);

  my $group_name = $self->clean($c->req->param("group_name"));
  my $group_description = $self->clean($c->req->param("description"));

  if (!$group_name || $group_name eq ""){
    $error .= "Must have a group name. ";
  }
  if (!@user_list || scalar(@user_list) == 0 || !$user_list[0]){
    $error .= "Must have at least one user in new group. ";
  }

  if ($error){
    $c->stash->{rest} = { error => $error };
    return;
  }

  my $row = {
    name => $group_name,
    description => $group_description
  };

  my $new_group;

  eval {
    my $new = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbgroup")->new($row);
    $new->insert();
    $new_group = $new->dbgroup_id();
  };

  if ($@) {
    $c->stash->{rest} = { error => "Sorry, an error occurred storing the group ($@)" };
    return;
  }

  #Now add user <=> group relationship

  my $i = 0;
  while($i < scalar(@user_list)){
    $row = {
      dbuser_id => $user_list[$i],
      dbgroup_id => $new_group
    };
    my $new_dbuser_dbgroup = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->new($row);
    $new_dbuser_dbgroup->insert();
    $i = $i + 1;
  }

  if ($@){
    $c->stash->{rest} = { error => "Sorry, an error occurred storing the group ($@)" };
  } else {
    $c->stash->{rest} = {success => "Successfully stored the new work group with id=$new_group"};
  }

}

sub update :Chained('groups') :PathPart('update') Args(0){
  my $self = shift;
  my $c = shift;

  my $group_id = $c->stash->{group_id};

  print STDERR "Attempting to update a group...\n";

  #Add user ids to user_group table
  #make sure to check if that user is already in the group

  my $user_ids = $self->clean($c->req->param('user_list'));

  my @user_list = split("\t", $user_ids);

  foreach my $user_id (@user_list){
    my $exists = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->find({dbuser_id => $user_id, dbgroup_id => $group_id});
    next if($exists);

    my $row = {
      dbuser_id => $user_id,
      dbgroup_id => $group_id
    };

    my $new = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->new($row);
    $new->insert();
  }

  if ($@){
    $c->stash->{rest} = { error => "Sorry, an error occurred adding users to the group ($@)" };
  } else {
    $c->stash->{rest} = {success => "Successfully added users to the group."};
  }
}

sub remove_user :Chained('groups') :PathPart('remove_user') Args(1){
  my $self = shift;
  my $c = shift;
  my $user_id = shift;

  my $group_id = $c->stash->{group_id};

  my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->find({dbuser_id => $user_id, dbgroup_id => $group_id});

  if (!$row){
    $c->stash->{rest} = {error=> "This user is not in this group!"};
    return;
  }

  $row->delete();

  if ($@){
    $c->stash->{rest} = {error => "Sorry, an error occurred removing the user. ($@)"};
  } else {
    $c->stash->{rest} = {success => 1};
  }
}

sub delete :Chained('groups') :PathPart('delete') Args(0){
  my $self = shift;
  my $c = shift;

  my $group_id = $c->stash->{group_id};

  print STDERR "Deleting group...\n";

  my $smid_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search({dbgroup_id => $group_id});
  while (my $smid = $smid_rs->next()){
    my $data = {
      public_status => 'private',
      last_modified_date => 'now()',
      dbgroup_id => undef
    };
    eval {
      $smid->update($data);
    };

    if ($@) {
        $c->stash->{rest} = { error => "Sorry, an error occurred deleting the group. ($@)" };
         return;
    }
  }

  my $user_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->search({dbgroup_id => $group_id});
  while (my $r = $user_rs->next()){
    $r->delete();
  }

  my $group_rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbgroup")->find({dbgroup_id => $group_id});
  $group_rs->delete();

  if ($@){
    $c->stash->{rest} = {error => "Sorry, an error occurred deleting the group. ($@)"};
  } else {
    $c->stash->{rest} = {success => 1};
  }
}
