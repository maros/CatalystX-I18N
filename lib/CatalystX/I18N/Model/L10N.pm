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

=head1 NAME

CatalystX::I18N::Model::L10N - Model Interface to Maketext class

=head1 SYNOPSIS

    my $l10n = $c->model('L10N');

=head1 DESCRIPTION

Glue  into Catalyst.

=head1 METHODS

=head2 new 

Initializes the model object. Loads po files for all used languages/locales.

=cut

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


=head3 ACCEPT_CONTEXT

Does the glueing! Setting the locale from the Session

=cut

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

1;

__END__


=head1 AUTHOR

REVDEV, C<< we@revdev.at >>

=head1 COPYRIGHT

Copyright 2008 REVDEV. All rights reserved.

=cut
