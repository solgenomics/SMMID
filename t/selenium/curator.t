use strict;
use Test::More;

use SMMID::Test::WebDriver;

my $t = SMMID::Test::WebDriver->new();

#First, start with a clean slate: no logged in user.
$t->get_ok('/');
$t->get_ok('/rest/user/logout');

#Next, attempt to access curator-only pages without correct privileges
$t->get_ok('/curator');
sleep(1);
#login dialog should show up, as well as a message that says "you must be logged in as a curator"
ok($t->body_text_contains('Forgot password?'), 'displays login screen');
$t->body_text_contains('You must be logged in as a curator');

#Attempt to access user accounts

#First, new user page
$t->get_ok('/user/0/profile');
sleep(1);
$t->accept_alert_ok();

#Then, existing user profile page
$t->get_ok('/user/1/profile');
sleep(1);
$t->accept_alert_ok();

#Try to view smids

#Public smid
$t->get_ok('/smid/2');
sleep(1);

#private smid
$t->get_ok('/smid/1');
sleep(1);
$t->accept_alert_ok();

### By now, it should have been shown that a user who is not logged in cannot view anything.

#Return to curator page and login
$t->get_ok('/curator');
sleep(1);
$t->login_curator();
sleep(1);

#Curator should see all smids, public and private
$t->body_text_contains('yeast#0001');
$t->body_text_contains('public');
$t->body_text_contains('earth#0001');
$t->body_text_contains('private');
$t->body_text_contains('Unverified');

#visit add new user page from curator page
$t->mouse_move_to_location( { element => 'new_account_button' } );

my $new_user = $t->find_element('new_account_button', 'id');
$new_user->click();

sleep(1);

$t->body_text_contains("Enter New User Data");

#Return to curator page
$t->get_ok('/curator');
sleep(1);

#Finished testing
$t->logout();
done_testing();
