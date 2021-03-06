
package SMMID::Controller::REST::User;

use Moose;
use utf8;
use Unicode::Normalize;
use IO::File;
use Data::Dumper;
use HTML::Entities;
use SMMID::Login;
use SMMID::Authentication::ViewPermission;
#use JSON::XS;

BEGIN { extends 'Catalyst::Controller::REST' };

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );


 sub clean {
     my $self = shift;
     my $str = shift;

     # remove script tags
     $str =~ s/\<script\>//gi;
     $str =~ s/\<\/script\>//gi;

     return $str;
 }

sub login : Path('/rest/user/login') Args(0) {
    my $self = shift;
    my $c = shift;

    my $LOGIN_COOKIE_NAME = $c->config->{login_cookie_name};

    my $username = $c->req->param("username");
    my $password = $c->req->param("password");
    my $goto_url = $c->req->param("goto_url");
    my $logout   = $c->req->param("logout");

    my $cookie = $c->req->param($LOGIN_COOKIE_NAME);

    print STDERR "Goto URL = $goto_url\n";

    my $login = SMMID::Login->new( { schema => $c->model("SMIDDB")->schema() } );
    my $login_info = $login->login_user($username, $password);

    my $credentials = SMMID::Authentication::Credentials->new();
    my ($user_row, $login_info) = $credentials->authenticate($c,'default', { username => $username, password => $password });


    if ($login_info->{cookie_string}) {

	# set the new cookie. The caller (controller)
	# will actually need to set the cookie.
	#
	$c->response->cookies->{$LOGIN_COOKIE_NAME}->{value} = $login_info->{cookie_string};
    }

    if (exists($login_info->{incorrect_password}) && $login_info->{incorrect_password} == 1) {
	$c->stash->{rest} = { error => "Login credentials are incorrect. Please try again." };
	return;
    }
    elsif (exists($login_info->{error})) {
	$c->stash->{rest} = { error => $login_info->{error} };
	return;
    }
    elsif (exists($login_info->{account_disabled}) && $login_info->{account_disabled}) {
	$c->stash->{rest} = { error => "This account has been disabled due to $login_info->{account_disabled}. Please contact the database to fix this problem." };
	return;
    }
    else {
	$c->stash->{rest} = {
	    message => "Login successful",
	    goto_url => $goto_url
	};
    }
}

sub logout :Path('/rest/user/logout') Args(0) {
    my $self = shift;
    my $c = shift;

    my $LOGIN_COOKIE_NAME = $c->config->{login_cookie_name};
    print STDERR "LOGIN COOKIE NAME = $LOGIN_COOKIE_NAME\n";

    my $login = SMMID::Login->new( { schema => $c->model("SMIDDB")->schema() } );
    my $cookie = $login->logout_user();
    print STDERR "LOGOUT: COOKIE = $cookie\n";
    $c->res->cookies->{$LOGIN_COOKIE_NAME} = undef;
    delete($c->res->cookies->{$LOGIN_COOKIE_NAME});
    $c->user(undef);
    $c->logout();
    $c->stash->{rest} = { message => "User successfully logged out." };
}

sub has_login : Path('/rest/user/has_login') Args(0) {
    my $self = shift;
    my $c = shift;

    if ($c->user()) {
	print STDERR "has_login: user present...\n";
	$c->stash->{rest} = { user => $c->user()->get_object()->dbuser_id(), role => $c->user()->get_object()->user_type() };
    }
    else {
	print STDERR "No user found.\n";
	$c->stash->{rest} = { user => undef, role => undef };
    }

}

