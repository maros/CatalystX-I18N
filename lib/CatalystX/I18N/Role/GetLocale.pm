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
    
    $locale = lc($+{language}).'_'.uc($+{territory});
    
    return 
        if not exists $c->config->{I18N}{locales}{$locale}
        || $c->config->{I18N}{locales}{$locale}{inactive} == 1;
    
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
    
    # Get Accept-Language
    if ($c->request->can('accept_languages')) {
        $languages = [ $c->request->accept_languages ];
        # Check if Accept-Language matches a locale
        foreach my $locale (@$languages) {
            return $locale
                if $c->check_locale($locale);
        }
        # Strip territory/variant part
        $languages = [ map { 
            my $element = $_;
            $element =~ s/_[A-Za-z]{2}//; 
            lc($element);
        } @$languages ];
    }
    
    $languages ||= [];
    
    # Get browser language
    if ($c->request->can('browser_language')) {
        my $language = lc($c->request->browser_language);
        unshift(@$languages,$language)
            unless grep { $language eq $_ } @$languages
    }
    
    # Get client country
    if ($c->request->can('client_country')) {
        $territory = uc($c->request->client_country);
    }
    # Get browser territory
    if ($c->request->can('browser_territory')) {
        $territory ||= uc($c->request->browser_territory);
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
                if ($locale =~ m/^${language}_[A-Z]{2}/) {
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

no Moose::Role;
1;

=head1 NAME

CatalystX::I18N::Role::GetLocale - Tries to determine the current users locale

=head1 SYNOPSIS

 package MyApp::Catalyst;
 
 use CatalystX::RoleApplicator;
 use Catalyst qw/MyPlugins 
    CatalystX::I18N::Role::Base
    CatalystX::I18N::Role::GetLocale/;
 
 __PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::TraitFor::Request/);
 
 package MyApp::Catalyst::Controller::Main;
 use strict;
 use warnings;
 use parent qw/Catalyst::Controller/;
 
 sub auto : Private { # Auto method will always be called first
     my ($self,$c) = @_;
     $c->get_locale();
 }

=head1 DESCRIPTION

This role provides many methods to retrieve/guess the best locale for the
current user.

=head1 METHODS

=head3 get_locale

Tries to determine the users locale in the given order

=over

=item # Session (via C<get_locale_from_session>)

=item # User (via C<get_locale_from_user>)

=item # Browser (via C<get_locale_from_browser>)

=item # Default locale from config (via C<$c-E<gt>config-E<gt>{I18N}{default_locale}>)

=item # Random locale

=back

Sets the winning locale (via C<$c-E<gt>locale()>) if the 
L<CatalystX::I18N::Role::Base> is loaded.

=head3 get_locale_from_browser

Tries to fetch the locale from the user object (via 
L<$c-E<gt>user-E<gt>locale>)

=head3 get_locale_from_session

Tries to fetch the locale from the current session.

=head3 get_locale_from_user

Tries to fetch the locale from the user object (via 
L<$c-E<gt>user-E<gt>locale>).

=head3 check_locale

=head1 SEE ALSO

L<Locale::Maketext>, L<CatalystX::I18N::Model::L10N> 
and L<CatalystX::I18N::L10N>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>