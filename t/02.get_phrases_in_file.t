use Test::More tests => 34;

use File::Temp ();
require bytes;    # just want function not pragma

BEGIN {
    use_ok('Text::Extract::MaketextCallPhrases');
}

diag("Testing Text::Extract::MaketextCallPhrases $Text::Extract::MaketextCallPhrases::VERSION");
my ( $fh, $filename ) = File::Temp::tempfile();
seek( $fh, 0, 0 );
my $guts = _get_guts();
print {$fh} $guts;
truncate( $fh, bytes::length($guts) );
seek( $fh, 0, 0 );

is( -s $filename, bytes::length($guts), 'Tmpt file sanityc check' );

my $result_ar = get_phrases_in_file($filename);

is( $result_ar->[0]->{'phrase'}, 'Greeting Programs', 'single line - phrase' );
is( $result_ar->[0]->{'line'},   1,                   'single line - line' );
is( $result_ar->[0]->{'offset'}, 9,                   'single line - offset' );
is( $result_ar->[0]->{'file'},   $filename,           'single line - file' );

is( $result_ar->[1]->{'phrase'}, "I say, lovely weather\nwe are having today.", 'two lines - phrase' );
is( $result_ar->[1]->{'line'},   3,                                             'two lines - line' );
is( $result_ar->[1]->{'offset'}, 9,                                             'two lines - offset' );
is( $result_ar->[1]->{'file'},   $filename,                                     'two lines - file' );

is( $result_ar->[2]->{'phrase'}, "Dear diary, \n\nThis is not a secret.\n\nChuck Norris uses Perl\n", 'multiple lines - phrase' );
is( $result_ar->[2]->{'line'},   6,                                                                   'multiple lines - line' );
is( $result_ar->[2]->{'offset'}, 9,                                                                   'multiple lines - offset' );
is( $result_ar->[2]->{'file'},   $filename,                                                           'multiple lines - file' );

is( $result_ar->[3]->{'phrase'}, "A single line on a different line.", 'different, single line - phrase' );
{
    local $TODO = "Issue #10";
    is( $result_ar->[3]->{'line'},   14, 'different, single line - line' );
    is( $result_ar->[3]->{'offset'}, 4,  'different, single line - offset' );
}
is( $result_ar->[3]->{'file'}, $filename, 'different, single line - file' );

is( $result_ar->[4]->{'phrase'}, "Multiple lines.\n\nAfter the maketext call.", 'different, multiple lines - phrase' );
{
    local $TODO = "Issue #10";
    is( $result_ar->[4]->{'line'},   18, 'different, multiple lines - line' );
    is( $result_ar->[4]->{'offset'}, 4,  'different, multiple lines - offset' );
}
is( $result_ar->[4]->{'file'}, $filename, 'different, multiple lines - file' );

is( $result_ar->[5]->{'phrase'}, "Longer maketext call", 'object, one line - phrase' );
is( $result_ar->[5]->{'line'},   23,                     'object, one line - line' );
is( $result_ar->[5]->{'offset'}, 27,                     'object, one line - offset' );
is( $result_ar->[5]->{'file'},   $filename,              'object, one line - file' );

is( $result_ar->[6]->{'phrase'}, "Longer, two line\nmaketext call", 'object, two lines - phrase' );
is( $result_ar->[6]->{'line'}, 25, 'object, two lines - line' );
{
    local $TODO = "Issue #10";
    is( $result_ar->[6]->{'offset'}, 15, 'object, two lines - offset' );
}
is( $result_ar->[6]->{'file'}, $filename, 'object, two lines - file' );

is( $result_ar->[7]->{'phrase'}, "Longer maketext call with text on a separate line", 'object, different line - phrase' );
{
    local $TODO = "Issue #10";
    is( $result_ar->[7]->{'line'},   29, 'object, different line - line' );
    is( $result_ar->[7]->{'offset'}, 4,  'object, different line - offset' );
}
is( $result_ar->[7]->{'file'}, $filename, 'object, different line - file' );

# This should not be needed but just to be extra vigilant
close $fh;
unlink $filename;

# / This should not be needed but just to be extra vigilant

sub _get_guts {
    return <<'END_GUTS';
maketext("Greeting Programs"); 

maketext('I say, lovely weather
we are having today.');

maketext('Dear diary, 

This is not a secret.

Chuck Norris uses Perl
');

maketext(
    q{A single line on a different line.}
);

maketext(
    qq{Multiple lines.

After the maketext call.}
);

Locale::Maketext::maketext('Longer maketext call');

$obj->maketext('Longer, two line
maketext call');

$obj->maketext(
    'Longer maketext call with text on a separate line'
);

END_GUTS
}
