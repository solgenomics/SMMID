# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'SMMID';
all_from 'lib/SMMID.pm';

build_requires 'Test::More';

requires 'Catalyst::Runtime' => '5.7006';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Config::General';
requires 'parent';
requires 'Tie::UrlEncoder';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
