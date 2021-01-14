
=head1 NAME

SMMID::Image - a class for accessing the image table in the smid database


=head1 DESCRIPTION

This class provides database access and store functions
and functions to associate tags with the image.

The implementation how images are stored has been changed. Whereas the
images were stored in the image root dir keyed to the image_id, it is
now keyed to the md5sum of the original image, with the md5sum stemmed
into two byte directories. The constructor now takes a hash instead of
positional arguments.

=head1 AUTHOR(S)

Lukas Mueller (lam87@cornell.edu)
Naama Menda (nm249@cornell.edu)

=head1 VERSION

0.02, Dec 15, 2009.

=head1 MEMBER FUNCTIONS

The following functions are provided in this class:

=cut


use strict;

package SMMID::Image;

use Moose;

use Carp qw/ cluck carp confess /;

use Digest::MD5;
use File::Path 'make_path';
use File::Spec;
use File::Basename qw| basename dirname |;
use File::Temp 'tempdir';
use File::Copy qw| copy move |;
use Data::Dumper;
use Image::Size;

# some pseudo constant definitions
#
our $LARGE_IMAGE_SIZE     = 800;
our $MEDIUM_IMAGE_SIZE    = 400;
our $SMALL_IMAGE_SIZE     = 200;
our $THUMBNAIL_IMAGE_SIZE = 100;


=head2 new

 Usage:        my $image = CXGN::Image->new(dbh=>$dbh, image_id=>23423
               image_dir => $image_dir)
 Desc:         constructor
 Ret:
 Args:         a hash of a database handle, optional identifier, and the
               path to the root image_dir, with keys dbh, image_id and image_dir.
 Side Effects: if an identifier is specified, the image object
               will be populated from the database, otherwise
               an empty object is returned.
               Either way, a database connection is established.
 Example:

=cut

has 'image_id' => (isa => 'Int', is => 'rw');

has 'name' => (isa => 'Maybe[Str]', is => 'rw');

has 'description' => (isa => 'Maybe[Str]', is => 'rw');

has 'original_filename' => (isa => 'Maybe[Str]', is => 'rw');

has 'md5sum' => (isa => 'Str', is => 'rw');

has 'file_ext' => (isa => 'Str', is => 'rw');

has 'schema' => (isa => 'Ref', is => 'rw', required => 1);

has 'image_dir' => (isa => 'Str', is => 'rw');

has 'processing_dir' => (isa => 'Str', is => 'rw');

has 'copyright' => (isa => 'Maybe[Str]', is => 'rw');

has 'dbuser_id' => (isa => 'Int', is => 'rw');

has 'create_date' => (isa => 'Str', is => 'rw');

has 'modified_date' => (isa => 'Str', is => 'rw');

has 'type' => (isa => 'Str', is => 'rw');

sub BUILD {
    my $self = shift;
    my $args = shift;

    if( exists $args->{image_id} ) {
	$self->image_id($args->{image_id});
	$self->_fetch_image() if $args->{image_id};
    }
}

sub _fetch_image {
    my $self = shift;

    my $row = $self->schema()->resultset("SMIDDB::Result::Image")->find( { image_id => $self->image_id(), obsolete => 'f' });
 
    if (! $row) {
	print STDERR "Image with image_id ".$self->image_id()." does not exist in the database. Creating empty object.\n";
	return;
    }
    
    $self->name($row->name());
    $self->description($row->description());
    $self->original_filename($row->original_filename());
    $self->file_ext($row->file_ext());
    $self->dbuser_id($row->dbuser_id());
    $self->create_date($row->create_date());
    $self->modified_date($row->modified_date());
    $self->image_id($row->image_id());
    $self->copyright($row->copyright());
    $self->md5sum($row->md5sum());

    #print STDERR  "Loaded image $image_id, $md5sum, $name, $original_filename, $file_ext\n";

}

=head2 store

 Usage:        $image->store()
 Desc:         will store the data in the image object to the database
               if the image has an associated image_id, an update will
               occur. if the image does not have an associated image_id,
               an insert into the database will occur.
 Ret:          the image_id of the updated or inserted object.
 Args:
 Side Effects: database update or insert. Note that the image itself is
               stored on the file system and that it is not affected by
               this operation, unless the filename property is changed.
 Example:

=cut

