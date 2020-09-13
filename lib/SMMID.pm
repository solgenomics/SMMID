=head1 NAME

SMMID - Catalyst based application

=head1 SYNOPSIS

    script/smmid_server.pl

=head1 DESCRIPTION

=cut

package SMMID;

use Moose;
use Data::Dumper;
use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

extends 'Catalyst';

use File::Spec ();
use File::Basename ();
use File::Path ();

use Catalyst qw(
                ConfigLoader
                Static::Simple
                SmartURI
                Authentication
                +SMMID::Authentication::Store
                +SMMID::Authentication::User
                Authorization::Roles
                +SMMID::Role::Site::Exceptions
                +SMMID::Role::Site::Files
);

our $VERSION = '0.01';


# Configure the application.
#
# Note that settings in smmid.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

# logs go by default in /var/log/smmid-site
my $logdir = File::Spec->catfile( File::Spec->rootdir,
				  'var',
				  'log',
				  'smmid-site',
				);

__PACKAGE__->config(
    name => 'smmid',
    access_log => File::Spec->catfile( $logdir, 'access.log' ),
    error_log  => File::Spec->catfile( $logdir, 'error.log'  ),
    default_view => 'Mason',
    #root => 'static',

    # our conf file is by default in /etc/cxgn/SMMID.conf
    'Plugin::ConfigLoader' => {
	#file => File::Spec->catfile( File::Spec->rootdir, __PACKAGE__->config->{home}.'/../../smmid_local.conf')
    },
    
    
    'Plugin::Authentication' => {
	default_realm => 'default',
	default => {
	    credential => {
		class => '+SMMID::Authentication::Credentials',
	    },
 	    
	    store => {
		class => "+SMMID::Authentication::Store",
		user_class => "+SMMID::Authentication::User",
		###		    role_column => 'roles',
	    },
	},

    },


    'Plugin::Static::Simple' => {
	dirs => [ 'js', 'tempfiles', 'static' ],
    }
);

after 'setup_finalize' => sub {
    my $self = shift;

    $self->config->{basepath} = $self->config->{home};

    # all files written by web server should be group-writable
    umask 000002;
};




# Start the application
__PACKAGE__->setup();

# also load SMMIDDb, since it won't be found by the regular Catalyst
# requires

#require SMMIDDB;


=head1 CLASS METHODS

=head2 configure_mod_perl

  Status  : public
  Usage   : SMMID->configure_mod_perl( vhost => 1 );
  Returns : nothing meaningful
  Args    : hash-style list of arguments as:
             vhost => boolean of whether this
                      configuration should be applied
                      to the current virtual host (if true),
                      or the root Apache server (if false),
  Side Eff: adds a lot of configuration to the currently running
            apache server


  Configures the currently running Apache mod_perl server
  to run this application.

  Example :

    In an Apache configuration file:

       <VirtualHost *:80>

           PerlWarn On
           PerlTaintCheck On

           LogLevel error

           #the name of the virtual host we are defining
           ServerName smmid.localhost.localdomain

           <Perl>

             use lib qw( /crypt/rob/cxgn/git/local-lib/core/SMMID/lib );
             use SMMID;
             SMMID->configure_mod_perl( vhost => 1 );

           </Perl>

       </VirtualHost>

=cut

# sub configure_mod_perl {
#     my $class = shift;
#     my %args = @_;

#     exists $args{vhost}
#         or die "must pass 'vhost' argument to configure_mod_perl()\n";

#     require Apache2::ServerUtil;
#     require Apache2::ServerRec;

#     my $app_name = $class;
#     my $cfg = $class->config;
#     -d $cfg->{home} or die <<EOM;
# FATAL: Catalyst could not figure out the home dir for $app_name, it
# guessed '$cfg->{home}', but that directory does not exist.  Aborting start.
# EOM
#     # add some other configuration to the web server
#     my $server = Apache2::ServerUtil->server;
#     $server = $server->next if $args{vhost}; #< vhost currently being
#                                              #configured should be first
#                                              #in the list
#     $server->add_config( $_ ) for map [ split /\n/, $_ ],
#         (
#          'ServerSignature Off',

#          #respond to all requests by looking in this directory...
#          "DocumentRoot $cfg->{home}",

#          #where to write error messages
#          "ErrorLog "._check_logfile( $cfg->{error_log} ),
#          "CustomLog "._check_logfile( $cfg->{access_log} ).' combined',

#          'ErrorDocument 500 "Internal server error: The server encountered an internal error or misconfiguration and was unable to complete your request. Feel free to contact us at sgn-feedback@sgn.cornell.edu and inform us of the error.',


#          # allow symlinks, allow access from anywhere
#          "<Directory />

#              Options +FollowSymLinks

#              Order allow,deny
#              Allow from all

#           </Directory>
#          ",


#          # set our application to handle most requests by default
#          "<Location />
#              SetHandler modperl
#              PerlResponseHandler SMMID
#           </Location>
#          ",

#          # except set up serving /static files directly from apache,
#          # bypassing any perl code
#          'Alias /static '.File::Spec->catdir( $cfg->{home}, 'root', 'static' ),
#          "<Location /static>
#              SetHandler  default-handler
#           </Location>
#          ",
#         );

# }

sub _check_logfile {
    my $file = File::Spec->catfile(@_);

    return $file if -w $file;

    my $dir = File::Basename::dirname($file);

    return $file if -w $dir;

    -d $dir
        or do { my $r = File::Path::mkpath($dir); chmod 0755, $dir}
        or die "cannot open log file '$file', dir '$dir' does not exist and I could not create it";

    -w $dir
        or die "cannot open log file '$file', dir '$dir' is not writable";

    return $file;
}



=head1 SEE ALSO

L<SMMID::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
