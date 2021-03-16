package SMMID::Authentication::ViewPermission;

use Moose;

#This subroutine determines if a viewer has permission to see a particular smid. Use it to control what data is sent to the webpage
#first parameter should be $c, second parameter should be an object encapsulating the smid
sub can_view_smid {

  my $c = shift;
  my $smid = shift;

  if($smid->public_status() eq "public"){return 1;}

  if (!$c->user() && $smid->public_status() eq "protected"){
    return 0;
  }

  if ($smid->public_status() eq "protected"){
    if ($c->user()->get_object()->user_type() eq "curator"){
      return 1;
    }
    if ($c->user()->dbuser_id() == $smid->dbuser_id()){
      return 1;
    }
    my @group_ids = $c->user()->get_object()->group_ids();
    while (my $group_id = @group_ids->next()){
      if ($group_id == $smid->group_id()){
        return 1;
      }
    }
  }

  if(!$c->user() && $smid->public_status() eq "private"){return 0;}

  if($smid->public_status() eq "private" && $c->user()->get_object()->dbuser_id() != $smid->dbuser_id() && $c->user()->get_object()->user_type() ne "curator"){return 0;}

  return 1;
}

#First parameter should be $c, second parameter should be the dbuser id of the group to be viewed
# sub can_view_group_data {
#
#   my $c = shift;
#   my $dbuser_id = shift;
#
#   if (!$c->user()) {return 0;}
#
#   if ($c->user()->dbuser_id() != $dbuser_id && $c->user()->get_object()->user_type() ne "curator") {return 0;}
#
#   return 1;
# }

#First parameter should be $c, second parameter should be the smid
sub can_edit_smid {
  my $c = shift;
  my $smid = shift;

  if($smid->public_status() eq "private"){
    if (!$c->user() || ( $c->user()->dbuser_id() != $smid->dbuser_id() && $c->user()->get_object()->user_type() ne "curator") ) {
      return 0;
    } else {return 1;}
  }

  if ($smid->public_status() eq "public" || $smid->public_status() eq "protected"){
    if (!$c->user()){
      return 0;
    }
    #they have permission if they are a curator
    if ($c->user()->get_object()->user_type() eq "curator"){
      return 1;
    }
    #they have permission if they are the author
    if ($c->user()->dbuser_id() == $smid->dbuser_id()){
      return 1;
    }
    #They have permission if they are part of the group managing this smid
    my @group_ids = $c->user()->get_object()->group_ids();
    while (my $group_id = @group_ids->next()){
      if ($group_id == $smid->group_id()){
        return 1;
      }
    }

    return 0;

  }
}

1;