sub new_account :Path('/rest/user/new') Args(0) {
    my $self = shift;
    my $c = shift;

    my $error="";

    if (!$c->user() || $c->user()->get_object()->user_type() ne "curator"){
      $error .= "You must be logged in as a curator to create new accounts.";
      $c->stash->{rest} = {error => $error};
      return;
    }

    my $first_name = $self->clean($c->req->param("first_name"));
    my $last_name = $self->clean($c->req->param("last_name"));
    my $email_address = $self->clean($c->req->param("email_address"));
    my $organization = $self->clean($c->req->param("organization"));
    my $username = $self->clean($c->req->param("username"));
    my $user_type = $self->clean($c->req->param("user_type"));

    my $already_exists = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find({username => $username});
    if ($already_exists){$error .= "A user with this username already exists.\n";}

    if(length($first_name) == 0){$error .= "Need a first name or a first initial.\n";}
    if(length($last_name) == 0){$error .= "Need a last name.\n";}
    if(length($email_address) == 0){$error .= "Need an email address.\n";}
    if(length($username) == 0){$error .= "Need a username. This is often the same as the email.\n";}

    my $password = $self->clean($c->req->param("password"));
    my $confirm_password = $self->clean($c->req->param("confirm_password"));

    if (length($password) < 7){$error .= "Password must be at least 7 characters long.\n";}
    if ($password ne $confirm_password){$error .= "Please confirm that the password is entered twice.\n";}

    if ($error){
      $c->stash->{rest} = {error => $error};
      return;
    }

    my $row;
    $row = {
      first_name => $first_name,
      last_name => $last_name,
      email => $email_address,
      organization => $organization,
      username => $username,
      user_type => $user_type,
      password => \"crypt('$password', gen_salt('bf'))",
      creation_date => 'now()',
      last_modified_date => 'now()',
    };

    my $new_dbuser;

    eval {
      my $new = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->new($row);
      $new->insert();
      $new_dbuser = $new->dbuser_id();
    };

    if ($@) {
	    $c->stash->{rest} = { error => "Sorry, an error occurred storing the user ($@)" };
    } else {
      $c->stash->{rest} = {success => "Successfully stored the new user with id=$new_dbuser"};
    }

}


