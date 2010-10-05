# ============================================================================
package CatalystX::I18N::L10N;
# ============================================================================

use strict;
use warnings;
use 5.010;

use parent qw(Locale::Maketext);

use Locale::Maketext::Lexicon;
#use Locale::Maketext::Lexicon::Gettext;
use Path::Class;

sub load_lexicon {
    my ( $class, %params ) = @_;

    my $locales = $params{locales} || [];
    my $directories = $params{directories};
    my $gettext_style = $params{gettext_style} // 1;
    my $inheritance = $params{inheritance} // {};
    
    $directories = [ $directories ]
        if defined $directories
        && ref $directories ne 'ARRAY';
    $directories ||= [];
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
    
    my %locale_loaded;
    
    # Loop all directories
    foreach my $directory (@$directories) {
        next 
            unless defined $directory;
        
        $directory = Path::Class::Dir->new($directory)
            unless ref $directory eq 'Path::Class::Dir';
        
        next
            unless -d $directory->stringify && -e _ && -r _;
        
        my @directory_content =  $directory->children();
        
        # Load all avaliable po files
        foreach my $locale (@$locales) {
            my $lc_locale = lc($locale);
            $lc_locale =~ s/-/_/g;
            my @locale_lexicon;
            foreach my $content (@directory_content) {
                if ($content->is_dir) {
                    push(@locale_lexicon,'Slurp',$content->stringify)
                        if $content->basename eq $locale;
                } else {
                    given ($content->basename) {
                        when(m/^$locale\.(mo|po)$/i) {
                            push(@locale_lexicon,'Gettext',$content->stringify);
                        }
                        when(m/^$locale\.m$/i) {
                            push(@locale_lexicon,'Msgcat',$content->stringify);
                        }
                        when(m/^$locale\.db$/i) {
                            push(@locale_lexicon,'Tie',[ $class, $content->stringify ]);
                        }
                        when(m/^$lc_locale\.pm$/) {
                            $locale_loaded{$locale} = 1;
                            require $content->stringify;
                            # TODO transform maketext -> gettext syntax if flag is set
                            # Locale::Maketext::Lexicon::Gettext::_gettext_to_maketext
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
        next
            if exists $inheritance->{$locale};
        next
            if exists $locale_loaded{$locale};
        $lexicondata->{$locale} ||= ['Auto'];
    }
    
    eval qq[
        package $class;
        Locale::Maketext::Lexicon->import(\$lexicondata)
    ];
    
    while (my ($locale,$inherit) = each %$inheritance) {
        my $locale_class = lc($locale);
        my $inherit_class = lc($inherit);
        $locale_class =~ s/-/_/g;
        $inherit_class =~ s/-/_/g;
        $locale_class = $class.'::'.$locale_class;
        $inherit_class = $class.'::'.$inherit_class;
        no strict 'refs';
        push(@{$locale_class.'::ISA'},$inherit_class);
    }
    
    die("Could not load Locale::Maketext::Lexicon") if $@;
    return;
}

sub set_lexicon {
    my ( $class, $locale, $lexicon ) = @_;
    
    $locale = lc($locale);
    $locale =~ s/-/_/g;
        
    no strict 'refs';
    %{$class .'::'.$locale.'::Lexicon'} = %{$lexicon};
    return;
}

1;

=head1 NAME

CatalystX::I18N::L10N - Wrapper around Locale::Maketext

=head1 SYNOPSIS

 package MyApp::L10N;
 use parent qw(CatalystX::I18N::L10N);

=head1 DESCRIPTION

This class can be used as your L10N base-class. It is a wrapper around
L<Locale::Maketext> and provides methods for auto-loading lexicon files.
It is designed to work toghether with L<CatalystX::Model::L10N>.

You need to subclass this package in your project in order to use it.

=head1 MEDTHODS

=head3 load_lexicon

 MyApp::L10N->load_lexicon(
     locales        => ['de','de_AT'],              # Required
     directories    => ['/path/to/your/l10/files'], # Required
     gettext_style  => 0,                           # Optional, Default 1
     inheritance    => {                            # Optional
         de_AT          => 'de',
     },
 );

This method will search the given directories and load all available L10N
files for the requested locales via

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

The folowing parameters are recognized/required

=over

=item * locales

Array reference of locales. 

Required

=item * directories

Array reference of directories. Also accepts L<Path::Class::Dir> objects
and single values.

Required

=item * gettext_style

Enable gettext style. L<%quant(%1,document,documents)> instead of 
L<[quant,_1,document,documents]>

Optional, Default TRUE

=item * inherit

=back

=head1 SEE ALSO

L<Locale::Maketext> and <Locale::Maketext::Lexicon>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>

