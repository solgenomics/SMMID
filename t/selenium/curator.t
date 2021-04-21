use strict;
use Test::More;

use SMMID::Test::WebDriver;

my $t = SMMID::Test::WebDriver->new();

#First, start with a clean slate: no logged in user.
$t->get_ok('/');

#Next, attempt to access curator-only pages without correct privileges
$t->get_ok('/curator');
sleep(1);
#login dialog should show up, as well as a message that says "you must be logged in as a curator"
ok($t->body_text_contains('Forgot password?'), 'displays login screen');
$t->body_text_contains('You must be logged in as a curator');
sleep(1);

#Attempt to access user accounts

#First, new user page
$t->get_ok('/user/0/profile');
sleep(2);
$t->accept_alert_ok();

#Then, existing user profile page
$t->get_ok('/user/1/profile');
sleep(2);
$t->accept_alert_ok();

#Try to view smids
print STDERR "Trying to view smids...\n";
#Private smid
$t->get_ok('/smid/2');
sleep(2);
$t->accept_alert_ok();

#Public smid
$t->get_ok('/smid/1');
sleep(1);

### By now, it should have been shown that a user who is not logged in cannot view anything.
print STDERR "Viewing curator page...\n";
#Return to curator page and login
$t->login_curator();
sleep(1);
$t->get_ok('/curator');
sleep(1);

#Curator should see all smids, public and private
$t->body_text_contains('earth#0002');
$t->body_text_contains('earth#0001');
$t->body_text_contains('private');
$t->body_text_contains('public');
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

print STDERR "Changing public and private statuses...\n";
#Make private smid public and public smid private, try visiting them
$t->mouse_move_to_location( { element => 'change_public_status_1' } );
my $public_smid = $t->find_element('change_public_status_1', 'id');
$public_smid->click();
sleep(2);
$t->mouse_move_to_location( { element => 'change_public_status_2' } );
my $private_smid = $t->find_element('change_public_status_2', 'id');
$private_smid->click();
sleep(2);

#Logout and view from browse page
$t->get_ok('/');
sleep(1);
$t->logout();
$t->get_ok('/browse');
sleep(2);
$t->body_text_contains('earth#0002');
$t->body_text_lacks('earth#0001');

#login as curator, return to curator page, and change smid curation status from detail page
print STDERR "Verifying test smid...\n";
$t->login_curator();
$t->get_ok('/smid/1');
$t->mouse_move_to_location( { element => 'curation_status_manipulate' } );
my $curation_status = $t->find_element('curation_status_manipulate', 'id');
$curation_status->click();
$t->mouse_move_to_location( { element => 'change_curation_verified' } );
my $verified = $t->find_element('change_curation_verified', 'id');
$verified->click();
$t->accept_alert_ok();

$t->get_ok('/curator');
sleep(2);
$t->body_text_contains("\x{2713}");

#Finished testing
$t->logout();
done_testing();