sub store {
    my $self = shift;

    my $data = {
	name => $self->name(),
	description => $self->description(),
	original_filename => $self->original_filename(),
	file_ext => $self->file_ext(),
	copyright => $self->copyright(),
	md5sum => $self->md5sum(),
	dbuser_id => $self->dbuser_id(),
	type => $self->type(),
    };
    
    if ($self->image_id()) {
	my $row = $self->schema()->resultset("SMIDDB::Result::Image")->find( { image_id => $self->image_id() } );
	$row->update($data);	
    }
    else {
	# it is an insert
	#
	$data->{create_date} = 'now()';
	my $row = $self->schema()->resultset("SMIDDB::Result::Image")->create( $data );
	$row->insert();
	$self->image_id($row->image_id());
	return $self->image_id();
    }
}

=head2 delete

 Usage:  $self->delete()
 Desc:   set the image status to obsolete='t'
 Ret:    true on success, false on failure
 Args:  none
 Side Effects: set to obsolete='t' in individual_image, and locus_image
 Example:

=cut

sub delete {
    my $self = shift;
    if ($self->image_id()) {

	my $row = $self->schema()->resultset("SMIDDB::Result::Image")->find( { image_id => $self->image_id() });

	my $data = {
	    obsolete => 't'
	};

	$row->update($data);

	# to do: obsolete in relationship tables?
	print STDERR "Deleting image compound relationships... \n";
	my $rs = $self->schema()->resultset("SMIDDB::Result::CompoundImage")->search( { image_id => $self->image_id() });
	while (my $r = $rs->next()) {
	    print STDERR "deleting association of image ".$self->image_id()." with compound_id ".$r->compound_id."...\n";
	    $r->delete();
	}
	    
	return 1;
    }
    else {
	warn("Image.pm: Trying to delete an image from the db that has not yet been stored.");
        return 0;
    }

}


=head2 process_image

 Usage:        $return_code = $image -> process_image($filename);
 Desc:         processes the image that has been uploaded with the upload command.
 Ret:          the image id of the image in the database as a positive number,
               error conditions as negative numbers.
 Args:         the filename of the file (complete path)
 Side Effects: generates a new subdirectory in the image_dir for the image files,
               copies the image file to a temp dir directory where it is processed
               (resized thumnbnails and other views for the image). After that
               is done, the image object is stored in the database, and the
               image files are moved to the final location in the filesystem.
 Example:

=cut

sub process_image {
    my $self      = shift;
    my $file_name = shift;
    my $type      = shift;
    my $type_id   = shift;

    if ($file_name !~ m/jpeg$|jpg$|gif$|png$|svg$/i) {
	print STDERR "FILE $file_name cannot be converted because it is of an incorrect type.\n";
	return undef;
    }
    
    if (! -e '/usr/bin/mogrify') {
	print STDERR "Warning! You may have to install the imagemagick Debian package for image processing to work.\n";
    }
    
    if ( my $id = $self->image_id() ) {
        warn "process_image: The image object ($id) should already have an associated image. The old image will be overwritten with the new image provided!\n";
    }

    make_path( $self->image_dir() );

    my ($processing_dir) =
      File::Temp::tempdir( "process_XXXXXX",
        DIR => $self->image_dir() );
    system("chmod 775 $processing_dir");
    $self->processing_dir($processing_dir);

    # process image
    #
    $processing_dir = $self->processing_dir();

    # copy unmodified image to be fullsize image
    #
    my $full_basename = basename($file_name); # includes file ext
    my $directories = dirname($file_name);
    my $file_ext;
    my $basename; # without file_ext;
    if ($full_basename =~ m/(.*)(\.(?!\.).*)$/) {  # extension is what follows last .
	$basename = $1;
	$file_ext = $2;
    }

    #print STDERR "BASENAME: $basename, DIRECTORIES: $directories FILE_EXT $file_ext\n";
    my $original_filename = $basename;
    my $original_file_ext = $file_ext;

    my $dest_name = $self->processing_dir() . "/" . $basename.$file_ext;

    #print STDERR "Destination: ".$dest_name."\n";
    File::Copy::copy( $file_name, $dest_name )
      || die "Can't copy file $file_name to $dest_name";
    my $chmod = "chmod 664 '$dest_name'";

    if ($file_ext =~ m/png/i) {
	$self->type("png");

	my $newname = $self->process_png($processing_dir, $basename, $file_ext);
	
    }

#    my $newname = "";
    
#    if ($file_ext =~ m/svg$/i) {
#	$newname = $original_filename.".svg";
#    }

#    my $ext = "";
#    if ( $original_filename =~ /(.*)(\.\S{1,4})$/ ) {#
#	$original_filename = $1;
#	$ext               = $2;
 #   }
    
    $self->original_filename($original_filename);
    $self->file_ext($file_ext); # this is the original file
    
    # start transaction, store the image object, and associate it to
    # the given type and type_id.
    
    # move the image into the md5sum subdirectory
    #
    my $original_file_path = $self->processing_dir()."/".$self->original_filename().$self->file_ext();
    
    my $md5sum = $self->calculate_md5sum($original_file_path);
    $self->md5sum($md5sum);
    
    $self->make_dirs();
    
    $self->finalize_location($processing_dir);

    if ($file_ext =~ m/svg/i) {
	$self->type("svg");
	
	my $newname = $self->process_svg();
    }
    

    
    my $image_id = $self->store();

    return $image_id;
}


