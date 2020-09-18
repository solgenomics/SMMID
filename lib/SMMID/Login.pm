
=head1 NAME

SMMID::Login - deal with browser site login

=head1 DESCRIPTION

This is an object which handles logging users in and out of our sites.

=head1 EXAMPLES

    #example 1
    #kick user out if they are not logged in. if they are not logged in, your code will exit here and they will be sent to the login page.
    #if they are logged in, you will get their person id and your code will continue to execute.
    my $person_id=CXGN::Login->new()->verify_session();

    #example 2
    #kick user out if they are not logged in. if they are not logged in, your code will exit here and they will be sent to the login page.
    #if they are logged in, you will get their person id and user type and your code will continue to execute.
    my($person_id,$user_type)=CXGN::Login->new($dbh)->verify_session();

    #example 3
    #let everyone view this page, but if they are logged in, get their person id so you can give them a customized page. your code will
    #continue execution after this line no matter what.
    my $person_id=CXGN::Login->new($dbh)->has_session();

    #example 4
    #let everyone view this page, but if they are logged in, get their person id and user type so you can give them a customized page.
    #your code will continue execution after this line no matter what.
    my($person_id,$user_type)=CXGN::Login->new($dbh)->has_session();

=head1 AUTHOR

John Binns <zombieite@gmail.com>

=cut

package SMMID::Login;

use Moose;

use Digest::MD5 qw(md5);
use String::Random;
use DateTime;
use DateTime::Format::ISO8601;

our $LOGIN_COOKIE_NAME = 'smmid_session_id';
our $LOGIN_PAGE        = '/user/login';
our $LOGIN_TIMEOUT     = 7200;                    #seconds for login to timeout
our $DBH;
our $EXCHANGE_DBH = 1;

has 'schema' => ( isa => 'Ref', is => 'rw');

has 'disable_login' => ( isa => 'Bool', is =>'rw' );

has 'is_mirror' => ( isa => 'Bool', is => 'rw' );

has 'cookie_string' => (isa => 'Str', is => 'rw');

has 'login_info' => (isa => 'HashRef', is => 'rw');

has 'login_cookie' => (isa => 'Str', is => 'rw');



