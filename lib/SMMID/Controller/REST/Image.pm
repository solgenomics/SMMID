
=head1 NAME

    SMMID::Controller::AJAX::Image - image ajax requests

=head1 DESCRIPTION

Implements the following endpoints:

 GET /rest/image/<image_id> 

 GET /rest/image/<image_id>/stock/<stock_id>/display_order

 POST /rest/upload/image

 POST /rest/image/<image_id>/update

 POST /rest/image/<image_id>/stock/<stock_id>/display_order/<display_order>

 GET /rest/image/<image_id>/locus/<locus_id>/display_order

 POST /rest/image/<image_id>/locus/<locus_id>/display_order/<display_order>

=head1 AUTHOR

Lukas Mueller <lam87@cornell.edu>

=cut

package SMMID::Controller::REST::Image;

use Moose;
use Data::Dumper;
use SMMID::Image;

BEGIN { extends 'Catalyst::Controller::REST' };

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );


# parse /rest/image/<image_id>
#
sub basic_rest_image :Chained('/') PathPart('rest/image') CaptureArgs(1) ActionClass('REST') {  }

sub basic_rest_image_GET { 
    my $self = shift;
    my $c = shift;

    my $image_id = shift;
    $self->basic_rest_image_POST($c, $image_id);
}

sub basic_rest_image_POST { 
    my $self = shift;
    my $c = shift;
    $c->stash->{image_id} = shift;

    $c->stash->{image} = SMMID::Image->new({ schema => $c->model("SMIDDB"), image_id => $c->stash->{image_id} });
}

# endpoint /rest/image/<image_id>
#    
sub image_info :Chained('basic_rest_image') PathPart('') Args(0) ActionClass('REST') {}

sub image_info_GET { 
    my $self = shift;
    my $c = shift;

    if (! $c->stash->{image}->image_id()) {
	$c->stash->{rest} = { error => 'The specified image does not exist.' };
	return;
    }

    my $image = $c->stash->{image};
    my $dir = $c->config->{image_url}."/".$image->image_subpath();
    
    my $response = {
	name => $image->name(),
	description => $image->description(),
	copyright => $image->copyright(),
	thumbnail => $self->source_tag("/".$dir."/thumbnail.png"),
	small => $self->source_tag("/".$dir."/small.png"),
	medium => $self->source_tag("/".$dir."/medium.png"),
	large => $self->source_tag("/".$dir."/large.png"),
	dbuser_id => $image->dbuser_id(),
        md5sum => $image->md5sum(),	    
    };
    
    $c->stash->{rest} = $response;
}

sub source_tag {
    my $self = shift;
    my $url = shift;

    return "<img src=\"$url\" />";

}



sub image_metadata_update :Chained('basic_rest_image') PathPart('update') Args(0) ActionClass('REST') { };

sub image_metadata_update_POST {
    my $self = shift;
    my $c = shift;
    my $params = shift;
    my $image_dir = shift;
    my $user_id = shift;
    my $user_type = shift;
    my $image_id = shift;
    
    my $image_name = $params->{image_name};
    my $description = $params->{description};
    my $image_file_name = $params->{image_file_name};
    my $mime_type = $params->{mimeType};

    # metadata store for the rest not yet implemented
    my $image_file_size = $params->{image_file_size};
    my $image_height = $params->{image_height};
    my $image_width = $params->{image_width};
    my $copyright = $params->{copyright};
    my $image_timestamp = $params->{image_timestamp};
    my $image_location_hashref = $params->{image_location};
    my $additional_info_hashref = $params->{additional_info};
    my $compound_id = $params->{compound_id};
    
    #### Prechecks before storing
    # 
    # Check that the image type they want to pass in is supported.
    # If it is not converted, and is the same after _get_extension, it is not supported.
    #
    my $extension_type = _get_extension($mime_type);
    if ($extension_type eq $mime_type) {
	$c->stash->{rest} = { error => "The type $mime_type is not supported." };
	return;
    }
    
    # Check if an image id was passed in, and if that image exists
    #
    my $image = SMMID::Image->new( { schema => $c->model("SMIDDB"), image_dir => $image_dir, image_id => $image_id  });
    if ($image_id && ! defined $image->get_create_date()) {
	$c->stash->{rest} = { error => "The image with ID $image_id does not exist" };
	return;
    }
    
    #
    ####  End of prechecks  ####
				       
    # Assign image properties
    unless ($image_id) { $image->set_sp_person_id($user_id); }
    $image->name($image_name);
    $image->description($description);
    $image->original_filename($image_file_name);
    $image->file_ext($extension_type);
    $image->copyright($copyright);
    $image->image_taken_timestamp($image_timestamp);
    # Save the image to the db
    $image_id = $image->store();
    
    my $image = SMMID::Image->new( { schema => $c->model("SMIDDB"), image_id => $image_id } );
    
    # Associate our stock with the image, if a stock_id was provided.
    if ($compound_id) {
	$image->associate_compound($compound_id);
	## Associate image with logged-in user here...
    }



}


    
#     my @image_ids;
#     push @image_ids, $image_id;
#     my $image_search = CXGN::Image::Search->new({
#         bcs_schema=>$self->bcs_schema(),
#         people_schema=>$self->people_schema(),
#         phenome_schema=>$self->phenome_schema(),
#         image_id_list=>\@image_ids
#     });

