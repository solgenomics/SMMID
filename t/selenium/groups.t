use strict;
use Test::More;

use SMMID::Test::WebDriver;

#create a new group
  #test that all the people that should be there are there
  #Add a new person to that group
  #Remove a person from that group
#delete that group
#create a new group
  #login as each user in the group and visit their user profile to make sure group displays correctly
#associate a smid with a group from the curator page
  #First make sure it is invisible to group members
  #give it protected status
  #Make sure it is visible to group members

#finish testing

my $t = SMMID::Test::WebDriver->new();

$t->get_ok('/');

$t->login_curator();
sleep(1);

$t->get_ok('/groups/manage');
sleep(1);

$t->mouse_move_to_location({element => "add_group_button"});
my $new_group_button = $t->find_element('add_group_button', 'id');
$new_group_button->click();
sleep(1);

$t->mouse_move_to_location({element => "select_user_1"});
my $push_user_1 = $t->find_element('select_user_1', 'id');
$push_user_1->click();
sleep(1);

$t->mouse_move_to_location({element => "select_user_2"});
my $push_user_2 = $t->find_element('select_user_2', 'id');
$push_user_2->click();
sleep(1);

my $group_name = $t->find_element('new_group_name','id');
$group_name->send_keys('Test Group');

$t->mouse_move_to_location({element => "submit_new_group"});
my $submit_new_group = $t->find_element('submit_new_group', 'id');
$submit_new_group->click();
$t->accept_alert_ok();
sleep(2);

$t->body_text_contains("Test Group");
sleep(1);

$t->mouse_move_to_location({element => "select_group_users"});
$t->find_element('select_group_users', 'id')->click();
$t->mouse_move_to_location({element=>"group_1"});
$t->find_element('group_1', 'id')->click();
sleep(1);

$t->body_text_contains("John Doe");
$t->body_text_contains("Jane Doe");

$t->mouse_move_to_location({element => "remove_user_1"});
$t->find_element('remove_user_1', 'id')->click();
$t->accept_alert_ok();
sleep(1);

$t->mouse_move_to_location({element => "select_group_users"});
$t->find_element('select_group_users', 'id')->click();
$t->mouse_move_to_location({element=>"group_1"});
$t->find_element('group_1', 'id')->click();
sleep(1);

$t->body_text_lacks("John Doe");
sleep(1);

$t->mouse_move_to_location({element => "delete_group_1"});
$t->find_element("delete_group_1", "id")->click();
sleep(1);

$t->body_text_lacks("Delete this Group");
sleep(1);

$t->mouse_move_to_location({element => "add_group_button"});
my $new_group_button = $t->find_element('add_group_button', 'id');
$new_group_button->click();
sleep(1);

$t->mouse_move_to_location({element => "select_user_1"});
my $push_user_1 = $t->find_element('select_user_1', 'id');
$push_user_1->click();
sleep(1);

$t->mouse_move_to_location({element => "select_user_2"});
my $push_user_2 = $t->find_element('select_user_2', 'id');
$push_user_2->click();
sleep(1);

my $group_name = $t->find_element('new_group_name','id');
$group_name->send_keys('Test Group 2');

$t->mouse_move_to_location({element => "submit_new_group"});
my $submit_new_group = $t->find_element('submit_new_group', 'id');
$submit_new_group->click();
$t->accept_alert_ok();
sleep(2);

$t->get_ok('/user/2/profile');
sleep(1);
$t->body_text_contains("Test Group 2");
$t->body_text_contains("John Doe");
sleep(1);

$t->get_ok('/');
$t->logout();
sleep(1);
$t->login_user();
sleep(1);
$t->get_ok('/browse');
sleep(1);
$t->body_text_lacks("earth#0002");

$t->get_ok('/curator');
sleep(1);
$t->mouse_move_to_location({element=>'change_public_status_2'});
my $make_protected = $t->find_element('change_public_status_2', 'id');
$make_protected->click();
sleep(1);
$t->mouse_move_to_location({element => "select_group"});
$t->find_element('select_group', 'id')->click();
$t->mouse_move_to_location({element => "group_2"});
$t->find_element('group2', 'id')->click();
sleep(1);
$t->mouse_move_to_location({element=>'submit_protected_button'});
$t->find_element('submit_protected_button', 'id')->click();
sleep(1);
$t->body_text_contains("protected");

$t->logout();
done_testing();
