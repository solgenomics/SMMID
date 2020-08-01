
package SMMID::Authentication::Credentials;

use Moose;

use Data::Dumper;


#has 'config' => ( isa => 'Ref', is => 'rw');

#has 'app' => (isa => 'Object', is => 'rw');

#has 'realm' => (isa => 'Str', is => 'rw');


#sub new {
 #   my $class = shift;
 #   my $args = shift || {};

#    return bless $args, $class;
#}

    

sub authenticate {
    my $self = shift;
    my $c = shift;
    my $realm = shift;
    my $auth_info = shift;
    print STDERR "AUTH INFO fed to authenticate: ".Dumper($auth_info);
    my $store = SMMID::Authentication::Store->new();

    my ($user, $login_info) = $store->find_user($auth_info, $c);

    return ($user, $login_info);
}


1;
