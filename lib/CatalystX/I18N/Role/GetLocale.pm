# ============================================================================
package CatalystX::I18N::Role::GetLocale;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;

sub check_locale {
    my ($c,$locale) = @_;
    
    
    return
        unless defined $locale
        && $locale =~ /^(?<language>[a-zA-Z]{2})_(?<territory>[a-zA-Z]{2})/;
    
    my $language = lc($+{language});
    my $territory = uc($+{territory});
    
    return 
        unless exists $c->config->{I18N}{locales}{$locale};
    
    return $locale;
}

sub get_locale_from_session {
    my ($c) = @_;
    
    if ($c->can('session')) {
        return $c->check_locale($c->session->{i18n_locale});
    }
    
    return;
}

sub get_locale_from_user {
    my ($c) = @_;
    
    if ($c->can('user')
        && defined $c->user
        && $c->user->can('locale')) {
        return $c->check_locale($c->user->locale);
    }
    
    return;
}

sub get_locale_from_browser  {
    my ($c) = @_;
    
    my ($languages,$territory);
    
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
        } elsif ($language) {
            $languages = [ $language ];
        }
    }
    
    if ($c->request->can('browser_territory')) {
        $territory = $c->request->browser_territory;
    }
    if ($c->request->can('client_country')) {
        $territory ||= $c->request->client_country;
    }
    
    my $locale_config = $c->config->{I18N}{locales};
    
    # Guess locale from language AND country/territory
    if (defined $languages && defined $territory) {
        foreach my $language (@$languages) {
            if (defined $locale_config->{$language.'_'.$territory}) {
                return $language.'_'.$territory;
            }
        }
    }
    # Guess locale from country/territory
    if (defined $territory) {
        foreach my $locale (keys %$locale_config) {
            if ($locale =~ /^[a-z]{2}_${territory}$/) {
                return $locale;
            }
        }
    }
    

    # Guess locale from language
    if (defined $languages) {
        foreach my $language (@$languages) {
            foreach my $locale (keys %$locale_config) {
                if ($locale =~ /^${language}_[A-Z]{2}/) {
                    return $locale;
                }
            }
        }
    }
    
    return;
}

sub get_locale {
    my ($c) = @_;
    
    my ($locale,$languages,$territory);
    my $locale_config = $c->config->{I18N}{locales};
    
    $locale = $c->get_locale_from_session();
    $locale ||= $c->get_locale_from_user();
    $locale ||= $c->get_locale_from_browser();
    
    # Default locale
    $locale ||= $c->config->{I18N}{default_locale};
    
    # Any locale
    ($locale) ||= keys %$locale_config;
    
    if ($c->can('locale')) {
        $c->locale($locale);
    }
    
    return $locale;
}

1;