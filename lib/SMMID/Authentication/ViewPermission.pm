package SMMID::Authentication::ViewPermission;

use Moose;

#This subroutine determines if a viewer has permission to see a particular smid. Use it to control what data is sent to the webpage
#first parameter should be $c, second parameter should be an object encapsulating the smid
sub can_view_smid {

  my $c = shift;
  my $smid = shift;

  if($smid->public_status() eq "public"){return 1;}

  if(!$c->user() && $smid->public_status() eq "private"){return 0;}

  if($smid->public_status() eq "private" && $c->user()->get_object()->dbuser_id() != $smid->dbuser_id() && $c->user()->get_object()->user_type() ne "curator"){return 0;}

  return 1;
}

1;
