###
###  NOTE: THIS BUILD.PL IS CURRENTLY MEANT ONLY FOR DEPENDENCY TRACKING, NOT INSTALLATION
###  (yet)
###

use Module::Build;
my $class = Module::Build->subclass(
    class => 'Module::Build::SMMIDSite',
    code  => <<'SUBCLASS',

# build action just runs make on programs
sub ACTION_build {}

# override install to just copy the whole dir into the install_base
sub ACTION_install {
   my $self = shift;
   require File::Spec;
   my $tgt_dir = File::Spec->catdir($self->install_base,'SMMID');
   system 'rm', '-rf', $tgt_dir;
   system 'cp', '-rl', '.' => $tgt_dir;
   $? and die "SGN site copy failed\n";
}

SUBCLASS
);

#my $class = 'Module::Build';
my $build = $class->new(

    dist_name          => 'SMMID',
    license            => 'perl',
    create_makefile_pl => 'passthrough',

    dist_version => '0.1',
    dist_author  => 'Lukas Mueller',
    dist_abstract =>
      'The code and content behind the SMMID website, http://smmid.org',

    recursive_test_files => 1,

    build_requires => {
        'Test::More' => 0,
    },
    requires       => {
        perl => '5.10',
        'Catalyst::Action::RenderView'     => 0,
        'Catalyst::Runtime'                => '5.7006',
        'Catalyst::Plugin::ConfigLoader'   => 0,
        'Catalyst::Plugin::Static::Simple' => 0,
        'Catalyst::View::TT'               => 0,
        'Config::General'                  => 0,
        'parent'                           => 0,
        'Tie::UrlEncoder'                  => 0,
    },
);
$build->create_build_script;
