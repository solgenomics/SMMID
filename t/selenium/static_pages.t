
use strict;
use Test::More;

use SMMID::Test::WebDriver;

#$ENV{TWD_HOST} = "selenium";
#$ENV{TWD_PORT} = 4444;
#$ENV{TWD_BROWSER} = 'firefox';
#$ENV{TWD_VERSION} = "81.0.1";
#$ENV{TWD_PLATFORM} = "Linux";


my $t = SMMID::Test::WebDriver->new(); #base_url => 'http://smid_db:8088/');

print STDERR "Starting...\n";

$t->get_ok('/');
$t->title_is('SMID-DB', 'homepage title test');
$t->content_like(qr/Small Molecule Identifier Database/, 'check content snippet');
sleep(2);

$t->get_ok('/about');
sleep(1);

$t->get_ok('/contact');
sleep(1);

$t->get_ok('/cite');
sleep(1); 

$t->get_ok('/search');
sleep(1);

$t->get_ok('/curator');
sleep(1);

$t->get_ok('/download');

$t->login_user();
sleep(1);
$t->get_ok('/smid/0');
sleep(1);

$t->logout();

sleep(1);

#my $smid_id_input = $t->find_element('smid_id', 'id');




done_testing();

