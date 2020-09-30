
use strict;

use Getopt::Std;
use File::Basename;
use SMMID::Image;

use vars ($opt_H, $opt_D);
getopts('H:D:');

my $image_dir = shift;

my $schema = 

my @images = glob($image_dir);

foreach my $file (@images) {
    my $image = SMMID::Image->new( { schema => $schema, image_dir => $image_dir });

    my $name = basename($file);
    $image->name($file);
    $image->description("This image represents the structure of the smid $name");
    $image->copyright("This image may be subject to copryight. Please contact the submitter for copyright information.");
    $image->process_image($file);

}
    
