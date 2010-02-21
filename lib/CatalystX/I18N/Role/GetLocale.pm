# ============================================================================
package CatalystX::I18N::Role::GetLocale;
# ============================================================================

use Moose::Role;
use HTTP::BrowserDetect;

around 'prepare' => sub {
    my $orig = shift;
    my $self = shift;
    
    print "I'm around prepare\n";
    
    my $c = $self->$orig(@_);
    
    $c->prepare_locale();
    
    return $c;
};

sub _check_locale {
    my ($c,$locale) = @_;
    
    return
        unless $locale =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})/;
    
    my $language = lc($+{language});
    my $territory = uc($+{territory});
    
    return 
        unless exists $c->config->{I18N}{locales}{$locale};
    
    return $locale;
}

sub prepare_locale {
    my ($c) = @_;
    
    my ($locale,$languages,$territory);
    
    # Locale from session
    if ($c->can('session')) {
        $locale = $c->_check_locale($c->session->{i18n_locale});
    }
    
    # Locale from user settings
    if ($c->can('user')
        && defined $c->user
        && $c->user->can('locale')) {
        $locale ||= $c->_check_locale($c->user->locale);
    }
    
    # Return locale if known/set
    return $locale
        if defined $locale;
    
    # Get language and country/territory from browser
    if ($c->request->can('accept_languages')) {
        $languages = $c->request->accept_languages;
    }
    if ($c->request->can('browser_language')) {
        my $language = $c->request->browser_language;
        if (defined $languages
            && ref $languages eq 'ARRAY') {
            unshift(@$languages,$language)
                unless grep { $language eq $_ } @$languages
        } else {
            $languages = [ $c->request->browser_language ];
        }
    }
    if ($c->request->can('browser_territory')) {
        $territory = $c->request->browser_territory;
    }
    if ($c->request->can('client_country')) {
        $territory ||= $c->request->client_country;
    }
    
    my $locale_config = $c->config->{I18N}{locales};
    
    # Guess locale from browser settings & ip
    if (defined $languages && defined $territory) {
        foreach my $language (@$languages) {
            if (defined $locale_config->{$language.'_'.$territory}) {
                return $language.'_'.$territory;
            }
        }
    }
    # Guess locale from country/territory
    if (defined $territory) {
        foreach my $checklocale (keys %$locale_config) {
            if ($checklocale =~ /^[a-z]{2}_${territory}$/) {
                return $checklocale;
            }
        }
    }
    # Guess locale from language
    if (defined $languages) {
        foreach my $language (@$languages) {
            foreach my $checklocale (keys %$locale_config) {
                if ($checklocale =~ /^${language}_[A-Z]{2}/) {
                    return $checklocale;
                }
            }
        }
    }
    
    # Default locale
    return $c->config->{I18N}{default_locale}
        if defined $c->config->{I18N}{default_locale};
    
    # Random locale
    ($locale) = keys %$locale_config;
    return $locale;
}

1;
