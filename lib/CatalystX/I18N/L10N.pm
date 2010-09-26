# ============================================================================
package CatalystX::I18N::L10N;
# ============================================================================

use strict;
use warnings;
use 5.010;

use parent qw(Locale::Maketext);

use Locale::Maketext::Lexicon;
use Path::Class;

sub load_lexicon {
    my ( $class, %params ) = @_;

    my $locales = $params{locales} || [];
    my $directory = $params{directory};
    my $gettext_style = $params{gettext_style} // 1;
    
    $locales = [ $locales ]
        unless ref $locales eq 'ARRAY';
    
    die "Invalid locales"
        unless defined $locales
        && scalar @$locales > 0
        && ! grep {  $_ !~ /^([a-z]{2})(_[A-Z]{2})?$/ } @$locales;
    
    my $lexicondata = {
        _decode => 1,
    };
    $lexicondata->{_style} = 'gettext'
        if $gettext_style;
    
    unless (defined $directory) {
        foreach my $locale (@$locales) {
            $lexicondata->{$locale} = ['Auto'];
        }
    } else {
        $directory = Path::Class::Dir->new($directory)
            unless ref $directory eq 'Path::Class::Dir';
        my @directory_content =  $directory->children();
        
        # Load all avaliable po files
        foreach my $locale (@$locales) {
            my @locale_lexicon;
            foreach my $content (@directory_content) {
                if ($content->is_dir) {
                    push(@locale_lexicon,'Slurp',$content->stringify)
                        if $content->basename eq $locale;
                } else {
                    given ($content->basename) {
                        when(m/^$locale\.(mo|po)$/) {
                            push(@locale_lexicon,'Gettext',$content->stringify);
                        }
                        when(m/^$locale\.m$/) {
                            push(@locale_lexicon,'Msgcat',$content->stringify);
                        }
                        when(m/^$locale\.db$/) {
                            push(@locale_lexicon,'Tie',[ $class, $content->stringify ]);
                        }
                    }
                }
            }
            push(@locale_lexicon,'Auto')
                unless scalar @locale_lexicon;
            $lexicondata->{$locale} = \@locale_lexicon;
        }
    }
    
    eval qq[
        package $class;
        Locale::Maketext::Lexicon->import(\$lexicondata)
    ];
    die("Could not load Locale::Maketext::Lexicon") if $@;
    return;
}

sub set_lexicon {
    my ( $class, $locale, $lexicon ) = @_;
    
    my $variable = $class .'::'.$locale.'::Lexicon';
    no strict 'refs';
    ${$variable} = $lexicon;
    return
}

1;

=head1 NAME

RevDev::Catalyst::L10N - Localisation base class

=head1 DESCRIPTION

This is the base L10N base class. It implements 
general localisation methods. It has no user maintainable parts inside.

=head1 MEDTHODS

=head3 load_po_file

    RevDev::Catalyst::L10N->load_po_file( $locale, $dir );

Reloads a po file.

C<$locale> has to be a valid locale string (eg 'de_AT', 'de').


=head1 SEE ALSO

L<Locale::Maketext> and <Locale::Maketext::Lexicon>

=head1 AUTHOR

REVDEV, C<< we@revdev.at >>

=head1 COPYRIGHT

Copyright 2008 REVDEV. All rights reserved.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.
