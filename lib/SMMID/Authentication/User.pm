
package SMMID::Authentication::User;

use Moose;

extends "Catalyst::Authentication::User";

has 'id' => (
    isa => 'Maybe[Str]',
    is => 'rw',
    default => sub {
	my $self = shift;
	if ($self->user()) { 
	    return $self->user()->username();
	}
	else {
	    return undef;
	}
    } );

has 'user' => (isa => 'Maybe[Ref]', is => 'rw' );

has 'object' => (isa => 'Maybe[Ref]', is => 'rw', writer => 'set_object', reader => 'get_object');

has 'supported_features' => (
    isa => 'Ref',
    is => 'ro',
    default => sub {
	return { roles => 1, self_check => 1 };
    });

has 'roles' => (
    isa => 'Maybe[ArrayRef]',
    is => 'rw',
    default => sub {
	my $self = shift;
	if ($self->user()) { 
	    return $self->user->roles();
	}
	else {
	    return undef;
	}
    });

# sub id {
#     my $self = shift;
#     return $self->user()->username();
# }

# sub supported_features {
#     my $self = shift;
#     return { roles =>1,  self_check=>1};
# }

# sub get_object {
#     my $self = shift;
#     return $self->user();;
# }

# sub set_object {
#     my $self = shift;
#     my $user = shift;
#     $self->user($user);
# }

# sub roles {
#     my $self = shift;
#     return $self->user()->roles();
# }

sub check_roles {
    my $self = shift;
    my @roles = @_;
    my %has_roles = ();
    map { $has_roles{$_} = 1; } $self->roles();

    foreach my $r (@roles) {
        if (!exists($has_roles{$r})) {
            return 0;
        }
    }
    return 1;
}

1;
