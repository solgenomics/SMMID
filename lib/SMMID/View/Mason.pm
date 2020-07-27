package SMMID::View::Mason;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::HTML::Mason';

=head1 NAME

SMMID::View::Mason - Catalyst View

=head1 DESCRIPTION

Catalyst View.


=encoding utf8

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->config(
    globals => ['$c'],
    template_extension => '.mas',
    interp_args => {
        data_dir => SMMID->tempfiles_base->subdir('mason'),
        comp_root => [
            [ main => SMMID->path_to('mason') ],
        ],
        preamble => "use utf8; ",
    },
);




__PACKAGE__->meta->make_immutable;

1;
