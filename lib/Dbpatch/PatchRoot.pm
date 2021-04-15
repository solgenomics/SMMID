
package Dbpatch::PatchRoot;

use Moose;

extends 'Dbpatch::Common';

use DBI;
use SMIDDB;
use Dbpatch;
use Text::Table;


has 'name' => (    #name of the dbpatch
    is     => 'rw',
    isa    => 'Str',
		   default => sub { return __PACKAGE__; }
		   
    );

has 'description' => (
    is => 'rw',
    isa => 'Str',
    );


    
sub init_patch {
    #print STDERR "init_patch() needs to be implemented in the subclass.\n";
}

sub patch {
    #print STDERR "patch() needs to be implemetned in the subclass.\n";
}


sub run {
    my $self = shift;

    print STDERR "Connecting to database ".$self->dbname()." on host ".$self->dbhost()."...\n";
    
    $self->init_patch;  #override this in the child class

    my $dbh =  DBI->connect('dbi:Pg:host='.$self->dbhost().";database=".$self->dbname(), 
			    $self->dbuser(),
			    $self->dbpass(),
			    { AutoCommit => 0, RaiseError => 1}
        );

    $dbh->{AutoCommit} = 1;

    $self->dbh($dbh);

    my $dbpatch_schema = Dbpatch->connect( sub { return $dbh; } );
    $self->schema($dbpatch_schema);


    
    my $rs;
    eval { 
	$rs = $dbpatch_schema->resultset('Dbpatch')->search( { name => $self->name() });
	if ($rs->count > 0) {
	    print STDERR "Dbpatch has already been run in ".$rs->next()->run_timestamp()."\n";
	}
    };

    
    
    if (defined($@) && $@ =~ m/does not exist/) {
	print STDERR "$@ ... Inserting dbpatch table...\n";
	$dbh->do("CREATE TABLE dbpatch (dbpatch_id serial primary key, dbuser_id bigint references dbuser, name varchar(100), description text, prereqs text, run_timestamp timestamp without time zone not null default now() )");
    }
    elsif ($@) {
	die "Can't continue: $@\n";
    }

    print STDERR "LIST : ".$self->list()."\n";
    if ($self->list()) {
	print STDERR "LIST HERE...\n";
	$self->list_installed_dbpatches();
	exit();
    }

    if ($self->list_files()) {
	my @dbpatches = get_dbpatch_files();
	print "AVAILABLE DBPATCH FILES:\n";
	print "------------------------\n";
	print join("\n", @dbpatches)."\n";
	exit();
    }

     if ($self->update()) {
	$self->run_all_patches();
	exit();
    }



    
    
    #CREATE A METADATA OBJECT and a new metadata_id in the database for this data

    ## patch method defined in subclass :-)
    #
    if (__PACKAGE__ ne 'Dbpatch::PatchRoot') { 
	print STDERR "RUNNING PATCH FOR ".__PACKAGE__."\n";
	my $error = $self->patch;
	if ($error ne '1') {
	    print "Failed! Rolling back! \n $error \n ";
	    #exit();
	} elsif ( $self->trial_mode) {
	    print "Trial mode! Not storing new metadata and dbversion rows\n";
	} else {
	    print STDERR "Adding patch info to dbpatch table...\n";
	    $dbpatch_schema->resultset("Dbpatch::Result::Dbpatch")->create(
		{
		    name => $self->name(),
		    description => $self->description(),
		});
	}
    }
}


sub list_installed_dbpatches {
    my $self = shift;
    print STDERR "LIST DB PATCHES\n";

    my $tb = Text::Table->new( "Name",  \' | ',  "Description",  \' | ', "Run_date",  \' | ', "Operator", \' |');

    my %not_installed_files = ();
    my @available_dbpatch_files  = get_dbpatch_files();
    foreach my $dpf (@available_dbpatch_files ) {
	$not_installed_files{$dpf} = 1;
    }

    my $rs = $self->schema()->resultset('Dbpatch')->search( { });
    my @lines;
    while (my $row = $rs->next()) {
	$not_installed_files{$row->name()} = 0;
	$tb->add( $row->name, $row->description,  $row->run_timestamp,  $row->dbuser_id );
	

    }

    foreach my $k (%not_installed_files) {
	if ($not_installed_files{$k} == 1) {
	    $tb->add($k, "-", "-", "-" );
	}
    }
    my $rule = $tb->rule('-','+');
    
    print $rule, $tb->title(), $rule, $tb->body(), $rule."\n";
}

sub get_dbpatch_files {
    my $self = shift;
    my $full_paths = shift;
    
    my @dbpatches = glob 'dbpatches/*/*.pm';

    foreach my $dbp (@dbpatches) {
	if (! $full_paths ) { $dbp =~ s/.*\/(.*?).pm/$1/; }
    }
    return @dbpatches;
}

sub run_all_patches {
    my $self = shift;

    # determine the uninstalled files
    #
    my %installed_patches;
    my %installed_patches_paths;
    my @available_dbpatch_files  = $self->get_dbpatch_files(1);
    foreach my $dbp (@available_dbpatch_files ) {
	print STDERR "PATH = $dbp\n";
	my $path = $dbp;
	$dbp =~ s/.*\/(.*?).pm/$1/;
	print STDERR "FILE = $dbp\n";
	my $file = $dbp;

	$installed_patches{$file} = $path;
    }

    my $rs = $self->schema()->resultset('Dbpatch')->search( { });
    my @lines;
    while (my $row = $rs->next()) {
	if ($installed_patches{$row->name()}) {
	    $installed_patches{$row->name()}=undef;
	}
    }

    foreach my $k (%installed_patches) {
	print STDERR "Running $k (path = $installed_patches{$k})...\n";

	if (defined($installed_patches{$k})) { 
	    require($installed_patches{$k});
	    
	    my $patch = $k->new();
	    $patch->dbname($self->dbname());
	    $patch->dbhost($self->dbhost());
	    $patch->dbpass($self->dbpass());
	    $patch->dbuser($self->dbuser());
	    
	    print STDERR "Running $k as ".$patch->dbuser()."\n";
	    $patch->dbh($self->dbh());
	    $patch->schema($self->schema());
	    $patch->run;
	}
    }
} 

    
1;    
    
