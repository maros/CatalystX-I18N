# ============================================================================
package CatalystX::I18N::Role::Base;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;
use Clone qw(clone);
use POSIX qw(locale_h);

has 'locale' => (
    is          => 'rw',
    isa         => 'CatalystX::I18N::Type::Locale',
    default     => 'en_US',
    trigger     => sub { shift->set_locale(@_) },
    predicate   => 'has_locale'
);

sub i18n_config {
    my ($c) = @_;
    
    return {}
        unless defined $c->config->{I18N}{locales}{$c->locale};
    
    my $config = clone($c->config->{I18N}{locales}{$c->locale});
    $config->{locale} = $c->locale;
    
    return $config;
}

sub i18n_geocode {
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
    setlocale( &POSIX::LC_ALL, $locale );
    
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

after setup_finalize => sub {
    my ($app) = @_;
    
    $app->config->{I18N} ||= {};
    my $config = $app->config->{I18N};
    my $locales = $config->{locales} ||= {};
    
    my $locale_type_constraint = $app
        ->meta
        ->get_attribute('locale')
        ->type_constraint;
    
    my $default_locale = $config->{default_locale};
    if (defined $default_locale
        && ! $locale_type_constraint->check($default_locale)) {
        Catalyst::Exception->throw(sprintf("Default locale '%s' does not match '[a-z]{2}_[A-Z]{2}'",$default_locale));
    }
    
    # Build inheritance tree
    my (%tree,$changed);
    $changed = 1;
    while ($changed) {
        $changed = 0;
        foreach my $locale (keys %$locales) {
            next
                if exists $tree{$locale};
            my $locale_config = $locales->{$locale};
            my $locale_inactive = $locale_type_constraint->check($locale) ? 0:1;
            $locale_config->{inactive} //= 0;
            if ($locale_config->{inactive} != $locale_inactive) {
                $app->log->warn(sprintf("Locale '%s' has been set inactive because it does not match '[a-z]{2}_[A-Z]{2}'",$locale));
                $locale_config->{inactive} = 1;
            }
            
            unless (exists $locale_config->{inherits}) {
                $locale_config->{_inherits} = [];
                $tree{$locale} = $locale_config;
                $changed = 1;
            } elsif (exists $tree{$locale_config->{inherits}}) {
                my $inactive = $locale_config->{inactive};
                my @inheritance = (@{$tree{$locale_config->{inherits}}->{_inherits}},$locale_config->{inherits});
                $tree{$locale} = $locales->{$locale} = $locale_config = Catalyst::Utils::merge_hashes($tree{$locale_config->{inherits}}, $locale_config);
                $locale_config->{_inherits} = \@inheritance;
                $locale_config->{inactive} = $inactive;
                $changed = 1;
            }
        }
    }
    foreach my $locale (keys %$locales) {
        my $locale_config = $locales->{$locale};
        unless (exists $locale_config->{_inherits}) {
            Catalyst::Exception->throw(sprintf("Circular I18N inheritance detected between '%s' and '%s'",$locale,$locale_config->{inherits}))
        }
    }
};

no Moose::Role;
1;

=head1 NAME

CatalystX::I18N::Role::Base - Basic catalyst I18N support

=head1 SYNOPSIS

 package MyApp::Catalyst;
 
 use Catalyst qw/MyPlugins 
    CatalystX::I18N::Role::Base/;
 
 
 package MyApp::Catalyst::Controller::Main;
 use strict;
 use warnings;
 use parent qw/Catalyst::Controller/;
 
 sub action : Local {
     my ($self,$c) = @_;
     
     $c->locale('de_AT');
 }

=head1 DESCRIPTION

This role is needed by all other roles and provides basic I18N support for
Catalyst.

=head1 METHODS

=head3 locale

 $c->locale('de_AT');
 OR
 my $locale  = $c->locale();

Get/set the current locale. Changing this value has some side-effects:

=over

=item * Sets program locale via L<POSIX::setlocale>

=item * Stores the locale in the current session (if any)

=item * Sets the 'Content-Language' response header (if L<CatalystX::I18N::TraitFor::Response> has been loaded)

=back

=head3 set_locale

Same as C<$c-E<GT>locale($locale);>.

=head3 language

Returns the language part of the current locale

=head3 territory

Returns the territory part of the current locale

=head3 i18n_config

Returns the (cloned) I18N config hash for the current locale.

=head3 i18n_geocode

 my $lgt = $c->i18n_geocode
 say $lgt->name;

Returns a L<Locale::Geocode::Territory> object for the current territory.

=head1 SEE ALSO

L<POSIX>, L<Locale::Geocode>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