sub process_png {
    my $self = shift;
    my $processing_dir = shift;
    my $basename = shift;
    my $file_ext = shift;
    
    my $dest_name = $processing_dir ."/".$basename.".".$file_ext;

    
    if ( ! `mogrify -format png '$dest_name'` ) {

	my $newname;
	if ($file_ext !~ /png/i) {
	    $newname = $basename.".png";
	}
	# has no extension at all
	elsif (!$file_ext) {
	    $newname = $basename.".png";
	}
	else {
	    $newname = $basename.".png";
	}
	    
	system( "convert", "$processing_dir/$basename$file_ext", "$processing_dir/$newname" );
	$? and die "Sorry, can't convert image $basename$file_ext to $newname";
	
	$basename = $newname;
    }
    
    # create large image
    $self->copy_image_resize(
	"$processing_dir/$basename",
	$self->processing_dir() . "/large.png",
	$self->get_image_size("large")
	);
    
    # create midsize images
    $self->copy_image_resize(
	"$processing_dir/$basename",
	$self->processing_dir() . "/medium.png",
	$self->get_image_size("medium")
	);
    
    # create small image
    $self->copy_image_resize(
	"$processing_dir/$basename",
	$self->processing_dir() . "/small.png",
	$self->get_image_size("small")
	);
    
    # create thumbnail
    $self->copy_image_resize(
	"$processing_dir/$basename",
	$self->processing_dir() . "/thumbnail.png",
	$self->get_image_size("thumbnail")
	);
}

sub  process_svg {
    my $self = shift;
  
    
    #create soft links to different file name sizes...

    my $dir = $self->image_dir()."/".$self->image_subpath();
    my $original_filename = $dir."/".$self->original_filename().$self->file_ext();
    
    print STDERR "Generating symlinks for SVG file...\n";
    symlink($original_filename, $dir."/large.svg") || die "Can't generate symlink for $original_filename\n";
    symlink($original_filename, $dir."/medium.svg") || die "Can't generate symlink for $original_filename\n";
    symlink($original_filename, $dir."/small.svg") || die "Can't generate symlink for $original_filename\n";
    symlink($original_filename, $dir."/thumbnail.svg")|| die "Can't generate symlink for $original_filename\n";
    

}

=head2 make_dirs

 Usage:
 Desc:         creates the directory structure for image from
               image_dir onwards (a split md5sum)
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub make_dirs {
    my $self = shift;
    my $image_sub_path = $self->image_subpath();

    my $path = File::Spec->catdir( $self->image_dir(), $image_sub_path );
    if (my $dirs = make_path($path) ) {
	#print STDERR  "Created $dirs Dirs (should be 4)\n";
    }
}


=head2 finalize_location

 Usage:
 Desc:
 Ret:
 Args:          the source location as a path to a dir
 Side Effects:
 Example:

=cut

sub finalize_location {
    my $self = shift;
    my $processing_dir = shift;

    my $image_dir = File::Spec->catdir( $self->image_dir, $self->image_subpath );
    foreach my $f (glob($processing_dir."/*")) {

	File::Copy::move( $f, $image_dir )
	    || die "Couldn't move temp dir to image dir ($f, $image_dir)";
	#print STDERR "Moved image file $f to final location $image_dir...\n";

    }

    rmdir $processing_dir;

}

# used for migration

sub copy_location {
    my $self = shift;
    my $source_dir = shift;

    my $image_dir = $self->image_dir() ."/".$self->image_subpath();
    foreach my $f (glob($source_dir."/*")) {
	if (! -e $f) {
	    print STDERR "$f does not exist... moving on...\n";
	    return;
	}
	File::Copy::copy( "$f", "$image_dir/" )
	    || die "Couldn't move temp dir to image dir ($f, $image_dir). $!";
	#print STDERR "Moved image file $f to final location $image_dir...\n";

    }

}


=head2 image_subpath

 Usage: $image->image_subpath
 Desc: returns the image subpath, which is a md5sum on an image file,
       divided into 16 directory levels at 2 bytes length each.
 Ret:  path part in which to store the various sizes of this image
       under the image root dir, something like 'ab/cd/ef/01/ab1fab1fab1fab1fab1fab1f'
 Args: none
 Side Effects: none

=cut

sub image_subpath {
    my $self = shift;

    my $md5sum = $self->md5sum();
    unless( $md5sum ) {
        # if the image has no md5sum, either from the database or for
        # some other reason, warn copiously about it but don't die
        cluck 'cannot calculate image_subpath, no md5sum set for image_id '.$self->image_id();
        $md5sum = 'X'x32;
    }

    return join '/', $md5sum =~ /^(..)(..)(..)(..)(.+)$/;
}

=head2 calculate_md5sum

 Usage:
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub calculate_md5sum {
    my $self = shift;
    my $file = shift;

    open (my $F, "<", $file) || confess "Can't open $file ";
    binmode($F);
    my $md5 = Digest::MD5->new();
    $md5->addfile($F);
    close($F);

    my $md5sum = $md5->hexdigest();
    $md5->reset();

    return $md5sum;
}

sub copy_image_resize {
    my $self = shift;
    my ( $original_image, $new_image, $width ) = @_;

    #print STDERR "Resizing: Destination: $new_image\n";
    File::Copy::copy( $original_image, $new_image );
    my $chmod = "chmod 664 '$new_image'";

    # now resize the new file, and ensure it is a jpeg
    my $resize = `mogrify -format png -geometry $width '$new_image'`;
}


=head2 get_image_size_hash

 Usage:
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub get_image_size_hash {
    my $self = shift;
    return (
        large     => $LARGE_IMAGE_SIZE,
        medium    => $MEDIUM_IMAGE_SIZE,
        small     => $SMALL_IMAGE_SIZE,
        thumbnail => $THUMBNAIL_IMAGE_SIZE,
    );
}

=head2 get_image_size

 Usage:
 Desc:
 Ret:
 Args:         "large" | "medium" | "small" | "thumbnail"
               default is medium
 Side Effects:
 Example:

=cut

sub get_image_size {
    my $self = shift;
    my $size = shift;
    my %hash = $self->get_image_size_hash();
    if ( exists( $hash{$size} ) ) {
        return $hash{$size};
    }

    # default
    #
    return $MEDIUM_IMAGE_SIZE;
}


=head2 get_filename

 Usage:
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub get_filename {
    my $self = shift;
    my $size = shift;
    my $type = shift || ''; # full or partial

    my $image_dir =
        $type eq 'partial'
            ? $self->image_subpath
            : File::Spec->catdir( $self->get_image_dir, $self->image_subpath );

    my $file_ext = $self->file_ext();
    
    if ($size eq "thumbnail") {
	return File::Spec->catfile($image_dir, 'thumbnail'.$file_ext);
    }
    if ($size eq "small") {
	return File::Spec->catfile($image_dir, 'small'.$file_ext);
    }
    if ($size eq "large") {
	return File::Spec->catfile($image_dir, 'large'.$file_ext);
    }
    if ($size eq "original") {
	return File::Spec->catfile($image_dir, $self->get_original_filename().$self->file_ext());
    }
    if ($size eq "original_converted") {
	return File::Spec->catfile($image_dir, $self->get_original_filename().$self->file_ext());
    }
    return File::Spec->catfile($image_dir, 'medium'.$file_ext);
}



#=head2 iconify_file

