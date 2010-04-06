# ============================================================================
package CatalystX::I18N::Controller::GetLocale;
# ============================================================================

BEGIN {
    use Moose;
    extends qw(Catalyst::Controller);
}

sub check_locale : Private {
    my ($self,$c,$locale) = @_;
    
    return
        unless $locale =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})/;
    
    my $language = lc($+{language});
    my $territory = uc($+{territory});
    
    return 
        unless exists $c->config->{I18N}{locales}{$locale};
    
    return $locale;
}

sub get_locale_from_session : Private {
    my ($self,$c) = @_;
    
    if ($c->can('session')) {
        return $self->check_locale($c,$c->session->{i18n_locale});
    }
    
    return;
}

sub get_locale_from_user : Private {
    my ($self,$c) = @_;
    
    if ($c->can('user')
        && defined $c->user
        && $c->user->can('locale')) {
        return $self->check_locale($c,$c->user->locale);
    }
    
    return;
}

sub get_locale_from_browser : Private {
    my ($self,$c) = @_;
    
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

sub get_locale : Private {
    my ($self,$c) = @_;
    
    my ($locale,$languages,$territory);
    
    $locale = $self->get_locale_from_session($c);
    $locale ||= $self->get_locale_from_user($c);
    $locale ||= $self->get_locale_from_browser($c);
    
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
