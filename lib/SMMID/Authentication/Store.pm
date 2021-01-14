
package SMMID::Authentication::Store;

use Moose;

use Data::Dumper;
use SMMID::Login;

sub find_user {
    my $self = shift;
    my $auth_info = shift;
    my $c = shift;

    print STDERR "Authenticating user $auth_info->{username}...\n";

    my $login = SMMID::Login->new( { schema => $c->model("SMIDDB")->schema() } );
    
    #my $row = $c->model("SMIDDB")->resultset("Dbuser")->find( { username => $auth_info->{username} });

    my $row = $login->exists_user($auth_info->{username});

    my $login_info = $login->login_user($auth_info->{username}, $auth_info->{password});
    
    if ($row) {
	print STDERR "User $auth_info->{username} found...\n";

	if (!$login_info->{error}) {
	    
	    
	    my $user = SMMID::Authentication::User->new();
	    $user->set_object($row);
	    $user->id($row->username());
	    $user->roles([ $row->user_type() ]);
	    return $row, $login_info;
	}
    }

    print STDERR "LOGIN INFO NOW: ".Dumper($login_info);
    return undef, $login_info;

}




1;
