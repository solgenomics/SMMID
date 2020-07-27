package SMMID::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use SMMID::Login;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

SMMID::Controller::Root - Root Controller for SMMID

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut


sub auto : Private {
    my ($self, $c) = @_;
 
    # gluecode for logins
    #
    unless( $c->config->{'disable_login'} ) {
	my $login = SMMID::Login->new( { schema => $c->model("SMIDDB")->schema() });
	
        if ( my $dbuser_id = $login->has_session())  {

            my $dbuser = $c->model("SMIDDB")->find( { dbuser_id => $dbuser_id });

            $c->authenticate({
                username => $dbuser->username(),
                password => $dbuser->password(),
            });
        }
    }
    return 1;
}
    
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->stash->{template} = 'welcome.tt2';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
    
}



sub contact :Path('/contact') :Args(0) { 
    my ($self, $c) = @_;
}

sub about :Path('/about') :Args(0) {
    my ($self, $c) = @_;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Lukas Mueller,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
