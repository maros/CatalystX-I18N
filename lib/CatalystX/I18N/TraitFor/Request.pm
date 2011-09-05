# ============================================================================
package CatalystX::I18N::TraitFor::Request;
# ============================================================================

use namespace::autoclean;
use Moose::Role;
requires qw(headers user_agent address);

use HTTP::BrowserDetect;
use IP::Country::Fast;

use CatalystX::I18N::TypeConstraints;

has 'accept_language'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Locales]',
    is          => 'rw',
    lazy_build  => 1,
    builder     => '_build_accept_language',
);

has 'browser_language'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Language]',
    is          => 'rw',
    lazy_build  => 1,
    builder     => '_build_browser_language',
);

has 'browser_territory'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Territory]',
    is          => 'rw',
    lazy_build  => 1,
    builder     => '_build_browser_territory',
);

has 'client_country'   => (
    isa         => 'Maybe[CatalystX::I18N::Type::Territory]',
    is          => 'rw',
    lazy_build  => 1,
    builder     => '_build_client_country',
);

has 'browser_detect'   => (
    isa         => 'HTTP::BrowserDetect',
    is          => 'rw',
    lazy_build  => 1,
    builder     => '_build_browser_detect',
);

sub _build_accept_language {
    my ($self) = @_;
    
    my $accept_language = $self->headers->header('Accept-Language');
    
    return
        unless $accept_language;
    
    my @accepted_languages = 
        map {
            my @tmp = split( /;\s*q=/, $_ );
            $tmp[1] ||= 1;
            \@tmp;
        } split( /\s*,\s*/, $accept_language );
    
    my @sorted_languages;
    
    no warnings 'once';
    foreach my $element (sort { $b->[1] <=> $a->[1] } @accepted_languages) {
        my ($language,$territory) = split /[_-]/,$element->[0];
        my $return = lc($language);
        $return .= '_'.uc($territory)
            if $territory;
        next
            unless $return =~ $CatalystX::I18N::TypeConstraints::LOCALE_RE;
        push(@sorted_languages,$return);
        
    }
    return \@sorted_languages;
}

sub _build_browser_language {
    my ($self) = @_;
    
    my $language = $self->browser_detect()->language();
    
    return
        unless defined $language;
    
    $language = lc($language);
    
    my $constraint = Moose::Util::TypeConstraints::find_type_constraint('CatalystX::I18N::Type::Language');
    
    return
        unless $constraint->check($language);
    
    
    return $language;
}

sub _build_browser_territory {
    my ($self) = @_;
    
    my $territory = $self->browser_detect()->country();
    
    return
        if ! defined $territory || ! $territory || $territory eq '**';
        
    my $constraint = Moose::Util::TypeConstraints::find_type_constraint('CatalystX::I18N::Type::Territory');
    
    return
        unless $constraint->check($territory);
    
    return uc($territory);
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
    
    return
        if ! $country || $country eq '**';
    
    return $country;
}

no Moose::Role;
1;

=encoding utf8

=head1 NAME

CatalystX::I18N::TraitFor::Request - Adds various I18N methods to a Catalyst::Request object

=head1 SYNOPSIS

 package MyApp::Catalyst;
 
 use CatalystX::RoleApplicator;
 use Catalyst qw/MyPlugins 
    CatalystX::I18N::Role::Base/;
 
 __PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::TraitFor::Request/);

=head1 DESCRIPTION

Adds several methods to a L<Catalyst::Request> object that help you determine
a users language and locale.

All methods are lazy. This means that the values will be only calculated
upon the first call of the method.

=head1 METHODS

=head3 accept_language

 my @languages = $c->request->accept_language();

Returns an ordered list of accepted languages (from the 'Accept-Language'
header)

=head3 browser_language

 my $browser_language = $c->request->browser_language();

Returns the language of the browser (form the 'User-Agent' header)

=head3 browser_territory

 my $browser_territory = $c->request->browser_territory();

Returns the territory of the browser (form the 'User-Agent' header)

=head3 client_country

 my $browser_territory = $c->request->client_country();

Looks up the client IP-address via L<IP::Country::Fast>.

=head3 browser_detect

 my $browser_detect = $c->request->browser_detect();

Returns a L<HTTP::BrowserDetect> object.

=head1 SEE ALSO

L<Catalyst::Request>, L<IP::Country::Fast>, L<HTTP::BrowserDetect>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
