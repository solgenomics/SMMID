
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
sleep(2);

$t->accept_alert_ok();

sleep(2);

# test addition of dbxref
#
$t->mouse_move_to_location( { element => 'add_dbxref_button' } );
my $add_dbxref_button = $t->find_element('add_dbxref_button', 'id');
$add_dbxref_button->click();

sleep(1);
my $dbxref_accession = $t->find_element('dbxref_accession', 'id');
$dbxref_accession->send_keys('blabla');

my $dbxref_description = $t->find_element('dbxref_description', 'id');
$dbxref_description->send_keys('more blablabla');

my $save_dbxref_button = $t->find_element('save_dbxref_button', 'id');
$save_dbxref_button->click();

sleep(1);
$t->accept_alert_ok();

# test addition of hplc_ms experiment
#
$t->mouse_move_to_location( { element => 'add_hplc_ms_button' });
my $add_hplc_ms_button = $t->find_element('add_hplc_ms_button', 'id');
$add_hplc_ms_button->click();

my $hplc_ms_author = $t->find_element('hplc_ms_author', 'id');
$hplc_ms_author->send_keys('Jimi Hendrix');

my $hplc_ms_retention_time = $t->find_element('hplc_ms_retention_time', 'id');
$hplc_ms_retention_time->send_keys('10');

my $hplc_ms_adducts_detected = $t->find_element('hplc_ms_adducts_detected', 'id');
$hplc_ms_adducts_detected->send_keys('xyz');

my $hplc_ms_scan_number = $t->find_element('hplc_ms_scan_number', 'id');
$hplc_ms_scan_number->send_keys('99');

my $hplc_ms_link = $t->find_element('hplc_ms_link', 'id');
$hplc_ms_link->send_keys('https://blabla.com');

my $save_hplc_ms_button = $t->find_element('save_hplc_ms_button', 'id');
$save_hplc_ms_button->click();

$t->accept_alert_ok();

# test ms/ms data submission
#
$t->mouse_move_to_location( { element => 'add_ms_spectrum_button' });

my $add_ms_spectrum_button = $t->find_element('add_ms_spectrum_button', 'id');
$add_ms_spectrum_button->click();

my $ms_spectrum_author= $t->find_element('ms_spectrum_author', 'id');
$ms_spectrum_author->send_keys('Ritchie Blackmore');

my $ms_spectrum_collision_energy = $t->find_element('ms_spectrum_collision_energy', 'id');
$ms_spectrum_collision_energy->send_keys('250');

my $ms_spectrum_adduct_fragmented = $t->find_element('ms_spectrum_adduct_fragmented', 'id');
$ms_spectrum_adduct_fragmented->send_keys('[M-]');

my $ms_spectrum_mz_intensity = $t->find_element('ms_spectrum_mz_intensity', 'id');
$ms_spectrum_mz_intensity->send_keys('? ? ? ');

my $ms_spectrum_link = $t->find_element('ms_spectrum_link', 'id');
$ms_spectrum_link->send_keys('https://solgenomics.net');

my $save_ms_spectrum_button = $t->find_element('save_ms_spectrum_button', 'id');
$save_ms_spectrum_button->click();

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