# sub change_account_info_action :Path('/rest/user/update') Args(0) {
#     my $self = shift;
#     my $c = shift;
#
#     if (! $c->user() ) {
#         $c->stash->{rest} = { error => "You must be logged in to use this page." };
# 	return;
#     }
#
#     my $person = new CXGN::People::Login($c->dbc->dbh(), $c->user->get_sp_person_id());
#
# #    my ($current_password, $change_username, $change_password, $change_email) = $c->req->param({qw(current_password change_username change_password change_email)});
#
#     my $args = $c->req->params();
#
#     if (!$args->{change_password} && ! $args->{change_username} && !$args->{change_email}) {
# 	my $error = "No actions were requested. Please select which fields you would like to update by checking the appropriate checkbox(es) on the form and entering your new information.";
# 	print STDERR $error;
# 	$c->stash->{rest} =  { error => $error };
# 	return;
#     }
#
#     chomp($args->{current_password});
#     if (! $person->verify_password($args->{current_password})) {
# 	my $error = "Your current password does not match SGN records.";
# 	print STDERR $error;
# 	$c->stash->{rest} = { error => "$error" };
# 	return;
#     }
#
#     # Check for error conditions in all changes, before making any of them.
#     # Otherwise, we could end up making some changes and then failing on later
#     # ones. The user would then push the back button and their information may
#     # be different now but they will probably assume no changes were made. This
#     # is most troublesome if the current password changes.
#     #
#     if ($args->{change_username}) {
# 	#unless change_username is set, new_username won't be in the args hash because of the prestore test
# 	my $new_username = $args->{new_username};
# 	if(length($new_username) < 7) {
# 	    my $error = "Username must be at least 7 characters long.";
# 	    print STDERR $error;
# 	    $c->stash->{rest} = { error => $error  };
# 	    return;
# 	}
#
# 	my $other_user = CXGN::People::Login->get_login($c->dbc->dbh(), $new_username);
# 	if (defined $other_user->get_sp_person_id() &&
# 	    ($person -> get_sp_person_id() != $other_user->get_sp_person_id())) {
# 	    print STDERR "Username alread in use.\n";
# 	    $c->stash->{rest} = { error =>  "Username \"$new_username\" is already in use. Please select a different username." };
# 	    return;
# 	}
#
# 	$person->set_username($new_username);
# 	$person->store();
#     }
#
#     if ($args->{change_password}) {
# 	#unless change_password is set, new_password won't be in the args hash because of the prestore test
# 	my ($new_password, $confirm_password) = ($args->{new_password}, $args->{confirm_password});
# 	if(length($args->{new_password}) < 7) {
# 	    print STDERR "Password too short\n";
# 	    $c->stash->{rest} = { error => "Passwords must be at least 7 characters long. Please try again." };
# 	    return;
# 	}
# 	#format check
# 	if($args->{new_password} !~ /^[a-zA-Z0-9~!@#$^&*_.=:;<>?]+$/) {
# 	    print STDERR "Illegal characters in password\n";
# 	    $c->stash->{rest} = { error => "An error occurred. Please use your browser's back button to try again.. The Password can't contain spaces or these symbols: <u><b>` ( ) [ ] { } - + ' \" / \\ , |</b></u>." };
# 	    return;
# 	}
# 	if($args->{new_password} ne $args->{confirm_password}) {
# 	    print STDERR "Password don't match.\n";
# 	    $c->stash->{rest} = { error => "New password entries do not match. You must enter your new password twice to verify accuracy." };
# 	    return;
# 	}
#
# 	print STDERR "Saving new password to the database\n";
# 	$person->update_password($args->{new_password});
#     }
#
#     my $user_private_email = $c->user->get_private_email();
#     if($args->{change_email}) {
# 	#unless change_email is set, private_email won't be in the args hash because of the prestore test
# 	my ($private_email, $confirm_email) = ($args->{private_email}, $args->{confirm_email});
# 	if($private_email !~ m/^[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+$/) {
# 	    print STDERR "Invalid email address\n";
# 	    $c->stash->{rest} = { error => "An error occurred. Please use your browser's back button to try again. The E-mail address \"$private_email\" does not appear to be a valid e-mail address." };
# 	    return;
# 	}
# 	if($private_email ne $confirm_email) {
# 	    print STDERR "Emails don't match\n";
# 	    $c->stash->{rest} = { error => "An error occurred. Please use your browser's back button to try again. New e-mail address entries do not match. You must enter your new e-mail address twice to verify accuracy." };
# 	    return;
# 	}
#
# 	print STDERR "Saving private email '$private_email' to the database\n";
# 	$person->set_private_email($private_email);
# 	my $confirm_code = $self->tempname();
# 	$person->set_confirm_code($confirm_code);
# 	$person->store();
#
# 	$user_private_email = $private_email;
#
# 	$self->send_confirmation_email($args->{username}, $user_private_email, $confirm_code, $c->config->{main_production_site_url});
#
#     }
#
#     $c->stash->{rest} = { message => "Update successful" };
#
# }

# sub send_confirmation_email {
#     my ($self, $username, $private_email, $confirm_code, $host) = @_;
#     my $subject = "[SGN] E-mail Address Confirmation Request";
#
#     my $body = <<END_HEREDOC;
#
# You requested an account on the site $host.
#
# Please do *NOT* reply to this message. The return address is not valid.
# Use the contact form at $host/contact/form instead.
#
# This message is sent to confirm the private e-mail address for community user
# \"$username\".
#
# Please click (or cut and paste into your browser) the following link to
# confirm your account and e-mail address:
#
#   $host/user/confirm?username=$username&confirm=$confirm_code
#
# Thank you.
# Sol Genomics Network
# END_HEREDOC
#
#    CXGN::Contact::send_email($subject, $body, $private_email);
# }

