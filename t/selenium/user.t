my $t = SMMID::Test::WebDriver->new();

#First, start with a clean slate: no logged in user.
$t->get_ok('/');
$t->get_ok('/rest/user/logout');

#First, new user page
$t->get_ok('/user/0/profile');
sleep(1);
$t->accept_alert_ok();

#Then, existing user profile page
$t->get_ok('/user/1/profile');
sleep(1);
$t->accept_alert_ok();

#No access should have been granted. Now, user will be logged in and try to access various pages.
$t->login_user();
sleep(1);
$t->mouse_move_to_location( { element => 'navbarNavDropdown' } );
my $navbar = $t->find_element('navbarNavDropdown', 'id');
$navbar->click();
sleep(1);
$t->mouse_move_to_location( { element => 'access_your_profile_button' } );
my $your_profile = $t->find_element('access_your_profile_button', 'id');
$your_profile->click();
sleep(1);

#Return home and login a curator
$t->get_ok('/');
$t->get_ok('/rest/user/logout');
$t->login_curator();
sleep(1);
$t->mouse_move_to_location( { element => 'navbarNavDropdown' } );
my $navbar = $t->find_element('navbarNavDropdown', 'id');
$navbar->click();
sleep(1);
$t->mouse_move_to_location( { element => 'access_your_profile_button' } );
my $your_profile = $t->find_element('access_your_profile_button', 'id');
$your_profile->click();
sleep(1);

#Create a new user
$t->get_ok('/user/0/profile');
sleep(1);
my $first_name = $t->find_element('edit_first_name','id');
$first_name->send_keys('User');
my $last_name = $t->find_element('edit_last_name','id');
$last_name->send_keys('Test');
my $username = $t->find_element('edit_username','id');
$username->send_keys('usertest');
my $email = $t->find_element('edit_email','id');
$email->send_keys('usertest@cornell.edu');
my $password = $t->find_element('new_password','id');
$password->send_keys('lettucesalad');
my $confirm_password = $t->find_element('new_password_confirm','id');
$confirm_password->send_keys('lettucesalad');

$t->mouse_move_to_location({element => 'submit_new_user_data_button'});
my $submit_new_user = $t->find_element('submit_new_user_data_button', 'id');
$submit_new_user->click();
sleep(1);
$t->accept_alert_ok();

#Login as new user. Change some data and the password.
$t->get_ok('/');
$t->get_ok('/rest/user/logout');

$t->login_yet_another_user();
sleep(1);
$t->get_ok('/user/4/profile');

$t->mouse_move_to_location({element => 'change_user_data_button'});
my $change_data = $t->find_element('change_user_data_button', 'id');
$change_data->click();

$first_name = $t->find_element('edit_first_name','id');
$first_name->send_keys('Billy');

$t->mouse_move_to_location({element => 'change_user_data_button'});
$change_data->click();
sleep(1);
$t->accept_alert_ok();

$t->mouse_move_to_location({element => 'change_password_button'});
my $change_password = $t->find_element('change_password_button', 'id');
$change_password->click();

my $old_password = $t->find_element('old_password', 'id');
$old_password->send_keys('lettucesalad');
my $new_password = $t->find_element('new_password', 'id');
$new_password->send_keys('eggsalad');
my $new_password_confirm = $t->find_element('new_password_confirm', 'id');
$new_password_confirm->send_keys('eggsalad');

$t->mouse_move_to_location({element => 'change_password_button'});
$change_password->click();
sleep(1);
$t->accept_alert_ok();

#Finished testing
$t->logout();
done_testing();
