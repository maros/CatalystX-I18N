# ============================================================================
package CatalystX::I18N::Model::L10N;
# ============================================================================

use Moose;
extends 'Catalyst::Model';

use Moose::Util::TypeConstraints;

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

sub BUILD {
    my ( $self, $c, @args ) = @_;
    
    $self = $self->next::method( $c, @args );
    
    my $class = $self->class() || ref($c) . '::L10N';
    $self->class($class);
    
    Class::MOP::load_class($class);
    
    # Load all avaliable po files
    foreach my $locale ( keys %{ $c->config->{I18N}{locales} } ) {
        $class->load_po_file( 
            locale  => $locale, 
            dir     => $self->path,
            type    => $self->lexicon,
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

__PACKAGE__->meta->make_immutable();

1;

__END__


=head1 AUTHOR

REVDEV, C<< we@revdev.at >>

=head1 COPYRIGHT

Copyright 2008 REVDEV. All rights reserved.

=cut