# sub reset_password :Path('/rest/user/reset_password') Args(0) {
#     my $self = shift;
#     my $c = shift;
#
#     my $email = $c->req->param('password_reset_email');
#
#     my @person_ids = CXGN::People::Login->get_login_by_email($c->dbc->dbh(), $email);
#
#     if (!@person_ids) {
# 	$c->stash->{rest} = { error => "The provided email ($email) is not associated with any account." };
# 	return;
#     }
#
#     if (@person_ids > 1) {
# 	$c->stash->{rest} = { message => "The provided email ($email) is associated with multiple accounts. An email is sent for each account. Please notify the database team using the contact form to consolidate the accounts." };
#     }
#
#     my @reset_links;
#     my @reset_tokens;
#     foreach my $pid (@person_ids) {
#         my $email_reset_token = $self->tempname();
#         my $reset_link = $c->config->{main_production_site_url}."/user/reset_password_form?reset_password_token=$email_reset_token";
#         my $person = CXGN::People::Login->new( $c->dbc->dbh(), $pid);
#         $person->update_confirm_code($email_reset_token);
#         print STDERR "Sending reset link $reset_link\n";
#         $self->send_reset_email_message($c, $pid, $email, $reset_link);
#         push @reset_links, $reset_link;
#         push @reset_tokens, $email_reset_token;
#     }
#
#     $c->stash->{rest} = {
#         message => "Reset link sent. Please check your email and click on the link.",
#         reset_links => \@reset_links,
#         reset_tokens => \@reset_tokens
#     };
# }

# sub process_reset_password_form :Path('/rest/user/process_reset_password') Args(0) {
#     my $self = shift;
#     my $c = shift;
#
#     my $token = $c->req->param("token");
#     my $confirm_password = $c->req->param("confirm_password");
#     my $new_password = $c->req->param("new_password");
#
#     if (length($new_password) < 7) {
#         $c->stash->{rest} = { error => "Password is too short. Password must be 7 or more characters" };
#         $c->detach();
#     }
#
#     if ($confirm_password ne $new_password){
#         $c->stash->{rest} = { error => "Please enter the same password in the confirm password field!" };
#         $c->detach();
#     }
#
#     eval {
#         my $sp_person_id = CXGN::People::Login->get_login_by_token($c->dbc->dbh, $token);
#
#         my $login = CXGN::People::Login->new($c->dbc->dbh(), $sp_person_id);
#         $login->update_password($new_password);
#         $login->update_confirm_code("");
#     };
#     if ($@) {
#         $c->stash->{rest} = { error => $@ };
#     }
#     else {
#         $c->stash->{rest} = { message => "The password was successfully updated." };
#     }
# }


# sub send_reset_email_message {
#     my $self = shift;
#     my $c = shift;
#     my $pid = shift;
#     my $private_email = shift;
#     my $reset_link = shift;
#
#     my $subject = "[SGN] E-mail Address Confirmation Request";
#     my $main_url = $c->config->{main_production_site_url};
#
#     my $body = <<END_HEREDOC;
#
# Hi,
#
# you have requested a password reset on $main_url.
#
# If this request did not come from you, please let us know.
#
# To contact us, please do NOT reply to this message; rather, use the contact form ($main_url/contact/form) instead.
#
# Your password can be reset using the following link, which you can either click or cut and paste into your browser:
#
# $reset_link
#
# Thank you.
#
# Your friends at $main_url
#
# END_HEREDOC
#
#    CXGN::Contact::send_email($subject, $body, $private_email);
# }

sub tempname {
    my $self = shift;
    my $rand_string = "";
    my $dev_urandom = new IO::File "</dev/urandom" || print STDERR "Can't open /dev/urandom";
    $dev_urandom->read( $rand_string, 16 );
    my @bytes = unpack( "C16", $rand_string );
    $rand_string = "";
    foreach (@bytes) {
        $_ %= 62;
        if ( $_ < 26 ) {
            $rand_string .= chr( 65 + $_ );
        }
        elsif ( $_ < 52 ) {
            $rand_string .= chr( 97 + ( $_ - 26 ) );
        }
        else {
            $rand_string .= chr( 48 + ( $_ - 52 ) );
        }
    }
    return $rand_string;
}

