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
    my $directories = $params{directory};
    my $gettext_style = $params{gettext_style} // 1;
    
    $directories = [ $directories ]
        unless ref $directories eq 'ARRAY';
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
    
    # Loop all directories
    foreach my $directory (@$directories) {
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
            $lexicondata->{$locale} = \@locale_lexicon
                if scalar @locale_lexicon;
        }
    }
    
    # Fallback lexicon
    foreach my $locale (@$locales) {
        $lexicondata->{$locale} ||= ['Auto'];
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

CatalystX::I18N::L10N - Wrapper around Locale::Maketext

=head1 SYNOPSIS

 package MyApp::L10N;
 use parent qw(CatalystX::I18N::L10N);

=head1 DESCRIPTION

This class can be used as your L10N base-class. It is a simple wrapper around
L<Locale::Maketext> and provides methods for auto-loading lexicon files.
It is designed to work toghether with L<CatalystX::Model::L10N>.

You need to subclass this package in your project in order to use it.

=head1 MEDTHODS

=head3 load_lexicon

 MyApp::L10N->load_lexicon(
     locales         => ['de','de_AT'],
     directory       => '/path/to/your/l10/files', 
     # you can also supply multiple directories by adding an array ref
     gettext_style   => 0, # Default 1
 );

This method will search the given directories and load all available L10N
files via

=over

=item * Locale::Maketext::Lexicon::Gettext 

for *.mo and *.po files

=item * Locale::Maketext::Lexicon::Tie 

for *.db files. The files will be tied to you L10N class, thus you need to
implement the necessary tie methods in your class.

=item * Locale::Maketext::Lexicon::Msgcat 

for *.m files

=item * Locale::Maketext::Lexicon::Slurp 

for sub directories

=back

If no translation files can be found for a given locale then 
L<Locale::Maketext::Lexicon::Auto> will be loaded.

=head1 SEE ALSO

L<Locale::Maketext> and <Locale::Maketext::Lexicon>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>

