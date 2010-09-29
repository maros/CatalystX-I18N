# Load the Module::Install bundled in ./inc/
use strict;
use inc::Module::Install;

# Define metadata
name            'CatalystX-I18N';
all_from        'lib/CatalystX/I18N.pm';

perl_version    '5.000';

# Specific dependencies
requires        'Catalyst::Runtime'         => '5.80004';
requires        'Moose'                     => 0;

requires        'Clone'                     => 0;
requires        'MooseX::Types::Path::Class'=> 0; 
requires        'CatalystX::RoleApplicator' => 0;

requires        'Locale::Maketext::Lexicon' => 0;
requires        'Locale::Maketext'          => 0;
requires        'Locale::Geocode'           => 0;

requires        'DateTime'                  => 0;
requires        'DateTime::Locale'          => 0;
requires        'DateTime::Format::CLDR'    => 0;
requires        'DateTime::TimeZone'        => 0;

requires        'IP::Country::Fast'         => 0;
requires        'HTTP::BrowserDetect'       => '1.09';

repository 'git://github.com/maros/CatalystX-I18N.git';

WriteAll;