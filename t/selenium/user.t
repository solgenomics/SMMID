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
sleep(0.5);
$t->mouse_move_to_location( { element => 'access_your_profile_button' } );
my $your_profile = $t->find_element('access_your_profile_button', 'id');
$your_profile->click();
sleep(1);

#Return home and login a curator
$t->get_ok('/');
$t->login_curator();
sleep(1);
$t->mouse_move_to_location( { element => 'navbarNavDropdown' } );
my $navbar = $t->find_element('navbarNavDropdown', 'id');
$navbar->click();
sleep(0.5);
$t->mouse_move_to_location( { element => 'access_your_profile_button' } );
my $your_profile = $t->find_element('access_your_profile_button', 'id');
$your_profile->click();
sleep(1);

#Finished testing
$t->logout();
done_testing();
