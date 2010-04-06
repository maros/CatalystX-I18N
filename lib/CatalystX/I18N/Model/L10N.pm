# ============================================================================
package CatalystX::I18N::Model::L10N;
# ============================================================================

use Moose;
extends 'Catalyst::Model';

use CatalystX::I18N::TypeConstraints;

has 'class' => (
    is          => 'rw', 
    isa         => 'Str',
);

has 'path' => (
    is          => 'rw', 
    isa         => 'Path::Class::Dir',
    coerce      => 1,
);

has 'lexicon' => (
    is          => 'rw', 
    isa         => 'Lexicon',
    default     => 'gettext',
);

has 'options' => (
    is          => 'rw', 
    isa         => 'HashRef',
    default     => sub { return {} },
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
    
    my $path = $self->path() || Path::Class::Dir->new($app->config->{home},'l10n');
    $self->path($path);
    
    Class::MOP::load_class($class);
    
    # Load all avaliable po files
    foreach my $locale ( keys %{ $app->config->{I18N}{locales} } ) {
        $class->load_lexicon( 
            locale  => $locale, 
            path    => $path,
            type    => $self->lexicon,
            options => $self->options,
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
    Catalyst::Exception->throw(
              "Could not fetch lanuage handle: PO files for <"
            . $c->locale
            . "> might be missing or corrupt in path " . "<"
            . $c->path
            . ">" )
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