sub get_login_button_html :Path('/rest/user/login_button_html') Args(0) {
    my $self = shift;
    my $c = shift;

#    my $logout =  $c->req->param("logout");

    select(STDERR);
    $|=1;

    my $html = "";



#     if ($logout eq "yes") {
# 	    print STDERR "generating login button for logout...\n";
# 	    $html = <<HTML;
#     <li class="dropdown">
#     <div class="btn-group" role="group" aria-label="..." style="height:34px; margin: 1px 0px 0px 0px" >
# 	<a href="/user/login">
#           <button id="logouclass="btn btn-primary" type="button" style="margin: 7px 7px 0px 0px">Login</button>
# 	</a>
#       </div>
#   </li>
# HTML

# 	    $c->stash->{rest} = { html => $html };
# 	    return;

#     }

    if ( $c->config->{disable_login} ) {
	$html =  '<div class="btn-group" role="group" aria-label="..." style="height:34px; margin: 1px 0px 0px 0px" > <button class="btn btn-primary disabled" type="button" style="margin: 7px 7px 0px 0px">Login</button> </div>';


	$c->stash->{rest} = { html => $html };
	return;
    }

    if( $c->config->{'is_mirror'} ) {
	my $production_site = $c->config->{main_production_site_url};

	# if the site is a mirror, gray out the login/logout links
	#
	print STDERR "generating login button for mirror site...\n";
	$html = qq| <a style="line-height: 1.2; text-decoration: underline; background: none" href="$production_site" title="log in on main site">main site</a> |;

	$c->stash->{rest} = { html => $html };
	return;
    }

    if ( $c->user() ) {
	print STDERR "Generate login button for logged in user...\n";
	my $sp_person_id = $c->user->get_object->dbuser_id();
	my $username = $c->user->id();
  my $welcome_sign = "Hi, ".$c->user->get_object()->first_name();
	my $display_name = qq(

  <nav class="navbar navbar-expand-lg navbar-light bg-white">

    <div class="collapse navbar-collapse" id="navbarNavDropdown_login">
      <ul class="navbar-nav">
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle header_link" style="color:lightblue;" href="/browse" id="navbarDropdownMenuLink_3" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            $welcome_sign
          </a>
          <div class="dropdown-menu" aria-labelledby="navbarDropdownMenuLink">
            <a class="dropdown-item" id="access_your_profile_button" href="/user/$sp_person_id/profile">Your Profile</a>
            <a class="dropdown-item"><button id="navbar_logout" class="btn btn-primary" type="button" onclick="logout();" title="Logout">Logout</button></a>

          </div>
        </li>
      </ul>
    </div>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
  <span class="navbar-toggler-icon"></span>
  </button>

  </nav>


  );

  $html = $display_name;


	print STDERR "GENERATED HTML = $html\n";
	$c->stash->{rest} = { html => $html };
	return;

    }

    ### Generate regular login button

    print STDERR "generating regular login button..\n";
    $html = qq | <button id="site_login_button" name="site_login_button" class="btn btn-primary" type="button">Login</button> |;

       $c->stash->{rest} = {
	html => $html, logged_in => $c->user_exists
       };

}

