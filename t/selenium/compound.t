
use strict;
use Test::More;

use SMMID::Test::WebDriver;

my $t = SMMID::Test::WebDriver->new();

print STDERR "Starting...\n";

# make sure we are logged out initially
#
$t->get_ok('/rest/user/logout');

# go to add compound page without being logged in
#
$t->get_ok('/smid/0');
sleep(1);

# should show login
#
ok($t->body_text_contains('Forgot password?'), 'displays login screen');

$t->login_user();
sleep(3);

# enter a new smid
#
$t->get_ok('/smid/0');
sleep(1);

my $smid_id_input = $t->find_element('smid_id', 'id');
$smid_id_input->send_keys('yeast#0001');

my $iupac_input = $t->find_element('iupac_name', 'id');
$iupac_input->send_keys('ethanol');

my $formula_input = $t->find_element('formula', 'id');
$formula_input->send_keys('C2H6O');

my $organism_input = $t->find_element('organisms', 'id');
$organism_input->send_keys('Saccharamyces candida');

my $smiles_input = $t->find_element('smiles_string', 'id');
$smiles_input->send_keys('CH3CH2OH');

$t->mouse_move_to_location( { element => 'add_new_smid_button' } );

my $submit_smid = $t->find_element('add_new_smid_button', 'id');
$submit_smid->click();

$t->accept_alert_ok();

$t->get_ok('/browse');
sleep(1);

$t->body_text_contains('yeast#0001');

$t->body_text_lacks('earth#0002');

$t->logout();
sleep(1);

$t->get_ok('/');
sleep(1);

$t->login_curator();
sleep(1);

$t->get_ok('/browse');
sleep(1);

$t->body_text_contains('yeast#0001');

$t->body_text_contains('earth#0002');
sleep(1);

$t->logout();









done_testing();

