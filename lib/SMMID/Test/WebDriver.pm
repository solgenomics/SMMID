
package SMMID::Test::WebDriver;

use Moo;
use Data::Dumper;

extends 'Test::Selenium::Remote::Driver';

around 'BUILDARGS' => sub {
    my ($orig, $class, $args)  = @_;

    if ($class->is_docker()) {
	print STDERR "We are in a docker!\n";
	$args->{remote_server_addr} = $args->{remote_server_addr} ? $args->{remote_server_addr} : "selenium";
	$args->{platform} = "LINUX";
	$args->{browser_name} = "firefox";
	$args->{version} = "81.0.1";
	$args->{base_url} = 'http://smid_db:3010';
    }
    else {
	print STDERR "We are not in a docker...\n";
	$args->{remote_server_addr} = $args->{remote_server_addr} ? $args->{remote_server_addr} : "localhost";
	$args->{port} = 4444;
	$args->{platform} = "LINUX";
	$args->{browser_name} = "firefox";
	$args->{base_url} = 'http://localhost:3010';
    }

    return $args;
};

sub is_docker {
    my $self = shift;

    my $lines = `cat /proc/1/cgroup`;
    if ($lines =~ /docker/) {
    	return 1;
    }
    return 0;
}

sub login {
    my $self = shift;
    my $username = shift;
    my $password = shift;


    
    $self->get_ok('/');
    sleep(2);
    
    my $site_login_button = $self->find_element('site_login_button', 'id');
    $site_login_button->click();
    sleep(1);
    
    my $username_field = $self->find_element('username', 'id');
    
    $username_field->send_keys($username);

    my $password_field = $self->find_element('password', 'id');
    
    $password_field->send_keys($password);

    my $login_button = $self->find_element('submit_password', 'id');
    $login_button->click();

    sleep(1);
}

sub login_user {
    my $self = shift;

    $self->login('john_doe', 'secretpw');
}

sub login_another_user {
    my $self = shift;

    $self->login('another_user', 'secretpw');
}

sub login_curator {
    my $self = shift;

    $self->login('jane_doe', 'secretpw');
}

sub logout {
    my $self = shift;

    $self->get_ok('/');
    sleep(2);
    
    my $login_menu = $self->find_element('navbarDropdownMenuLink_3', 'id');
    $login_menu->click();
    sleep(3);

    my $logout_button = $self->find_element('navbar_logout', 'id');
    $logout_button->click();
    sleep(1);
    
    $self->accept_alert_ok();
    
    #$self->get_ok('/rest/user/logout');
    #sleep(1);
    $self->get_ok('/');
    sleep(1);

    print STDERR "Logged out.\n";
}

1;
