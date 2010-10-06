# ============================================================================
package CatalystX::I18N::Model::L10N;
# ============================================================================

use Moose;
extends 'Catalyst::Model';

use 5.010;

use CatalystX::I18N::TypeConstraints;

has 'class' => (
    is          => 'rw', 
    isa         => 'Str',
);

has 'gettext_style' => (
    is          => 'rw', 
    isa         => 'Bool',
    default     => 1,
);

has 'directories' => (
    is          => 'rw', 
    isa         => 'CatalystX::I18N::Type::DirList',
    coerce      => 1,
    default     => sub { [] },
);

sub new {
    my ( $self,$app,$config ) = @_;
    
    $self = $self->next::method( $config );
    
    my $class = $self->class() || $app .'::L10N';
    $self->class($class);
    
    unless (scalar @{$self->directories}) {
        #warn('HOME:'.$self->config->{home} || '');
        my $calldir = $app;
        $calldir =~ s{::}{/}g;
        my $file = "$calldir.pm";
        my $path = $INC{$file};
        $path =~ s{\.pm$}{/L10N};
        $self->directories([ Path::Class::Dir->new($path) ]);
    }
    
    eval {
        Class::MOP::load_class($class);
        return 1;
    } or Catalyst::Exception->throw(sprintf("Could not load '%s' : %s",$class,$@));
    
    Catalyst::Exception->throw(sprintf("Could initialize '%s' because is is not a 'Locale::Maketext' class",$class))
        unless $class->isa('Locale::Maketext');
    
    if ($class->can('load_lexicon')) {
        my (@locales,%inhertiance,$config);
        $config = $app->config->{I18N}{locales};
        foreach my $locale (keys %$config) {
            push(@locales,$locale);
            $inhertiance{$locale} = $config->{$locale}{inherits}
                if defined $config->{$locale}{inherits};
            
        }
        $app->log->debug(sprintf("Loading L10N lexicons for locales %s",join(',',@locales)))
            if $app->debug;
        $class->load_lexicon( 
            locales             => \@locales, 
            directories         => $self->directories,
            gettext_style       => $self->gettext_style,
            inheritance         => \%inhertiance,
        );
    } else {
        $self->log->warn(sprintf("'%s' does not implement a 'load_lexicon' method",$class))
    }
    
    return $self;
}

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    # set locale and fallback
    my $handle = $self->class->get_handle( $c->locale );
    
    # Catch error
    Catalyst::Exception->throw(sprintf("Could not fetch lanuage handle for locale '%s'",$c->locale))
        unless ( scalar $handle );
    
    $handle->fail_with( sub { } );
    
    return $handle;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;

=encoding utf8

=head1 NAME

CatalystX::I18N::Model::L10N - Glues CatalystX::I18N::L10N into Catalyst

=head1 SYNOPSIS

 package MyApp::Catalyst;
 use Catalyst qw/CatalystX::I18N::Role::Base/;
 
 __PACKAGE__->config( 
    'Model::L10N' => {
        directory       => '/path/to/l10n/files', # optional
    },
 );
 
 
 package MyApp::Model::L10N;
 use parent qw/CatalystX::I18N::Model::L10N/;
 
 
 package MyApp::Controller::Main;
 use parent qw/Catalyst::Controller/;
 
 sub action : Local {
     my ($self,$c) = @_;
     
     $c->stash->{title} = $c->model('L10N')->maketext('Hello world');
     # See CatalystX::I18N::Role::Maketext for a convinient wrapper
 }

=head1 DESCRIPTION

This model glues a L<CatalystX::I18N::L10N> class (or any other 
L<Locale::Maketext> class) with Catalyst. 

=head1 CONFIGURATION

=head3 class

Set the L<Locale::Maketext> class you want to use from this model.

Defaults to $APPNAME::L10N

=head3 gettext_style

Enable gettext style. L<%quant(%1,document,documents)> instead of 
L<[quant,_1,document,documents]>

Default TRUE

=head3 directory

List of directories to be searched for L10N files.

See L<CatalystX::I18N::L10N> for more details on the C<directory> parameter

=head1 SEE ALSO

L<CatalystX::I18N::L10N>, L<Locale::Maketext>, L<Locale::Maketext::Lexicon>
and L<CatalystX::I18N::Role::Maketext>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>