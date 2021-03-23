package SMMID::Authentication::ViewPermission;

use Moose;

#This subroutine determines if a viewer has permission to see a particular smid. Use it to control what data is sent to the webpage
#first parameter should be $c->user(), second parameter should be an object encapsulating the smid
sub can_view_smid {

  my $c = shift;
  my $smid = shift;

  my $user = $c->user();

  if($smid->public_status() eq "public"){return 1;}

  if (!$user && $smid->public_status() eq "protected"){
    return 0;
  }

  if ($smid->public_status() eq "protected"){
    if ($user->get_object()->user_type() eq "curator"){
      return 1;
    }
    if ($user->dbuser_id() == $smid->dbuser_id()){
      return 1;
    }
    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->search({dbgroup_id => $smid->dbgroup_id()});
    while(my $r = $rs->next()){
      if($user->dbuser_id() == $r->dbuser_id()){
        return 1;
      }
    }
    return 0;
  }

  if(!$user && $smid->public_status() eq "private"){return 0;}

  if($smid->public_status() eq "private" && $user->get_object()->dbuser_id() != $smid->dbuser_id() && $user->get_object()->user_type() ne "curator"){return 0;}

  return 1;
}

#First parameter should be $c->user(), second parameter should be the dbuser id of the group to be viewed
# sub can_view_group_data {
#
#   my $user = shift;
#   my $dbuser_id = shift;
#
#   if (!$user) {return 0;}
#
#   if ($user->dbuser_id() != $dbuser_id && $user->get_object()->user_type() ne "curator") {return 0;}
#
#   return 1;
# }

#First parameter should be $c->user(), second parameter should be the smid
sub can_edit_smid {
  my $c = shift;
  my $smid = shift;

  my $user = $c->user();

  if(!$smid->public_status()){
    return 0;
  }

  if($smid->public_status() eq "private"){
    if (!$user || ( $user->dbuser_id() != $smid->dbuser_id() && $user->get_object()->user_type() ne "curator") ) {
      return 0;
    } else {return 1;}
  }

  if ($smid->public_status() eq "public" || $smid->public_status() eq "protected"){
    if (!$user){
      return 0;
    }
    #they have permission if they are a curator
    if ($user->get_object()->user_type() eq "curator"){
      return 1;
    }
    #they have permission if they are the author
    if ($user->dbuser_id() == $smid->dbuser_id()){
      return 1;
    }
    #They have permission if they are part of the group managing this smid
    #Add search to see if the user is in the group that manages this smid
    my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->search({dbgroup_id => $smid->dbgroup_id()});
    while(my $r = $rs->next()){
      if($user->dbuser_id() == $r->dbuser_id()){
        return 1;
      }
    }

    return 0;

  }
}

1;
