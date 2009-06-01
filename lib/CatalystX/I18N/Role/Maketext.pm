# ============================================================================
package CatalystX::I18N::Role::L10N;
# ============================================================================

use Moose::Role;
requires 'l10nhandle';

use strict;
use warnings;
use 5.010;
 
=head3 maketext

 my $msgstr_localized = $c->maketext($msgid[,@parameters]);

=cut

sub maketext {
    my ($c,$msgid,@args) = @_;

    my @args_expand;
    foreach my $arg (@args) {
        push @args_expand,
            (ref $arg eq 'ARRAY') ? @$arg : $arg;
    }

    my $handle = $c->l10nhandle;
    my $msgstr = $handle->maketext( $msgid, @args_expand );
    
    return $msgstr
        if defined $msgstr;
    
    # Method expansion
    my $replacesub = sub {
        my $method = shift;
        my @params = split(/,/,shift);
        if ($handle->can($method)) {
            return $handle->$method(@params);
        }
        return $method;
    };
        
    $msgstr = $msgid;
    $msgstr =~s{%(\d+)}{ $args[$1-1] // 'missing value %'.$1 }eg;
    $msgstr =~s/%(\w+)\(([^)]+)\)/$replacesub->($1,$2)/eg;    
    return $msgstr;
}

*localize = \&maketext;


1;