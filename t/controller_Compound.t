use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'SMMID' }
BEGIN { use_ok 'SMMID::Controller::Compound' }

ok( request('/compound')->is_success, 'Request should succeed' );


