# ============================================================================
package CatalystX::I18N::Role::Base;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;

use POSIX qw(locale_h);

has 'locale' => (
    is          => 'rw',
    isa         => 'CatalystX::I18N::Type::Locale',
    default     => 'en_US',
    trigger     => sub { shift->set_locale(@_) },
    predicate   => 'has_locale'
);



=head2 ACCESSORS

=head3 locale

Get/set the current locale. Changing the locale alters the following
accessors:

=over

=item * timezone

=item * language

=item * territory

=item * datetime_locale

=item * datetime_format_datetime

=item * datetime_format_date

=item * numberformat

=back

=head3 timezone

C<DateTime::TimeZone> object for the current locale

=head3 timezone

C<DateTime::TimeZone> object for the current locale

=head3 timezone


=head2 METHODS

=head3 territory

The current territory as an uppercase 3166-1 alpha-2 code. (eg. UK)

=head3 language

The current language as a lowercase alpha-2 code. (eg. en)



sub locale_config {
    my ($c) = @_;
    
    return $c->config->{$c->locale} || {};
}

=head3 geodcode
 
 my $lgt = $c->geodcode
 say $lgt->name;
 
Returns a C<Locale::Geocode::Territory> object for the current territory
 
=cut

sub geocode {
    my ($c) = @_;
    
    my $territory = $c->territory;
    
    return 
        unless $territory;
    
    Class::MOP::load_class('Locale::Geocode');
    
    my $lc = new Locale::Geocode;
    return $lc->lookup($territory);
} 

sub language {
    my ($self) = @_;
    
    return 
        unless $self->has_locale();
    
    return 
        unless $self->locale =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})(\..+)/;
    
    return lc($+{language});
}

sub territory {
    my ($self) = @_;
    
    return 
        unless $self->has_locale();
    
    return 
        unless $self->locale =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})(\..+)/;
    
    return lc($+{territory});
}

sub set_locale {
    my ($c,$value) = @_;
    
    return 
        unless $value =~ /^(?<language>[a-zA-Z]{2})_(?<territory>[a-zA-Z]{2})(\..+)?/;
        
    my $language = lc($+{language});
    my $territory = uc($+{territory});
    my $locale = $language.'_'.$territory;
    
    return 
        unless exists $c->config->{I18N}{locales}{$locale};
    
    # Set posix locale
    setlocale( LC_CTYPE, $locale.'.UTF-8' );
    
    # Set content language header
    $c->response->content_language($language)
        if $c->response->can('content_language');
    
    # Save locale in session
    $c->session->{i18n_locale} = $locale
        if ($c->can('session'));
    
    # Set locale
    $c->meta->get_attribute('locale')->set_value($locale)
        unless $c->locale eq $locale;
}

1;