#     my ($search_result, $total_count) = $image_search->search();
#     my %result;

#     foreach (@$search_result) {

#         # Get the cv terms assigned
#         my $image = SGN::Image->new($self->bcs_schema()->storage->dbh(), $_->{'image_id'});
#         my @cvterms = $image->get_cvterms();
#         # Process cvterms
#         my @cvterm_names;
#         foreach (@cvterms) {
#             if ($_->name) {
#                 push(@cvterm_names, $_->name);
#             }
#         }

#         # Get the observation variable db ids
#         my @observationDbIds;
#         my $observations_array = $_->{'observations_array'};

#         foreach (@$observations_array) {
#             my $observationDbId = $_->{'phenotype_id'};
#             push @observationDbIds, $observationDbId
#         }

#         # Construct the response
#         %result = (
#             additionalInfo => {
#                 observationLevel => $_->{'stock_type_name'},
#                 observationUnitName => $_->{'stock_uniquename'},
#             },
#             copyright => $_->{'image_username'} . " " . substr($_->{'image_modified_date'},0,4),
#             description => $_->{'image_description'},
#             descriptiveOntologyTerms => \@cvterm_names,
#             imageDbId => $_->{'image_id'},
#             imageFileName => $_->{'image_original_filename'},
#             # Since breedbase doesn't care what file size is saved when the actual saving happens,
#             # just return what the user passes in.
#             imageFileSize => $imageFileSize,
#             imageHeight => $imageHeight,
#             imageWidth => $imageWidth,
#             imageName => $_->{'image_name'},
#             imageTimeStamp => $_->{'image_modified_date'},
#             imageURL => $url,
#             mimeType => _get_mimetype($_->{'image_file_ext'}),
#             observationUnitDbId => $_->{'stock_id'},
#             # location and linked phenotypes are not yet available for images in the db
#             imageLocation => {
#                 geometry => {
#                     coordinates => [],
#                     type=> '',
#                 },
#                 type => '',
#             },
#             observationDbIds => [@observationDbIds],
#         );
#     }

#     my $total_count = 1;
#     my $pagination = CXGN::BrAPI::Pagination->pagination_response($total_count,$page_size,$page);
#     return CXGN::BrAPI::JSONResponse->return_success( \%result, $pagination, undef, $self->status());
# }



sub image_upload : Path('/rest/upload/image') Args(0) ActionClass('REST') { };

sub image_upload_GET {
    my $self = shift;
    my $c = shift;

    $c->stash->{rest} = { error => "Call this using POST!" };
}

sub image_upload_POST {
    my $self = shift;
    my $c = shift;

    if (! $c->user()) {
	$c->stash->{rest} = { error => "You must be logged in to submit images. Sorry." };
	return;
    }

    my $dbuser_id = $c->user()->get_object()->dbuser_id();
    
    print STDERR Dumper($c->req->params());
    my $compound_id = $c->req->param("compound_id");
    
    print STDERR "Uploading file...\n";
    my $upload = $c->req->upload("input_image_file_upload");

    my $filename = $upload->tempname();
    print STDERR "Filename = $filename\n";
    if ($upload->type() !~ m/jpg|jped|png|gif/) {
	print STDERR "Trying to upload wrong filetype. Sorry.\n";
	$c->stash->{rest} = { error => 'The uploaded file must be of type jpg, gif or png.' };
	return;
    }

    print STDERR "Processing image...\n";
    my $image = SMMID::Image->new( { schema => $c->model("SMIDDB"), image_dir => $c->config->{image_dir} });

    $image->name( $upload->filename() );
    $image->dbuser_id($dbuser_id);
    $image->process_image($filename);
    $image->associate_compound($compound_id);
    
    print STDERR "Processing done.\n";

    $c->stash->{rest} = { success => "Upload succeeded! Congratulations! :-)" };
    
}


# sub image_store {
#     my $self = shift;
#     my $image_dir = shift;
#     my $image_id = shift;
#     my $inputs = shift;
#     my $content_type = shift;
	
#     print STDERR "Image ID: $image_id. inputs to image metadata store: ".Dumper($inputs);

#     # Get our image file extension type from the database
#     my @image_ids;
#     push @image_ids, $image_id;
#     my $image_search = CXGN::Image::Search->new({
#      bcs_schema=>$self->bcs_schema(),
#      people_schema=>$self->people_schema(),
#      phenome_schema=>$self->phenome_schema(),
#      image_id_list=>\@image_ids
#     });

#     my ($search_result, $total_count) = $image_search->search();
#     my $file_extension = @$search_result[0]->{'image_file_ext'};