# sub quick_create_user :Path('/rest/user/quick_create_account') Args(0) {
#     my $self = shift;
#     my $c = shift;
#
#      if (!$c->user()) {
# 	$c->stash->{rest} = { error => "Need to be logged in to use feature." };
# 	return;
#     }
#
#     if (!$c->user()->check_roles("curator")) {
# 	$c->stash->{rest} = { error => "You don't have the privileges to use this feature" };
# 	return;
#     }
#     my $logged_in_person_id = $c->user()->get_sp_person_id();
#
#     my $logged_in_user=CXGN::People::Person->new($c->dbc->dbh(), $logged_in_person_id);
#     $logged_in_person_id=$logged_in_user->get_sp_person_id();
#     my $logged_in_username=$logged_in_user->get_first_name()." ".$logged_in_user->get_last_name();
#     my $logged_in_user_type=$logged_in_user->get_user_type();
#
#     my ($username, $password, $confirm_password, $email_address, $new_user_type, $first_name, $last_name) =
# 	map { print STDERR $_." ".$c->req->param($_)."\n"; $c->req->param($_) } qw | username password confirm_password confirm_email user_type first_name last_name |;
#
#     print STDERR "$username, $password, $confirm_password, $email_address, $new_user_type, $first_name, $last_name\n";
#
#     my $new_user_login=CXGN::People::Login->new($c->dbc->dbh);
#
#     if ($username) {
#         my @fail=();
#
# 	if(length($username)<7){push @fail,"Username is too short. Username must be 7 or more characters";}
#         my $existing_login=CXGN::People::Login->get_login($c->dbc->dbh, $username);
#
#         if($existing_login->get_username()){push @fail,"Username \"$username\" is already in use. Please pick a different us
# ername.";}
#
# 	if(length($password)<7){push @fail,"Password is too short. Password must be 7 or more characters";}
#
# 	if("$password" ne "$confirm_password"){push @fail,"Password and confirm password do not match.";}
#
# 	if($password eq $username){push @fail,"Password must not be the same as your username.";}
#
# 	if($new_user_type ne 'user' and $new_user_type ne 'sequencer' and $new_user_type ne 'submitter'){
# 	    push @fail,"Sorry, but you cannot create user of type \"$new_user_type\" with web interface.";}
#         if(@fail)
#         {
#             my $fail_str="";
#             foreach(@fail)
#             {
#                 $fail_str .= "<li>$_</li>\n"
#             }
# 	    $c->stash->{rest} = { error => $fail_str };
# 	    return;
#
#         }
#     }
#
#     eval {
# 	$new_user_login->set_username(encode_entities($username));
# 	$new_user_login->set_password($password);
# 	$new_user_login->set_private_email(encode_entities($email_address));
# 	$new_user_login->set_user_type(encode_entities($new_user_type));
# 	$new_user_login->store();
# 	my $new_user_person_id=$new_user_login->get_sp_person_id();
# 	my $new_user_person=CXGN::People::Person->new($c->dbc->dbh, $new_user_person_id);
# 	$new_user_person->set_first_name(encode_entities($first_name));
# 	$new_user_person->set_last_name(encode_entities($last_name));
# 	##removed. This was causing problems with creating new accounts for people,
# 	##and then not finding it in the people search.
# 	#$new_user_person->set_censor(1);#censor by default, since we are creating this account, not the person whose info might be displayed, and they might not want it to be displayed
# 	$new_user_person->store();
#     };
#
#     if ($@) {
# 	$c->stash->{rest} = { html => "An error occurred. $@" };
#     }
#     else {
# 	$c->stash->{rest} = { html => "<center><h4>Account successfully created for $first_name $last_name</h4><a href=\"/user/admin/quick_create_account\">Create another account" };
#     }
# }

sub user :Chained('/') :PathPart('rest/user') CaptureArgs(1){
  my $self = shift;
  my $c = shift;

  if (!$c->user()) {
    $c->stash->{rest} = { error => "Sorry, you need to be logged in." };
    return;
 }

  my $dbuser_id = shift;

  $c->stash->{dbuser_id} = $dbuser_id;
}

sub profile :Chained('user') :PathPart('profile') Args(0){
  my $self = shift;
  my $c = shift;

  if (!$c->user()) {
    $c->stash->{rest} = { error => "Sorry, you need to be logged in to view user profiles." };
    return;
 }

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find( {dbuser_id => $c->stash->{dbuser_id}} );

  if (!$rs){
    $c->stash->{rest} = {error => "Sorry, this user does not exist."};
  } else {
    my $user_type;
    if ($rs->user_type() eq "curator"){$user_type = "Curator";}
    else {$user_type = "Standard User";}

    my $data;
    $data->{first_name} = $rs->first_name();
    $data->{last_name} = $rs->last_name();
    $data->{full_name} = $rs->first_name()." ".$rs->last_name();
    $data->{email_address} = $rs->email();
    $data->{username} = $rs->username();
    $data->{user_role} = $user_type;
    $data->{organization} = $rs->organization();

    $c->stash->{rest} = {data => $data};
  }

}