=head2 constructor new()

 Usage:        my $login = SMMID::Login->new( { schema => $schema, cookie_string )
 Desc:         creates a new login object
 Ret:          
 Args:         a database handle
 Side Effects: connects to database
 Example:

=cut

=head2 get_login_status

 Usage:        my %logged_in_status = $login -> get_login_status();
 Desc:         a member function. This was changed on 5/1/2009.
 Ret:          a hash with user_type as a key and count of logins as a value
 Args:         none
 Side Effects: accesses the database
 Example:

=cut

sub get_login_status {
    my $self = shift;

    my $sth = $self->get_sql("stats_aggregate");

    
    $sth->execute($LOGIN_TIMEOUT);

    my %logins = ();
    while ( my ( $user_type, $count ) = $sth->fetchrow_array() ) {
        $logins{$user_type} = $count;
    }
    if ( !$logins{curator} )   { $logins{curator}   = "none"; }
    if ( !$logins{submitter} ) { $logins{submitter} = "none"; }
    if ( !$logins{user} )      { $logins{user}      = "none"; }

    $sth = $self->get_sql("stats_private");
    $sth->execute($LOGIN_TIMEOUT);

    $logins{detailed} = {};
    while ( my ( $user_type, $username, $contact_email ) =
        $sth->fetchrow_array() )
    {
        $logins{detailed}->{$user_type}->{$username}->{contact_email} =
          $contact_email;
    }

    if (wantarray) {
        return %logins;
    }
    else {
        return \%logins;
    }
}

# =head2 get_login_info

#  Usage:         $login->get_login_info()
#  Desc:
#  Ret:
#  Args:
#  Side Effects:
#  Example:

# =cut

# sub get_login_info {
#     my $self = shift;
#     return $self->{login_info};
# }

=head2 verify_session

 Usage:        $login->verify_session($user_type)
 Desc:         checks whether a user is logged in currently and 
               is of the minimum user type $user_type. 
               user types have the following precedence:
               user < submitter < sequencer < curator
 Ret:          the person_id, if a session exists
 Args:         a minimum user type required to access the page
 Side Effects: redirects the website to the login page if no login
               is currently defined.
 Example:

=cut

sub verify_session {
    my $self = shift;
    my ($user_must_be_type) = @_;
    my ( $person_id, $user_type ) = $self->has_session();
    if ($person_id) {    #if they have a session
        if ($user_must_be_type)
        {                #if there is a type that they must be to view this page

            if ( $user_must_be_type ne $user_type )
            {            #if they are not the required type, send them away

                return;
            }
        }
    }
    else {               #else they do not have a session, so send them away

        return;
    }
    if (wantarray)
    { #if they are trying to get both pieces of info, give it to them, in array context

        return ( $person_id, $user_type );
    }
    else {    #else they just care about the login id

        return $person_id;
    }
}

=head2 has_session ()

if the user is not logged in, the return value is false;
else it's the person ID if in scalar context, or (person ID, user type) in array context

=cut

sub has_session {
    my $self = shift;

    print STDERR "has_session()...\n";
    #if people are not allowed to be logged in, return
    if ( !$self->login_allowed() ) {
	print STDERR "LOGIN NOT ALLOWED.\n";
        return;
    }

    #if they have no cookie, they are not logged in
    unless ($self->cookie_string()) {
	print STDERR "NO COOKIE\n";
        return;
    }
    else {
	print STDERR "We have a cookie (".$self->cookie_string().")!!!\n";
    }

    my ( $dbuser_id, $user_type, $user_prefs, $expired ) =
      $self->query_from_cookie($self->cookie_string());

    #if cookie string is not found, they are not logged in
    unless ( $dbuser_id ) {
	print STDERR "We have no person id and user type( $dbuser_id)\n";
        return;
    }

    #if their cookie is good but their timestamp is old, they are not logged in
    if ($expired) {
	print STDERR "The cookie is expired. Sorry!\n";
        return;
    }

    ################################
    # Ok, they are logged in! yay! #
    ################################

    my $login_info = { 
	person_id => $dbuser_id,
	cookie_string => $self->cookie_string(),
	user_type => $user_type,
    };

    #$self->set_login_info($login_info);

    $self->update_timestamp($dbuser_id);

#if they are trying to get both pieces of info, give it to them, in array context
    if (wantarray) {
        return ( $dbuser_id, $user_type );
    }

    #or they just care about the login id
    else {
        return $dbuser_id;
    }
}

sub query_from_cookie {
    my $self          = shift;
    my $cookie_string = shift;

    my @result = (undef, undef, undef, undef);
    
    
    my $row = $self->user_from_cookie_string();

    my $expired = 0;
    if ($row && $self->cookie_string()) { 
	
	@result = ($row->dbuser_id(), $row->user_type(), $row->user_prefs(), $row->last_access_time());

	if ($result[2]) { 
	    my $iso8601 = DateTime::Format::ISO8601->new;
	    my $last_access_time = $iso8601->parse_datetime( $result[2] );
	    
	    my $current_time = DateTime->now();
	    
	    my $seconds_since_last_login = $current_time->epoch()-$last_access_time->epoch();
	    
	    print STDERR "SECONDS SINCE LAST LOGIN : $seconds_since_last_login\n";
	    if ($seconds_since_last_login > $LOGIN_TIMEOUT) {
		print STDERR "LOGOUT IS EXPIRED!\n";
		$expired =1;
	    }
	}
	

    }
    
    if (wantarray) {
        return ($result[0], $result[1], $result[2], $expired);
    }
    else {
        return $row->dbuser_id();
    }
}

sub user_from_cookie_string {
    my $self = shift;
    
    my $row = $self->schema()->resultset('SMIDDB::Result::Dbuser')->find( { cookie_string => $self->cookie_string() } );
    
    if (!$row) { return; }

    else {
	return $row;
    }

}

sub user_from_credentials {
    my $self = shift;
    my $username = shift;
    my $password = shift;

    my $encoded_password_h = $self->schema()
	->storage
	->dbh()
	->prepare("SELECT crypt('$password', gen_salt('bf'))");

    $encoded_password_h->execute($password);

    my ($encoded_password) = $encoded_password_h->fetchrow_array();
	
    print STDERR "ENCODED PASSWORD = $encoded_password\n";

    if ($username) { 
	
	my $row = $self->schema()->resultset("SMIDDB::Result::Dbuser")->find( { username => { ilike => $username },  password => $encoded_password } );
	
	return $row;
    }
    return undef;
}

sub exists_user {
    my $self = shift;
    my $username = shift;

    if ($username) { 
	my $row = $self->schema()->resultset("SMIDDB::Result::Dbuser")->find( { username => { ilike => $username } }  );
	
	if ($row) {
	    return $row;
	}
	else {
	    return 0;
	}
    }
    return 0;

}

sub login_allowed {
    my $self = shift;

#conditions for allowing logins:
#
#    1. configuration 'disable_login' must be 0 or undef
#    2. configuration 'is_mirror' must be 0 or undef
#    3. configuration 'dbname' must not be 'sandbox' if configuration 'production_server' is 1
#     -- the reason for this is that if users can log in, they must be able to log in to the REAL database,
#        not some mirror or some sandbox, because logged-in users can CHANGE data in the database and we
#        don't want to lose or ignore those changes.
    if (
            !$self->disable_login() 
        and !$self->is_mirror()

#we haven't decided whether it's a good idea to comment this next line by default -- Evan
#        and !(
#                $self->{conf_object}->get_conf('dbname') =~ /sandbox/
#            and $self->{conf_object}->get_conf('production_server')
#        )
      )
    {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 login_user

 Usage:        $login->login_user($username, $password);
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub login_user {
    my $self = shift;
    my $username = shift;
    my $password = shift;

    print STDERR "Logging in user $username with password XXXXXXXX\n";
    my $login_info;    #information about whether login succeeded, and if not, why not

    if ( ! $username) {
	$login_info->{error} = "Please provide a username.";
    }

    elsif (! $password) {
	$login_info->{error} = "Please provide a password.";
    }
    else { 

	my $row = $self->user_from_credentials($username, $password);

	print STDERR "NOW LOGGING IN USER $username\n";
        #my $num_rows = $sth->execute( $username, $password );
	if (! $row) {
	    $login_info->{error} = "Incorrect password or user information.";
	    return $login_info;
	}

	#my ( $person_id, $disabled, $user_prefs, $first_name, $last_name ) = $sth->fetchrow_array();
	my ( $person_id, $disabled, $user_prefs, $first_name, $last_name ) = (
	    $row->dbuser_id,
	    $row->disabled,
	    $row->first_name,
	    $row->user_prefs,
	    $row->last_name,
	    );

	print STDERR "FOUND: $person_id\n";
#        if ( $num_rows > 1 ) {
#            die "Duplicate entries found for username '$username'";
#        }
        if ($disabled) {
            $login_info->{account_disabled} = $disabled;
        }
        else {
	    print STDERR "Generating new login cookie...\n";
            $login_info->{user_prefs} = $user_prefs;
            if ($person_id) {
                my $new_cookie_string =
                  String::Random->new()
                  ->randpattern(
"ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
                  );
		my $row = $self->schema()->resultset("SMIDDB::Result::Dbuser")->find( { dbuser_id => $person_id });
		$row->update( 
		    {
			cookie_string => $new_cookie_string
		    });
		
		$login_info->{person_id}     = $person_id;
		$login_info->{first_name}     = $first_name;
		$login_info->{last_name}     = $last_name;
		$login_info->{cookie_string} = $new_cookie_string;
            }
            else {
                $login_info->{incorrect_password} = 1;
            }
        }
    }

    $self->{login_info} = $login_info;
    return $login_info;
}

=head2 function logout_user()

 Usage:        $login->logout_user();
 Desc:         log out the current logged in user
 Ret:          nothing  
 Args:         none
 Side Effects: resets the cookie to empty
 Example:

=cut

sub logout_user {
    my $self   = shift;
    my $cookie = $self->cookie_string();
    if ($cookie) {

	    my $row = $self->schema()->resultset("Dbuser")->find( { cookie_string => $cookie });

	$row->update( { cookie_string => "", last_access_time => $self->now() });

	# controller needs to set the cookie
        ###CXGN::Cookie::set_cookie( $LOGIN_COOKIE_NAME, "" );
    }
}

=head2 update_timestamp

 Usage:        $login->update_timestamp();
 Desc:         updates the timestamp, such that users don't 
               get logged out when they are active on the site.
 Ret:          nothing
 Args:         none
 Side Effects: accesses the database to change the timeout status.
 Example:

=cut

sub update_timestamp {
    my $self   = shift;
    my $dbuser_id = shift;
    
    my $cookie = $self->cookie_string();
    if ($cookie) {
        # my $sth = $self->get_sql("refresh_cookie");
	
        #   "	UPDATE 
	# 			sgn_people.sp_person 
	# 		SET 
	# 			last_access_time=current_timestamp 
	# 		WHERE 
	# 			cookie_string=?",
	
	my $row = $self->schema()->resultset("SMIDDB::Result::Dbuser")->find( { dbuser_id => $dbuser_id });
	$row->update( { last_access_time => $self->now() });
	
    }
}


sub now {
    my $self = shift;
    my $now = DateTime->now();
    return $now->ymd()."T".$now->hms();
}

# =head2 get_login_cookie

#  Usage:        my $cookie = $login->get_login_cookie();
#  Desc:         returns the cookie for the current login
#  Args:         none
#  Side Effects: 
#  Example:

# =cut

# sub get_login_cookie {
#     my $self = shift;
#     return CXGN::Cookie::get_cookie($LOGIN_COOKIE_NAME);
# }

=head2 login_page_and_exit
##DEPRECATED: redirect should happen in a catalyst controller, not in an object like CXGN::Login

 Usage:        $login->login_page_and_exit();
 Desc:         redirects to the login page.
 Ret:
 Args:
 Side Effects:
 Example:

=cut

#sub login_page_and_exit {
#    my $self = shift;
    #CGI redirect crashes server when used from a catalyst controller.
    #Redirecting should happen in controller, not in an object like CXGN::Login
    #print CGI->new->redirect( -uri => $LOGIN_PAGE, -status => 302 );
    #exit;
#}

###
### helper function. SQL should probably be moved to the CXGN::People::Login class
###

sub set_sql {
    my $self = shift;

    $self->{queries} = {

        user_from_cookie =>    #send: session_time_in_secs, cookiestring

          "	SELECT 
				sp_person_id,
				sgn_people.sp_roles.name as user_type,
				user_prefs,
				extract (epoch FROM current_timestamp-last_access_time)>? AS expired 
			FROM 
				sgn_people.sp_person JOIN sgn_people.sp_person_roles using(sp_person_id) join sgn_people.sp_roles using(sp_role_id) 
			WHERE 
				cookie_string=?
                        ORDER BY sp_role_id
                        LIMIT 1",

        user_from_uname_pass =>

           "	SELECT 
				sp_person_id, disabled, user_prefs, first_name, last_name
			FROM 
				sgn_people.sp_person 
			WHERE 
				UPPER(username)=UPPER(?) 
				AND (sp_person.password = crypt(?, sp_person.password))",

        cookie_string_exists =>

          "	SELECT 
				cookie_string 
			FROM 
				sgn_people.sp_person 
			WHERE 
				cookie_string=?",

        login =>    #send: cookie_string, sp_person_id

          "	UPDATE 
				sgn_people.sp_person 
			SET 
				cookie_string=?,
				last_access_time=current_timestamp 
			WHERE 
				sp_person_id=?",

        logout =>    #send: cookie_string

          "	UPDATE 
				sgn_people.sp_person 
			SET 
				cookie_string=null,
				last_access_time=current_timestamp 
			WHERE 
				cookie_string=?",

        refresh_cookie =>    #send: cookie_string  (updates the timestamp)

          "	UPDATE 
				sgn_people.sp_person 
			SET 
				last_access_time=current_timestamp 
			WHERE 
				cookie_string=?",

        stats_aggregate => #send:  session_timeout_in_secs (gets aggregate login data)

          "	SELECT  
				sp_roles.name, count(*) 
			FROM 
				sgn_people.sp_person
                        JOIN    sgn_people.sp_person_roles USING(sp_person_id)
                        JOIN    sgn_people.sp_roles USING(sp_role_id)
           
			WHERE 
				last_access_time IS NOT NULL 
				AND cookie_string IS NOT NULL 	
				AND extract(epoch from now()-last_access_time)<? 
			GROUP BY 	
				sp_roles.name",

        stats_private => #send: session_timeout_in_secs (gets all logged-in users)

          "	SELECT 
				sp_roles.name as user_type, username, contact_email 
			FROM 
				sgn_people.sp_person JOIN sgn_people.sp_person_roles using(sp_person_id) JOIN sgn_people.sp_roles using (sp_role_id)
			WHERE 
				last_access_time IS NOT NULL 
				AND cookie_string IS NOT NULL	
				AND extract(epoch from now()-last_access_time)<?",

    };

    while ( my ( $name, $sql ) = each %{ $self->{queries} } ) {
        $self->{query_handles}->{$name} = $self->get_dbh()->prepare($sql);
    }

}

sub get_sql {
    my $self = shift;
    my $name = shift;
    return $self->{query_handles}->{$name};
}

###
1;    #do not remove
###