#     if (! defined $file_extension) {
#         return CXGN::BrAPI::JSONResponse->return_error($self->status, sprintf('Unsupported image type, %s', $file_extension));
#     }

#     my $tempfile = $inputs->filename();
#     my $file_with_extension = $tempfile.$file_extension;
#     rename($tempfile, $file_with_extension);

#     print STDERR "TEMP FILE : $tempfile\n";

#     # process image data through CXGN::Image...
#     #
#     my $cxgn_img = CXGN::Image->new(dbh=>$self->bcs_schema()->storage()->dbh(), image_dir => $image_dir, image_id => $image_id);

#     eval {
#         $cxgn_img->process_image($file_with_extension);
#     };

#     if ($@) {
#            print STDERR "An error occurred during image processing... $@\n";
#     }
#     else {
#            print STDERR "Image processed successfully.\n";
#     }

#     my %result = ( image_id => $image_id);

#     foreach (@$search_result) {
#         my $sgn_image = SGN::Image->new($self->bcs_schema()->storage->dbh(), $_->{'image_id'});
#         my $page_obj = CXGN::Page->new();
#         my $hostname = $page_obj->get_hostname();
#         my $url = $hostname . $sgn_image->get_image_url('medium');
#         my $filename = $sgn_image->get_filename();
#         my $size = (stat($filename))[7];
#         my ($width, $height) = imgsize($filename);

#         # Get the observation variable db ids
#         my @observationDbIds;
#         my $observations_array = $_->{'observations_array'};

#         foreach (@$observations_array) {
#             my $observationDbId = $_->{'phenotype_id'};
#             push @observationDbIds, $observationDbId
#         }

#      %result = (
#          additionalInfo => {
#              observationLevel => $_->{'stock_type_name'},
#              observationUnitName => $_->{'stock_uniquename'},
#          },
#          copyright => $_->{'image_username'} . " " . substr($_->{'image_modified_date'},0,4),
#          description => $_->{'image_description'},
#          imageDbId => $_->{'image_id'},
#          imageFileName => $_->{'image_original_filename'},
#          imageFileSize => $size,
#          imageHeight => $height,
#          imageWidth => $width,
#          imageName => $_->{'image_name'},
#          imageTimeStamp => $_->{'image_modified_date'},
#          imageURL => $url,
#          mimeType => _get_mimetype($_->{'image_file_ext'}),
#          observationUnitDbId => $_->{'stock_id'},
#          # location and linked phenotypes are not yet available for images in the db
#          imageLocation => {
#              geometry => {
#                  coordinates => [],
#                  type=> '',
#              },
#              type => '',
#          },
#          observationDbIds => [@observationDbIds],
#      );
#     }

#     my $pagination = CXGN::BrAPI::Pagination->pagination_response(1, 10, 0);
#     return CXGN::BrAPI::JSONResponse->return_success( \%result, $pagination, [], $self->status(), 'Image data store successful');
# }

sub _get_mimetype {
    my $extension = shift;
    my %mimetypes = (
        '.jpg' => 'image/jpeg',
        '.JPG' => 'image/jpeg',
        '.jpeg' => 'image/jpeg',
        '.png' => 'image/png',
        '.gif' => 'image/gif',
        '.svg' => 'image/svg+xml',
        '.pdf' => 'application/pdf',
        '.ps'  => 'application/postscript',
    );
    if ( defined $mimetypes{$extension} ) {
        return $mimetypes{$extension};
    } else {
        return $extension;
    }
}

sub _get_extension {
    my $mimetype = shift;
    my %extensions = (
        'image/jpeg'             => '.jpg',
        'image/png'              => '.png',
        'image/gif'              => '.gif',
        'image/svg+xml'          => '.svg',
        'application/pdf'        => '.pdf',
        'application/postscript' => '.ps'
    );
    if ( defined $extensions{$mimetype} ) {
        return $extensions{$mimetype};
    } else {
        return $mimetype;
    }
}

sub delete_image :Chained('basic_rest_image') PathPart('delete') Args(0) {
    my $self = shift;
    my $c = shift;

    print STDERR "Deleting image ".$c->stash->{image_id}."...\n";
    
    if (!$c->stash->{image}->image_id()) {
	$c->stash->{rest} = { error => 'The image with id '.$c->stash->{image_id}.' does not exist in the database.'};
	return;
    }
			      
    if (! $c->user()) {
	$c->stash->{rest} = { error => 'You need to be logged in to delete images.' };
	return;
    }

    if ($c->user()->get_object()->user_type() ne "curator" || $c->user()->get_object()->dbuser_id() != $c->stash->{image}->dbuser_id()) {
	$c->stash->{rest} = { error => "You are not a curator, or you don't own the image, so you cannot delete it. Sorry." };
	return;
    }

    print STDERR "Everything checks out. Deleting now.\n";
    
    $c->stash->{image}->delete();

    $c->stash->{rest} = { success => 1 }; 
}

1;
