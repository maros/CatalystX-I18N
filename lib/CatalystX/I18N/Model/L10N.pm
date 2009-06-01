# ============================================================================
package CatalystX::I18N::Model::L10N;
# ============================================================================
use strict;
use warnings;

use Moose;
extends 'Catalyst::Model';

use Params::Coerce;
use Moose::Util::TypeConstraints;

enum 'Lexicon' => qw(auto gettext msgcat tie);

subtype 'Path' => as class_type('Path::Class::Dir');

coerce 'Path'
    => from 'Str'
        => via { 
            Path::Class::Dir->new( $_ ) 
        }
    => from 'ArrayRef[Str]'
        => via { 
            Path::Class::Dir->new( @{$_} ) 
        };
        
has 'class' => (
    is => 'rw', 
    isa => 'Lexicon',
);

has 'path' => (
    is => 'rw', 
    isa => 'Path',
    coerce => 1,
);

has 'lexicon' => (
    is => 'rw', 
    default => 'gettext',
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

    $c->config->{'L10N'} //= {};

    $c->config->{'L10N'}{class} //= ref($c) . '::L10N';
    $c->config->{'L10N'}{path}  //= '/opt/revdev/share/l10n';
    $c->config->{'L10N'}{lexicon}  //= 'gettext';

    $self->{l10nclass} = $c->config->{'L10N'}{class};
    $self->{path}  = $c->config->{'L10N'}{path};
    $self->{lexicon}  = $c->config->{'L10N'}{lexicon};

    eval( "use " . $self->{l10nclass} );
    die $@ if $@;

    foreach my $locale ( keys %{ $c->config->{I18N}{locales} } ) {
        $self->{l10nclass}->load_po_file( 
            locale  => $locale, 
            dir     => $self->{path},
            type    => 
        );
    }
    return $self;
}

=head3 ACCEPT_CONTEXT

Does the glueing! Setting the locale from the Session

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;

    my $l10nclass = $self->{l10nclass};

    # set locale and fallback
    my $handle = $l10nclass->get_handle( $c->locale );

    # Catch error
    Catalyst::Exception->throw(
              "Could not fetch lanuage handle: PO files for <"
            . $c->locale
            . "> might be missing or corrupt in path " . "<"
            . $c->config->{'Model::L10N'}{path}
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
