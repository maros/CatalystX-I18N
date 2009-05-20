# ============================================================================
package RevDev::Catalyst::Controller::Locale;
# ============================================================================
use strict;
use warnings;
use base qw(RevDev::Catalyst::Controller::Base);
use 5.010;

use IP::Country::Fast;

=head1 NAME

Babilu::Controller::Locale - Catalyst Controller

=head1 SYNOPSIS

  my $locale = $c->forward(qw/Locale set_locale/);

=head1 DESCRIPTION

Catalyst Controller that manages and selects the correct locale for a
user/session

This should mostly be used to set the locale at the beginning of a session

To re-initiate the Locale setting, you have to delete $country and $lang from
the session

=cut

=head2 verify_locale 

	my $locale = 'de_DE';
	if ($c->forward('verify_locale', [ $locale]) {
		...
	}

In case the Locale is valid (in valid format and also defined in the config),
this returns 1.

C<$locale> is needed and can always be read as ($lang, $country) = split(/_/, $locale)

=cut

sub verify_locale : Private {
    my ( $self, $c, $locale ) = @_;

    if ( $locale =~ m/\A[a-z]{2,3}(_[A-Z]{2})?\Z/ ) {

        if ( exists $c->config->{locales}{$locale} ) {
            #$c->log->debug( "Confirm locale: " . $locale );
            return 1;
            
        }
        else {
            $c->log->debug( "Not a valid locale: " . $locale );
            return;
        }

    }
    else {
        $c->detach('/error',["Locale <$locale> not in required format"]);
    }

}

=head3 locale_from_session 

	my $locale = $c->forward('locale_from_session') 
	# $locale is now probably 'de_DE'

Checks the session variables $lang and $country if they are set to valid
locale settings, returns these settings if they are valid.

=cut

sub locale_from_session : Private {
    my ( $self, $c ) = @_;

    if ( $c->session->{lang} && $c->session->{country} ) {
        my $locale = join( "_", $c->session->{lang}, $c->session->{country} );

        if ( $self->verify_locale( $c, $locale ) ) {
            return $locale;
        }
    }

    #$c->log->debug( "No valid locale in Session");
    return;

}

=head3 locale_from_settings

	my $locale = $c->forward('locale_from_settings', [$c->user]) 
	# $locale is now probably 'de_DE'

This will have precedence as source for the user's locale.

=cut

sub locale_from_settings : Private { # TODO not implemented yet
    my ( $self, $c, $usr ) = @_;
    # not implemented

	if ($usr) {
		foreach my $locale ($usr->localebit->list_locale()) {
            return $locale 
                if ($self->verify_locale($c, $locale ));
		}
	}
    #$c->log->debug("Cannot retrieve locale from settings");
	return;
}

=head3 find_client_country

	my $cc = $c->forward('find_client_country', [ $c->req->address ]) 

This returns the client ip's home country using IP::Country::Fast
returns the country only if it is one of the configured valid countries.

=cut

sub find_client_country : Private {
    my ( $self, $c, $ip_address ) = @_;

    my $ip_country = IP::Country::Fast->new();

    my $cc    = $ip_country->inet_atocc($ip_address);
    my $match = qr|
		[a-z]{2,3}    # match the language
		_			  # the separator
		\Q$cc\E	      # and the literal country as it can be **
		|x;

    if ( $match ~~ %{ $c->config->{locales} } ) {
        return $cc;
    }
    elsif ($cc) {
        #$c->log->debug("The country <$cc> has not been configured");
    }
    else {
        #$c->log->debug( "Unable to find the home country of ip <"
        #        . $c->req->address
        #        . ">" );
    }
    return;

}

=head3 client_accept_language

	my @langs = $c->forward('client_accept_language', 
		$c->request->headers->header('Accept-Language') );
	# @langs is probably like ( 'de', 'de-at', 'tr' )
	# original format is like ( 'de', 'de-at;q=0.8' ... )
	# http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4

Finds out the languages and locales the browser would like to receive. They
get returned sorted by priority and sanitized.

=cut

sub client_accept_language : Private {
    my ( $self, $c, $header ) = @_;

	return [] unless ($header);

    my @accepted_langs = split( /\s*,\s*/, $header );

    my @sorted_langs = map { $_->[0] }
        sort { $b->[1] <=> $a->[1] }
        map {
        my @tmp = split( /;\s*q=/, $_ );
        $tmp[1] //= 1;
        \@tmp;
        } @accepted_langs;

    #$c->log->debug(
    #    "Interpreting <$header> as: " . join( ", ", @sorted_langs ) 
    #    );

    return \@sorted_langs;

}

=head3 locale_from_browser

	my $loc = $c->forward('locale_from_browser');

If the browser returns langs in the format 'de-de', the locale 'de_DE' is
chosen if it is valid for the config.
This should be used with high preference, as MS IE set's the lang to the
user's locale initially.

=cut

sub locale_from_browser : Private {
    my ( $self, $c ) = @_;

    foreach my $loc (
        @{  $self->client_accept_language( $c,
                $c->request->headers->header('Accept-Language') ) } )
    {

        my ( $cc, $lc ) = split( /-/, $loc );
        my $locale = lc($cc);
		$locale .=  "_" . uc($lc) if ($lc);

        if ( $self->verify_locale( $c, $locale ) ) {
            #$c->log->debug(
            #    "I can select the locale <$locale> from the 
            #    browser");
            return $locale;
        }

    }
    #$c->log->debug(
    #    "Unable to set the locale based on the browser 
    #    Accept-Language Headers"
    #);
    return;
}

=head3 locale_from_geoip_and_browser

	my $loc = $c->forward('locale_from_geoip_and_browser');

When the browser did NOT send a country preference in the Accept-Language
headers, this might help, as it tries to find out the country via the geo-ip

=cut

sub locale_from_geoip_and_browser : Private {
    my ( $self, $c ) = @_;

    if ( my $cc = $self->find_client_country( $c, $c->req->address ) ) {
        return $self->locale_for_country_from_browser( $c, $cc );
    }
    #$c->log->debug("Unable to find the client's IP's country");
    return;

}

=head3 fallback_locale

	my $loc = $c->forward('fallback_locale');

So default, fallback, if everything else fails

    return join( "_",
        $c->config->{default_language},
        $c->config->{default_country} );

=cut

sub fallback_locale : Private {
    my ( $self, $c ) = @_;

    return join( "_",
        $c->config->{default_language},
        $c->config->{default_country} );
}

=head3 locale_from_all_countries_and_browser

	my $loc = $c->forward('locale_from_all_countries_and_browser');

This also returns the locale if it can successfully retrieve one. The search
path in this case is. Go through all the configured countries and try to match
those with the language the user has set in the browser.

The country takes precedence! So if any language-preference matches the
country, we return. So the sort may not reflect the lang-prefs of the user

=cut

sub locale_from_all_countries_and_browser : Private {
    my ( $self, $c ) = @_;

    # put a slight priority on the default country
    my @country_codes = (
        $self->fallback_locale($c),
        keys %{ $c->config->{locales} } );

    my %countries = ();
COUNTRY:
    foreach my $cc (@country_codes) {

        $cc =~ s/\A[a-z]{2,3}_([A-Z]{2})/$1/;
        next COUNTRY if $countries{$cc};

        if ( my $locale = $self->locale_for_country_from_browser( $c, $cc ) )
        {
            return $locale;
        }
        else {
            $countries{$cc} = 1;
        }
    }
    return;

}

=head3 locale_for_country_from_browser

	my $cc = uc('at');
	my $loc = $c->forward('locale_for_country_from_browser', [ $cc ]);

A general function that is used by C<locale_from_all_countries_and_browser>
and others that checks if there is a locale available for a supplied country.
C<$cc> must be upper cased and the official 2 letter country-code of a country

=cut

sub locale_for_country_from_browser : Private {
    my ( $self, $c, $cc ) = @_;

    my %checked_locale = ();
LANGUAGE:
    foreach my $lang_loc (
        @{  $self->client_accept_language( $c,
                $c->request->headers->header('Accept-Language') ) } )
    {

        my ($lang) = split (/-/, $lang_loc);

        my $locale = join( "_", $lang, $cc );
        next LANGUAGE if $checked_locale{$locale};

        if ( $self->verify_locale( $c, $locale ) ) {
            $c->log->debug(
                "I can select the locale <$locale> from the geoip and browser"
            );
            return $locale;
        }

        $checked_locale{$locale} = 1;

    }
#    $c->log->debug("I cannot select a locale from the geoip and 
#    browser");
    return;

}

=head2 set_locale

	my $loc = $c->forward('set_locale');

This tries to set the locale for the Session in the following order:

    my $locale 
        = $self->locale_from_session($c)
        || $self->locale_from_settings($c)
        || $self->locale_from_browser($c)
        || $self->locale_from_geoip_and_browser($c)
        || $self->locale_from_all_countries_and_browser($c)
        || $self->fallback_locale($c);

It stores the locale in the session as well as it returns the value

=cut

sub set_locale : Private {
    my ( $self, $c ) = @_;
    
    my $country;
    my $lang;
    my $user = $c->can('user_exists') && $c->user_exists ? $c->user : undef;

    my $locale 
        = $self->locale_from_session($c)
        || $self->locale_from_settings($c, $user)
        || $self->locale_from_browser($c)
        || $self->locale_from_geoip_and_browser($c)
        || $self->locale_from_all_countries_and_browser($c)
        || $self->fallback_locale($c);

    ( $lang, $country ) = split /_/, $locale;
    $c->lang($lang);
    $c->country($country);

    $c->session->{lang}=$lang;
    $c->session->{country}=$country;

    return $locale;
}

=head2 set

User method to set locale.

=cut

sub set : Local Args(1) {
    my ( $self, $c, @locale) = @_;

    my $locale = (scalar @locale == 1) ? 
        $locale[0] : join('_',@locale);
        
    my $user = $c->can('user_exists') && $c->user_exists ? $c->user : undef;
        
    unless ( $self->verify_locale($c,$locale) ) {
        $c->detach('/error',["Unknown locale: ".$locale]);
    }
    
    if ( $user && ! $user->localebit->hasall($locale) ) {
        $c->detach('/error',["User does not have requested locale: ".$locale]);
    }

    $c->locale($locale);
       
    $c->redirect_to_base;
}

=head1 AUTHOR

Klaus Ita, << klaus@worstofall.com >>; 
REVDEV, C<< we@revdev.at >>

=head1 SEE ALSO

IP::Country, <http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
