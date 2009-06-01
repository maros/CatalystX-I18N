# ============================================================================
package CatalystX::I18N;
# ============================================================================

use strict;
use warnings;
use 5.010;

our $VERSION = version->new('1.00');

=head1 NAME

CatalystX::I18N - Catalyst internationalisation (I18N) framework

=head1 DESCRIPTION

CatalystX::I18N provides a comprehensive toolset for internationalisation 
(I18N) and localisation (L10N) of catalyst applications. This distribution 
consists of several modules that are designed to integrate seamlessly, but
can be replaced easily if necessarry.

=over

=item * L<CatalystX::I18N::Role::I18N> 

Provides 

=item * L<CatalystX::I18N::Role::L10N> 

Adds a maketext method to C<$c>

=item * L<CatalystX::I18N::Model::Locale>

Tries to determine/guess the locale for a request

=item * L<CatalystX::I18N::Model::L10N>

Provides access to L<Locale::Maketext> classes

=item * L<CatalystX::I18N::L10N>

Wrapper arround L<Locale::Maketext>

=back

=head1 SEE ALSO

L<Locale::Maketext>, <Locale::Maketext::Lexicon>,
L<Number::Format>, L<DateTime::Locale>, L<DateTime::Format::CLDR>, 
L<DateTime::TimeZone>, and L<Locale::Geocode>

=head1 SUPPORT

Please report any bugs or feature requests to 
C<catalystx-i18n@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=CatalystX::I18N>.
I will be notified and then you'll automatically be notified of the progress 
on your report as I make changes.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>

=head1 ACKNOWLEDGEMENTS 

This module was written for Revdev L<http://www.revdev.at>, a nice litte
software company I run with Koki and Domm (L<http://search.cpan.org/~domm/>).

=head1 COPYRIGHT

CatalystX::I18N is Copyright (c) 2009 Maroš Kollár 
- L<http://www.revdev.at>

This program is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut