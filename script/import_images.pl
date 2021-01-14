
use strict;

use Getopt::Std;
use Data::Dumper;
use File::Basename;
use SMMID::Image;
use SMIDDB;

our ($opt_H, $opt_D, $opt_p);
getopts('H:D:p:');

my $image_source_dir = shift;

my $schema = SMIDDB->connect("dbi:Pg:dbname=$opt_D;host=$opt_H;user=postgres;password=$opt_p");

my @images = glob("$image_source_dir/*");

print STDERR Dumper(\@images);

foreach my $file (@images) {
    my $image = SMMID::Image->new( { schema => $schema, image_dir => '/home/production/smmid_images/' });

    my $name = basename($file);
    $image->name($file);
    $image->description("This image represents the structure of the smid $name");
    $image->copyright("This image may be subject to copryight. Please contact the submitter for copyright information.");
    $image->dbuser_id(1);
    $image->process_image($file);


    my $compound_name = $name;
    $compound_name =~ s/\.png//g;

    print STDERR "Compound name = $compound_name\n";

    my $row = $schema->resultset("SMIDDB::Result::Compound")->find( { smid_id => $compound_name });

    if (! $row) {
	print STDERR "Compound $compound_name not found... Skipping.\n";
	next();
    }
    
    my $link_row = $schema->resultset("SMIDDB::Result::CompoundImage")->create(
	{
	    compound_id => $row->compound_id(),
	    image_id => $image->image_id(),
	});
}
    
