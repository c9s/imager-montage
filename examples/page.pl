#!perl -W
use lib '../lib';

use Imager::Montage;
use File::chdir;

my $im = Imager::Montage->new;

$CWD = 'images';
my @imgs = <*.png>;

for (@imgs) {
    print;
    print "\n";
}

print "gen page1\n";
my $page = $im->gen_page(
    {   files      => \@imgs,
        geometry_w => 300
        , # geometry from source. if not set , the resize_w , resize_h will be the default
        geometry_h => 250,

        resize_w => 100,    # resize your source image
        resize_h => 100,

        cols => 5,
        rows => 5,

        margin_v => 1,     # margin for each image
        margin_h => 1,

        page_args => {
            xsize  => 1024,    # the output image width & height
            ysize => 1024,
        },

        flip  => 'h',          # do horizontal flip
        frame => 100,
        res   => 600,          # resolution
    }
);
$page->write( file => '../output1.png', type => 'png' );

print "gen page2\n";
$page = $im->gen_page(
    {   files    => \@imgs,
        resize_w => 300,       # resize your source image
        resize_h => 250,

        cols => 3,
        rows => 5,

        margin_v => 56,        # margin for each image
        margin_h => 12,

        page_args => {
            xsize  => 800,    # the output image width & height
            ysize => 600,
        },

        flip  => 'h',          # do horizontal flip
        frame => 20,
        res   => 600,          # resolution
    }
);
$page->write( file => '../output2.png', type => 'png' );

print "gen page3\n";
$page = $im->gen_page(
    {   files    => \@imgs,
        resize_w => 100,       # resize your source image
        resize_h => 100,

        cols => 3,
        rows => 3,

        margin_v    => 1,     # margin for each image
        margin_h    => 1,
        page_args => {
            xsize  => 800,    # the output image width & height
            ysize => 800,
        },
        flip        => 'h',    # do horizontal flip
        flip_exclude => sub { my $file = shift ; $file =~ m/\d+.png/ } ,   # don't flip files named \d+.png

        background_color => '#FFFFAA',

        frame       => 10,
        frame_color => '#000000',

        border       => 10,
        border_color => '#000000',
    }
);

$page->write( file => '../output3.png', type => 'png' );

print "gen page4\n";
$page = $im->gen_page(
    {   files => \@imgs,

        resize_w => 300,    # resize your source image
        resize_h => 250,

        cols => 3,
        rows => 5,

        margin_v => 36,     # margin for each image
        margin_h => 36,

        flip => 'h',        # do horizontal flip
        flip_exclude =>
            sub { my $file = shift; $file =~ m/\d+.png/} ,   # don't flip files named \d+.png

        background_color => '#FFFFAA',

        frame       => 50,
        frame_color => '#000000',

        border       => 20,
        border_color => '#000000',
    }
);

$page->write( file => '../output4.png', type => 'png' );



print "gen page5\n";
$page = $im->gen_page(
    {   files => \@imgs,

        page_args => { channels => 1 },

        resize_w => 300,    # resize your source image
        resize_h => 250,

        cols => 3,
        rows => 5,

        margin_v => 36,     # margin for each image
        margin_h => 36,

        flip => 'h',        # do horizontal flip
        flip_exclude =>
            sub { my $file = shift; $file =~ m/\d+.png/} ,   # don't flip files named \d+.png

        background_color => '#FFFFAA',

        frame       => 50,
        frame_color => '#000000',

        border       => 20,
        border_color => '#000000',
    }
);

$page->write( file => '../output5.png', type => 'png' );