# Usage:   Iconify_file ($filename)
# Desc:    This is used only for PDF, PS and EPS files during Upload processing to produce a thumbnail image
#          for these filetypes for the CONFIRM screen.  Results end up on disk but are not used other than to t
# 	 produce the thumbnail
# Ret:
# Args:    Full Filename of PDF file
# Side Effects:
# Example:

# =cut

# sub iconify_file {
#     my $file_name = shift;

#     my $basename = File::Basename::basename($file_name);

#     my $self = SGN::Context->new()
#       ;    # merely used to retrieve correct temp dir on this host
#     my $temp_dir =
#         $self->get_conf("basepath") . "/"
#       . $self->get_conf("tempfiles_subdir")
#       . "/temp_images";

#     my @image_pages = `/usr/bin/identify $file_name`;

#     my $mogrified_image;
#     my $newname;
#     if ( $basename =~ /(.*)\.(.{1,4})$/ )
#     {      #note; mogrify will create files name
#             # basename-0.jpg, basename-1.jpg
#         if ( $#image_pages > 0 ) {    # multipage, pdf, ps or eps
#             $mogrified_image = $temp_dir . "/temp-0.jpg";
#         }
#         else {
#             $mogrified_image = $temp_dir . "/temp.jpg";
#         }
#         my $tempname = $temp_dir . "/temp." . $2;    # retrieve file extension
#         $newname = $basename . ".jpg";               #
#         my $new_dest = $temp_dir . "/" . $newname;

#         # use temp name for mogrify/ghostscript
#         File::Copy::copy( $file_name, $tempname )
#           || die "Can't copy file $basename to $tempname";

#         if ( (`mogrify -format jpg '$tempname'`) ) {
#             die "Sorry, can't convert image $basename";
#         }

#         File::Copy::copy( $mogrified_image, $new_dest )
#           || die "Can't copy file $mogrified_image to $newname";

#     }
#     return;
# }


=head2 hard_delete

 Usage:        $image->hard_delete()
 Desc:         "hard" deletes the image.
               NEVER USE THIS FUNCTION!
 Ret:          nothing
 Args:         none
 Side Effects: completely removes all the traces of this image.
 Example:      to be used in testing scripts only. Deletion should be
               implemented using the 'obsolete' flag.

=cut

sub hard_delete {
    my $self = shift;
    my $test_mode = shift;

    if ( $self->original_filename && $self->pointer_count() < 2) {
        foreach my $size ('original', 'thumbnail', 'small', 'medium', 'large') {
            my $filename = $self->get_filename($size);
	    
	    if ($test_mode) { 
		print STDERR  "Test Mode: Would delete $filename.\n";
	    }
	    else { 
		print STDERR "Deleting $filename...\n";
		unlink $filename;
	    }
        }
    }

    $self->get_dbh->do('delete from image where image_id = ?', undef, $self->get_image_id );
}

=head2 pointer_count

 Usage: print $image->pointer_count." db rows reference this image"
 Desc: get a count of how many rows in the db refer to the same image file
 Ret: integer number
 Args: none
 Side Effects: queries the db

=cut

sub pointer_count {
    my ($self) = @_;

    return $self->get_dbh->selectrow_array( <<'', undef, $self->get_md5sum );
SELECT count( distinct( image_id ) ) from md_image WHERE md5sum=?

}


sub associate_compound {
    my $self = shift;
    my $compound_id = shift;

    if (!$self->image_id()) {
	die "No image ID. Can't associate compound to image. Need to save image first.";
    }
    
    my $row = $self->schema()->resultset("SMIDDB::Result::CompoundImage")->find_or_create(
	{
	    compound_id => $compound_id,
	    image_id => $self->image_id()
	});
    
    $row->insert();

}

sub remove_compound {
    my $self = shift;
    my $compound_id = shift;

    if (! $self->image_id()) {
	die "No image ID. Cannot remove compound associated with no image.";
    }

    my $row = $self->schema()->resultest("SMIDDB::Result::CompoundImage")->find( { compound_id => $compound_id, image_id=> $self->image_id() } );

    if (! $row) {
	print STDERR "Warning. The compound $compound_id does not seem to be associated with image ".$self->image_id().", Igoring remove\n";
    }
    else { 
	$row->delete();
    }
}




###########
1;#########
###########
