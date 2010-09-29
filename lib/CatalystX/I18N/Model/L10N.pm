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

has 'directory' => (
    is          => 'rw', 
    isa         => 'Path::Class::Dir',
    coerce      => 1,
);

sub new {
    my ( $self,$app,$config ) = @_;
    
    $self = $self->next::method( $config );
    
    my $class = $self->class() || $app .'::L10N';
    $self->class($class);
    
    unless ($self->directory) {
        my $calldir = $app;
        $calldir =~ s{::}{/}g;
        my $file = "$calldir.pm";
        my $path = $INC{$file};
        $path =~ s{\.pm$}{/I18N};
        $self->directory(Path::Class::Dir->new($path));
    }
    
    Class::MOP::load_class($class);
    
    if ($class->can('load_lexicon')) {
        $class->load_lexicon( 
            locales             => [ keys %{ $app->config->{I18N}{locales} } ], 
            directory           => $self->directory,
            gettext_style       => $self->gettext_style,
        );
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