sub authored_smids :Chained('user') :PathPart('authored_smids') Args(0){
  my $self = shift;
  my $c = shift;

  if (!$c->user()) {
    $c->stash->{rest} = { error => "Sorry, you need to be logged in to view user profiles." };
    return;
 }

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search( {dbuser_id => $c->stash->{dbuser_id}} );
  my @data;
  while (my $r = $rs->next()){

    next if (!SMMID::Authentication::ViewPermission::can_view_smid($c->user(), $r, $c->model("SMIDDB")));

    my $formula_subscripts = $r->formula();
    $formula_subscripts =~ s/(\d+)/\<sub\>$1\<\/sub\>/g;

    push @data, ["<a href=\"/smid/".$r->compound_id()."\">".$r->smid_id()."</a>", $formula_subscripts, $r->molecular_weight(), $r->curation_status(), $r->public_status() ];
  }
  $c->stash->{rest} = {data => \@data};
}

sub authored_experiments :Chained('user') :PathPart('authored_experiments') Args(0){
  my $self = shift;
  my $c = shift;

  if (!$c->user()) {
    $c->stash->{rest} = { error => "Sorry, you need to be logged in to view user profiles." };
    return;
 }

  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::Experiment")->search( {'me.dbuser_id' => $c->stash->{dbuser_id} }, {join => 'compound'} );
  my @data;

  while (my $r = $rs->next()){

    next if (!SMMID::Authentication::ViewPermission::can_view_smid($c->user(), $r->compound(), $c->model("SMIDDB")));

    my $experiment_type;
    if ($r->experiment_type() eq "hplc_ms"){
      $experiment_type = "HPLC-MS";
    } else {
      $experiment_type = "MS/MS";
    }

    push @data, [$experiment_type, "<a href=\"/smid/".$r->compound_id()."\">".$r->compound()->smid_id()."</a>"];
  }
  $c->stash->{rest} = {data => \@data};
}

sub change_profile :Chained('user') :PathPart('change_profile') Args(0) {

  my $self = shift;
  my $c = shift;

  my $error = "";

  my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find( {dbuser_id => $c->stash->{dbuser_id}} );

  if (!$c->user() || $c->user()->dbuser_id() != $c->stash->{dbuser_id}){
    $c->stash->{rest} = { error => "Sorry, you need to have a valid login to edit user data." };
    return;
  }

  print STDERR "Found user profile editor...\n";

  my $first_name = $self->clean($c->req->param("first_name"));
  my $last_name = $self->clean($c->req->param("last_name"));
  my $email_address = $self->clean($c->req->param("email_address"));
  my $organization = $self->clean($c->req->param("organization"));
  my $username = $self->clean($c->req->param("username"));

  if (length($first_name) == 0){$error .= "First name may not be blank. ";}
  if (length($last_name) == 0){$error .= "Last name may not be blank. ";}
  if (length($email_address) == 0){$error .= "Email may not be blank. ";}
  #if (length($organization) == 0){$error .= "Organization may not be blank. ";}
  if (length($username) == 0){$error .= "Username may not be blank. ";}

  if ($error) {
    $c->stash->{rest} = { error => $error };
    return;
  }

  my $data;
  $data->{first_name} = $first_name;
  $data->{last_name} = $last_name;
  $data->{email} = $email_address;
  $data->{username} = $username;
  $data->{organization} = $organization;


  eval{
    $row->update($data);
    print STDERR "Updated user profile.\n";
  };

  if ($@) {
      $c->stash->{rest} = {success => 0};
  } else {
      $c->stash->{rest} = {success => 1};
  }

}

