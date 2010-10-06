# ============================================================================
package Catalyst::Helper::Model::L10N;
# ============================================================================

use strict;
use warnings;

use Path::Class;
use FindBin;

sub mk_compclass {
    my ($self, $helper) = @_;

    my %args = ();

    my $basedir = Path::Class::Dir->new( $FindBin::Bin, '..', 'lib');
    my $l10nmodule = $helper->{app}.'::'.$helper->{name};

    my @path = split (/\:\:/,$l10nmodule);
    my $file = pop @path;
    
    my $l10ndir = $basedir->subdir( join '/', @path );
    my $l10nfile = $l10ndir->file($file.'pm');
    $l10ndir->mkpath();
    
    $helper->render_file('l10nclass', $l10nfile->stringify, \%args);
    $helper->render_file('modelclass', $helper->{file}, \%args);
    
    return 1;
}

sub mk_comptest {
    my ($self, $helper) = @_;

    $helper->render_file('modeltest', $helper->{test});
}

=encoding utf8

=head1 NAME

Catalyst::Helper::Model::L10N - Helper for L10N models

=head1 SYNOPSIS

    script/myapp_create.pl model L10N L10N

=head1 DESCRIPTION

Helper for the L<Catalyst> L10N model.

=head1 ARGUMENTS

   ./script/myapp_create.pl model <model_name> L10N

You need to sepecify the C<model_name> (the name of the model).

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

=cut

1;

__DATA__

=begin pod_to_ignore

__l10nclass__
package [% app %]::[% name %];

use strict;
use warnings;
use parent qw(CatalystX::I18N::L10N);

1;

__modelclass__
package [% class %];

use strict;
use warnings;
use parent qw(CatalystX::I18N::Model::L10N);

1;

=head1 NAME

[% class %] - L10N Catalyst model component

=head1 SYNOPSIS

See L<[% app %]>.

=head1 DESCRIPTION

L10N Catalyst model component.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
__modeltest__
use strict;
use warnings;
use Test::More tests => 3;

use_ok('Catalyst::Test', '[% app %]');
use_ok('[% class %]');
use_ok('[% app %]::[% name %]');
