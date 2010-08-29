# ============================================================================
package CatalystX::I18N::Role::Request;
# ============================================================================

use Moose::Role;
use HTTP::BrowserDetect;
use IP::Country::Fast;

use CatalystX::I18N::TypeConstraints;

has 'accept_language'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Languages]',
    is          => 'rw',
    lazy_build  => 1,
);

has 'browser_language'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Language]',
    is          => 'rw',
    lazy_build  => 1,
);

has 'browser_territory'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Territory]',
    is          => 'rw',
    lazy_build  => 1,
);

has 'client_country'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Territory]',
    is          => 'rw',
    lazy_build  => 1,
);

has 'browser_detect'   => (
    isa         => 'HTTP::BrowserDetect',
    is          => 'rw',
    lazy_build  => 1,
);

sub _build_accept_language {
    my ($self) = @_;
    
    my $accept_language = $self->headers->header('Accept-Language');
    
    return
        unless $accept_language;
    
    my @accepted_languages = split( /\s*,\s*/, $accept_language );

    my @sorted_languages = 
        map { lc($_->[0]) }
        sort { $b->[1] <=> $a->[1] }
        map {
            my @tmp = split( /;\s*q=/, $_ );
            $tmp[1] //= 1;
            \@tmp;
            
        } @accepted_languages;
    
    return
        unless scalar @sorted_languages;
    
    return \@sorted_languages;
}

sub _build_browser_language {
    my ($self) = @_;
    
    my $language = $self->browser_detect()->language();
    
    return
        unless $language;
    
    return lc($language);
}


sub _build_browser_territory {
    my ($self) = @_;
    
    my $territory = uc($self->browser_detect()->country());
    
    return undef
        if ! $territory || $territory eq '**';
    
    return lc($territory);
}

sub _build_browser_detect {
    my ($self) = @_;
    
    return new HTTP::BrowserDetect($self->user_agent);
}

sub _build_client_country {
    my ($self) = @_;
    
    my $ip_address = $self->address;
    
    return
        unless $ip_address;
    
    my $ip_country = IP::Country::Fast->new();

    my $country = $ip_country->inet_atocc($ip_address);
    
    return undef
        if ! $country || $country eq '**';
}

1;