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
    #unless( $c->config->{'disable_login'} ) {
    my $login = SMMID::Login->new( { schema => $c->model("SMIDDB")->schema() });

    if (exists($c->req->cookies->{smmid_session_id})) { 
	$login->cookie_string($c->req->cookies->{smmid_session_id}->value());
    }
    
    if ( my $dbuser_id = $login->has_session())  {

	print STDERR "We have a logged in user! :-)\n";
	my $dbuser = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find( { dbuser_id => $dbuser_id });
	print STDERR "The logged in user is ".$dbuser->username()."\n";

	my $user = SMMID::Authentication::User->new();
	$c->user($user);
	$c->user()->set_object($dbuser);
	
	# $self->authenticate($c, 'default', {
	#     username => $dbuser->username(),
	#     password => $dbuser->password(),
			   # });
    }
    #}
    return 1;
}
    
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->stash->{template} = 'index.mas';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
    
}

sub contact :Path('/contact') :Args(0) { 
    my ($self, $c) = @_;
}

sub cite : Path('/cite') Args(0) {

}

sub about :Path('/about') :Args(0) {
    my ($self, $c) = @_;
}

sub download :Path('/download') Args(0) {
    my $self = shift;
    my $c = shift;

    $c->stash->{template} = '/download.mas';
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
