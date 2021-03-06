
package Dbpatch::RunPatches;

use Moose;

extends 'Dbpatch::Common';

use DBI;
use SMIDDB;
use Dbpatch;
use Text::Table;
use Cwd qw(cwd);


has 'trial_mode' => (
    is => 'rw',
    isa => 'Bool',
    );

has 'list' => (
    is => 'rw',
    isa => 'Bool',
    required => 0,
    traits      => ['Getopt'],
    default => 0,
    cmd_aliases => 'l',
    documentation => 'Test run. Rollback the transaction.',
    );

has 'list_files' => (
    is => 'rw',
    isa => 'Bool',
    required => 0,
    traits      => ['Getopt'],
    default => 0,
    cmd_aliases => 'f',
    documentation => 'List available dbpatch files.',
    );

has 'update' => (
    is => 'rw',
    isa => 'Bool',
    required => 0,
    traits      => ['Getopt'],
    default => 0,
    cmd_aliases => 'r',
    documentation => 'List available dbpatch files.',
    );
    
sub run {
    my $self = shift;

    print STDERR "Connecting to database ".$self->dbname()." on host ".$self->dbhost()."...\n";
    
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
	$rs = $dbpatch_schema->resultset('Dbpatch::Result::Dbpatch')->search( { name => 'test' });
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

    if ($self->list()) {
	$self->list_installed_dbpatches();
	exit();
    }

    if ($self->list_files()) {
	my $tb = Text::Table->new( "AVAILABLE DBPATCH FILES", \" |");
	my @dbpatches = get_dbpatch_files();

	foreach my $patch (@dbpatches) {
	    $tb->add($patch);
	}

	my $rule = $tb->rule('-','+');
	
	print $rule, $tb->title(), $rule, $tb->body(), $rule, "\n";
	exit();
    }

    if ($self->update()) {
	$self->run_all_patches();
	exit();
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
    
    my @dbpatches = sort glob 'dbpatches/*/*.pm';

    foreach my $dbp (@dbpatches) {
	if (! $full_paths ) { $dbp =~ s/.*\/(.*?).pm/$1/; }
    }
    return @dbpatches;
}

sub run_all_patches {
    my $self = shift;

    # determine the uninstalled files
    #
    my %missing_patches;
    my %installed_patches_paths;
    my @available_dbpatch_files  = $self->get_dbpatch_files(1);
    foreach my $dbp (@available_dbpatch_files ) {
#	print STDERR "PATH = $dbp\n";
	my $path = $dbp;
	$dbp =~ s/.*\/(.*?).pm/$1/;
#	print STDERR "FILE = $dbp\n";
	my $file = $dbp;

	$missing_patches{$file} = $path;
    }

    my $rs = $self->schema()->resultset('Dbpatch')->search( { });
    my @lines;
    while (my $row = $rs->next()) {
	if ($missing_patches{$row->name()}) {
	    delete($missing_patches{$row->name()})
	}
    }

    if (scalar(keys(%missing_patches))==0) {
	print "+-------------------------+\n";
        print "| Patches are up to date! |\n";
	print "+-------------------------+\n";
    }
    
    
    foreach my $k (%missing_patches) {
	print STDERR "Running $k (path = $missing_patches{$k})...\n";

	if (defined($missing_patches{$k})) { 
	    require(cwd()."/".$missing_patches{$k});
	    
	    my $patch = $k->new();
	    $patch->dbname($self->dbname());
	    $patch->dbhost($self->dbhost());
	    $patch->dbpass($self->dbpass());
	    $patch->dbuser($self->dbuser());
	    
	    print STDERR "Running $k as ".$patch->dbuser()."\n";
	    $patch->dbh($self->dbh());
	    $patch->schema($self->schema());
	    $patch->patch();
	    $patch->schema()->resultset("Dbpatch::Result::Dbpatch")->create(
		{
		    name => $patch->name(),
		    description => $patch->description(),
		});
	}
    }
} 

    
1;    
    
