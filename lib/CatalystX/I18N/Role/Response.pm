# ============================================================================
package CatalystX::I18N::Role::Response;
# ============================================================================

use Moose::Role;

sub init_meta {
    Catalyst::Request->meta->add_role('CatalystX::I18N::Role::_Response');
}

# ============================================================================
package CatalystX::I18N::Role::_Response;
# ============================================================================

use Moose::Role;

sub content_language {
    my ($self,@languages) = @_;
    
    if (scalar @languages) {
        my $language = join(', ',@languages);
        return $self->headers->header( 'Content-Language' => $language );
    } else {
        return $self->header->header( 'Content-Language' );
    }
}

1;