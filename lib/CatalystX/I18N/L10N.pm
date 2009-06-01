# ============================================================================
package CatalystX::L10N;
# ============================================================================

use strict;
use warnings;
use 5.010;

use parent qw(Locale::Maketext);

use Locale::Maketext::Lexicon;
use Path::Class;

sub load_po_file {
    my ( $class, $locale, $dir ) = @_;

    die "Invalid locale"
        unless $locale =~ /^([a-z]{2})(_[A-Z]{2})?$/;

    die "Cannot read $dir in load_po_file" unless ( -r $dir );
    my $po_file = Path::Class::File->new( $dir, "$locale.po" )->stringify;

    eval qq[
        package $class;
        Locale::Maketext::Lexicon->import( {
            $locale => [ Gettext => '$po_file' ],
            _decode => 1,
            _style  => 'gettext',
        });
    ];
    die( "Couldn't open " . $po_file . ": $@" ) if $@;
    return;
}

sub load_auto {
    my ( $class, $locale ) = @_;

    die "Invalid locale"
        unless $locale =~ /^([a-z]{2})(_[A-Z]{2})?$/;

    eval qq[
        package $class;
        Locale::Maketext::Lexicon->import( {
            $locale => ['Auto'],
        });
    ];
    return;
}

1;

=head1 NAME

RevDev::Catalyst::L10N - Localisation base class

=head1 DESCRIPTION

This is the base L10N base class. It implements 
general localisation methods. It has no user maintainable parts inside.

=head1 MEDTHODS

=head3 load_po_file

    RevDev::Catalyst::L10N->load_po_file( $locale, $dir );

Reloads a po file.

C<$locale> has to be a valid locale string (eg 'de_AT', 'de').


=head1 SEE ALSO

L<Babilu>, L<Locale::Maketext> and <Locale::Maketext::Lexicon>

=head1 AUTHOR

REVDEV, C<< we@revdev.at >>

=head1 COPYRIGHT

Copyright 2008 REVDEV. All rights reserved.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.