sub change_password :Chained('user') :PathPart('change_password') Args(0) {

  my $self = shift;
  my $c = shift;

  my $error = "";

  my $dbuser_id = $c->stash->{dbuser_id};

  my $row = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find( {dbuser_id => $dbuser_id} );

  if (!$c->user() || $c->user()->get_object()->dbuser_id() != $dbuser_id){
    $c->stash->{rest} = { error => "Sorry, you need to have a valid login to edit user data." };
    return;
  }

  my $old_password = $self->clean($c->req->param("old_password"));
  my $new_password = $self->clean($c->req->param("new_password"));
  my $new_password_confirm = $self->clean($c->req->param("new_password_confirm"));

  my $login = SMMID::Login->new( { schema => $c->model("SMIDDB")->schema() } );
  my $current_user = $login->user_from_credentials($c->user()->get_object()->username(), $old_password);
  if (!$current_user){$error .= "Incorrect password. ";}
  if (length($new_password) < 7){$error .= "New password must be at least 7 characters long. ";}
  if ($new_password ne $new_password_confirm){$error .= "Please confirm that the new password is entered twice. ";}

  if ($error) {
    $c->stash->{rest} = { error => $error };
    return;
  }


  my $masked_new_password = $login->schema()->storage->dbh()->prepare("UPDATE dbuser SET password=crypt(?, gen_salt('bf')) WHERE dbuser_id=?");
  $masked_new_password->execute($new_password, $dbuser_id);

  if ($@) {
      $c->stash->{rest} = {success => 0};
  } else {
      $c->stash->{rest} = {success => 1};
  }
}

sub group_data :Chained('user') :PathPart('group_data') Args(0){
  my $self = shift;
  my $c = shift;

  my $dbuser_id = $c->stash->{dbuser_id};

  #Query database for the groups that this user has, then put them here. List the name of the group, list of members, and list of smids

  print STDERR "Accessing user's groups...\n";

  my @group_data;
  my $data;


  my $int = 0;
  my $rs = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->search({dbuser_id => $dbuser_id});
 #rs contains a list of all the groups that this user is in.
  while (my $row = $rs->next()){
    my $group = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbgroup")->find({dbgroup_id => $row->dbgroup_id()});
    my $members = $c->model("SMIDDB")->resultset("SMIDDB::Result::DbuserDbgroup")->search({dbgroup_id => $row->dbgroup_id()});
    my $smids = $c->model("SMIDDB")->resultset("SMIDDB::Result::Compound")->search({dbgroup_id => $row->dbgroup_id()});

    my @member_list;
    while (my $ur = $members->next()){
      my $member = $c->model("SMIDDB")->resultset("SMIDDB::Result::Dbuser")->find({dbuser_id => $ur->dbuser_id()});
      push @member_list, "<a href=\"/user/".$member->dbuser_id()."/profile\">".$member->first_name()." ".$member->last_name()."</a>";
    }
    my $member_string = join(", ", @member_list);

    my $smid_table = "<table id=smid_list_$int class='display' style='width:\"100%\"'>";

    while(my $smid = $smids->next()){
      next if (!SMMID::Authentication::ViewPermission::can_view_smid($c->user(), $smid, $c->model("SMIDDB")));
      my $formula_subscripts = $smid->formula();
      $formula_subscripts =~ s/(\d+)/\<sub\>$1\<\/sub\>/g;
      $smid_table .= "<tr>";
      $smid_table .= "<td><a href=\"/smid/".$smid->compound_id()."\" >".$smid->smid_id()."</a></td><td>".$formula_subscripts."</td><td>".$smid->molecular_weight()."</td><td>".$smid->curation_status()."</td><td>".$smid->public_status()."</td>";
      $smid_table .= "</tr>";
    }

    push @group_data, [$group->name(), $group->description(), $member_string, $smid_table];
    $int = $int + 1;
  }

  $data->{group_data} = \@group_data;
  $data->{num_smid_tables} = $int;

  $c->stash->{rest} = {data => $data};
}


1;
