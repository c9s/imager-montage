package Imager::Montage;

use warnings;
use strict;

use Imager;
use Class::Trigger;

=head1 NAME

Imager::Montage - montage images 

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    # Generate a montage image.

    use Imager::Montage;

    my $im = Imager::Montage->new;
    my @imgs = <*.png>;
    my $page = $im->gen_page(
        {   
            files       => \@imgs,
            geometry_w  => 200,  
            geometry_h  => 200,  # if we aren't going to resize the source images , we should specify the geometry at least.
            cols        => 5,
            rows        => 5,
        }
    );
    $page->write( file => 'page.png' , type => 'png'  );  # generate a 1000x1000 pixels image with 5x5 tiles

=head1 EXPORT


=head1 Methods

=over 4

=item B<new>
=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}


=item _load_image

return a L<Imager> object

    $imager = $self->_load_image( $filename );

=cut

sub _load_image {
    my $self     = shift;
    my $filename = shift;
    my $o        = Imager->new;
    $o->read( file => $filename );
    return $o;
}

=item _load_font
    
Return L<Imager::Font>

    my $font = _load_font( { file => '/path/to/font.ttf' , color => '#000000' , size => 72 } );

=cut

sub _load_font {
    my ( $self , $args ) = @_;
    # get the font path
    my $color = Imager::Color->new(  $args->{color}  );
    my $font  = Imager::Font->new(
        file  => $args->{file},
        color => Imager::Color->new( $args->{color} ),
        size  => $args->{size},
    );
    return $font;
}

=item _load_color
    
return L<Imager::Color>

    $self->_load_color( '#000000' );

=cut

sub _load_color {
    my ( $self , $color ) = @_;
    return Imager::Color->new( $color ),
}


=item _calculate_page_height
=cut
sub _calculate_page_height {
    my $self = shift;
    my $args = shift;
    return $args->{frame} * 2 
        + ( $args->{border} * 2 ) * $args->{rows}
        + ( $args->{resize_h} || $args->{geometry_h} ) * $args->{rows}
        + ( $args->{cell_padding} * ( $args->{rows} - 1 ) )
        + ( $args->{margin_v} * 2 ) * $args->{rows};
}

=item _calculate_page_width
=cut
sub _calculate_page_width {
    my $self = shift;
    my $args = shift;
    return $args->{frame} * 2 
        + ( $args->{border} * 2 ) * $args->{cols}
        + ( $args->{resize_w} || $args->{geometry_w} )  * $args->{cols}
        + ( $args->{cell_padding} * ( $args->{cols} - 1 ) )
        + ( $args->{margin_h} * 2 ) * $args->{cols};
}

sub _calcuate_dist_x {
    my ( $self , $args ) = @_;
    return (  $args->{border} * 2 
            + $args->{margin_h} * 2
            + $args->{padding_h} * 2
            + $args->{cell_padding}
            + ( $args->{resize_w} || $args->{geometry_w} ) );
}
sub _calcuate_dist_y {
    my ( $self , $args ) = @_;
    return (  $args->{border} * 2 
            + $args->{margin_v} * 2
            + $args->{padding_v} * 2
            + $args->{cell_padding} 
            + ( $args->{resize_h} || $args->{geometry_h} ) );
}

=item _mk_frame
=cut
sub _mk_frame {
    my $self = shift;
    my $img  = shift;
    my $args = shift;

    $img->box(
        filled => 1,
        color  => $args->{frame_color} );

    my $box = Imager->new(
            xsize => $args->{page_args}->{xsize} - $args->{frame} * 2 ,
            ysize => $args->{page_args}->{ysize} - $args->{frame} * 2 
                )->box( filled => 1, color  => $args->{background_color});

    $img->paste(
        left => $args->{frame},
        top  => $args->{frame},
        src  => $box);
}

=item _mk_border
=cut
sub _mk_border {
    my ( $self , $page , $pos , $args ) = @_;
    my $box = Imager->new(
        xsize => ( $args->{resize_w} ||  $args->{geometry_w} ) + $args->{border} * 2 + $args->{padding_h} * 2,
        ysize => ( $args->{resize_h} ||  $args->{geometry_h} ) + $args->{border} * 2 + $args->{padding_v} * 2,
            )->box( filled => 1, color => $args->{border_color} );
    $page->paste(
        left => $pos->{left} + $args->{margin_h} ,
        top  => $pos->{top} + $args->{margin_v} , 
        src  => $box );
}

=item _init_color
=cut
sub _init_color {
    my $self = shift;
    my $args = shift;
    $args->{$_} ||= '#ffffff'
        for (qw/background_color border_color frame_color/);

    $args->{$_} = $self->_load_color( $args->{$_} )
        for (qw/background_color border_color frame_color/);

}

=item B<gen_page>

montage your source image .  it will return an L<Imager> Object.

    my $page = $im->gen_page( {
           files => \@imgs,

            # if we want to resize the images , we can ignore 'geometry_w' and 'geometry_h'
           resize_w    => 100,
           resize_h    => 100,
           resize_type => 'noprop',

           cols     => 3,
           rows     => 3,
           margin_v => 5,
           margin_h => 5,

           page_args => {    # Canvas Arguments
                          xsize    => 800,
                          ysize    => 600,
                          channels => 1,     # grayscale
                        },

           background_color => '#ffffff',

           flip => 'h',           # horizontal flip
           flip_exclude => sub { my $file = shift; $file =~ m/d\d+.png/ },

           # don't flip files named \d+.png  ( optional )

           frame       => 4,           # ( optional )
           frame_color => '#000000',

           border       => 4,
           border_color => '#000000',

           res => 600,
    } );

Parameters:

I<files>: an array contains filenames

I<background_color>: background color of output image

I<geometry_h, geometry_w>:  geometry from source. if not set , the resize_w , resize_h will be the default

I<resize_w, resize_h>): if it's given , montage will resize your source image to this size

I<cols, rows>: tiles.

I<margin_v,margin_h>: margin for each image

I<page_args>:  arguments for canvas

I<flip>: do flip to each source image

I<flip_exclude>

I<frame>: frame width (optional)

I<frame_color>: frame color (optional)

I<border>:  border width for each image (optional)

I<border_color>:    border color (optional)

I<res>: resolution , default resolution is 600 (optional)

I<padding_h>:

I<padding_v>:

I<cutting_line>:

=cut


sub gen_page {
    my ( $self , $args ) = @_;

    # $args->{geometry_w} ||= $args->{resize_w};
    # $args->{geometry_h} ||= $args->{resize_h};

    $args->{$_} ||= 0 for ( qw/border frame margin_v margin_h padding_v padding_h cell_padding/ );

    $args->{padding_v} = $args->{padding_h} = $args->{padding} if ( $args->{padding} );
    $args->{margin_v}  = $args->{margin_h}  = $args->{margin}  if ( $args->{margin} );

    $args->{page_args}->{xsize} ||= $self->_calculate_page_width( $args );
    $args->{page_args}->{ysize} ||= $self->_calculate_page_height( $args );

    $self->_init_color( $args );

    # if cols/rows are not given
    if ( ! exists $args->{cols} and ! exists $args->{rows} ) {
        # XXX: calculates the cols and rows if we only specify the page width and page height
    }

    # create a page
    my $page_img = Imager->new( %{ $args->{ page_args } } );

    $self->_set_resolution( $page_img, $args->{res} )
        if ( exists $args->{res} );

    # this could make a frame for page
    if ( exists $args->{frame} ) {
        $self->_mk_frame( $page_img , $args );
    }
    else {
        $page_img->box( filled => 1, color => $args->{background_color}, );
    }

    my ( $top, $left ) = ( $args->{frame}, $args->{frame} );

    # default direction is vertical
    $args->{direction} ||= 'v';


    if ( $args->{direction} eq 'v' ) { 
        # Vertical Direction                        {{{
        for ( my $col = 0 ; $col < $args->{cols} ;
                            $left += $self->_calcuate_dist_x( $args ) , 
                            $col++ ) {

            $top = $args->{frame};

            for ( my $row = 0 ; $row < $args->{rows} ; 
                                $top += $self->_calcuate_dist_y( $args ), 
                                $row++ ) {
                                
                # get filename
                my $file = ${ $args->{files} }[ $col * $args->{rows} + $row ];
                next if ( ! defined $file );

                my $canvas_img = $self->_load_image($file);
                $self->call_trigger( 'after_loadcanvas' , $canvas_img );

                # resize it if we define a new size
                if ( exists $args->{resize_w} ) {
                    $canvas_img = $canvas_img->scale( xpixels => $args->{resize_w},
                                                      ypixels => $args->{resize_h},
                                                      type    => $args->{resize_type} || 'nonprop' );
                }
                $self->call_trigger( 'after_resizecanvas' , $canvas_img );

                # XXX: do flip in call_trigger
                if ( exists $args->{flip}
                     and ( exists $args->{flip_exclude} and !$args->{flip_exclude}->( $file ) ) )
                {
                    $canvas_img->flip( dir => $args->{flip} );
                }

                # if border is set
                if( $args->{border} ) {
                    # create a border , actually we create a box on the page
                    $self->_mk_border( $page_img, { left => $left, top => $top }, $args );
                } 

                # paste our image
                $page_img->paste(
                    left => $left + $args->{margin_h} + $args->{border} + $args->{padding_h} ,  # default border is 0
                    top  => $top + $args->{margin_v} + $args->{border} + $args->{padding_v} ,
                    src  => $canvas_img );

            }
        } 
        # }}}
    } 
    elsif( $args->{direction} eq 'h' )  {
        # Horizontal Direction {{{

        for my $row ( 0 .. $args->{rows} - 1 ) {
            # return to the horizontal first canvas
            $left = $args->{frame};

            for my $col ( 0 .. $args->{cols} - 1 ) {


                # get filename
                my $file = ${ $args->{files} }[ $row * $args->{cols} + $col ];
                next if ( ! defined $file );

                my $canvas_img = $self->_load_image($file);
                $self->call_trigger( 'after_loadcanvas' , $canvas_img );

                # resize it if we define a new size
                if ( exists $args->{resize_w} ) {
                    $canvas_img = $canvas_img->scale(
                        xpixels => $args->{resize_w},
                        ypixels => $args->{resize_h},
                        type    => $args->{resize_type} || 'nonprop'
                    );
                }
                $self->call_trigger( 'after_resizecanvas' , $canvas_img );

                # flip
                if ( exists $args->{flip}
                    and ( exists $args->{flip_exclude} and ! $args->{flip_exclude}->($file) ) ) {
                    $canvas_img->flip( dir => $args->{flip} ); 
                }

                # if border is set
                if( $args->{border} ) {
                    # create a border , actually we are creating a box on the page
                    $self->_mk_border( $page_img, { left => $left, top => $top }, $args );
                } 

                # paste our image
                $page_img->paste(
                    left => $left + $args->{margin_h} + $args->{border} + $args->{padding_h} ,  # default border is 0
                    top  => $top + $args->{margin_v} + $args->{border} + $args->{padding_v} ,
                    src  => $canvas_img );

            } continue { $left += $self->_calcuate_dist_x( $args ); }
        } 
        continue { $top += $self->_calcuate_dist_y( $args ); }
        # }}}
    }

    return $page_img;
}


# XXX: deprecated
sub _draw_cutting_line {
    my $self     = shift;
    my $page_img = shift;
    my $args     = shift;
    my ( $top, $left ) = ( $args->{frame}, $args->{frame} );
    for ( my $col = 0 ; $col <= $args->{cols};
          $left += $self->_calcuate_dist_x( $args ), $col++ )
    {

        $page_img->line( x1 => $left,
                         y1 => 0 - $args->{cutting_line_outer} ,
                         x2 => $left,
                         y2 => $args->{page_args}->{ysize} + $args->{cutting_line_outer} );

        $top = $args->{frame};
        for ( my $row = 0 ; $row <= $args->{rows} ;
              $top += $self->_calcuate_dist_y( $args ), $row++ )
        {

            $page_img->line( x1 => 0 - $args->{cutting_line_outer} ,
                             y1 => $top,
                             x2 => $args->{page_args}->{xsize} + $args->{cutting_line_outer},
                             y2 => $top );
        }
    }
}


=item draw_cutting_line

Args
    page_width
    page_height

    start_x
    start_y

    canvas_width
    canvas_height

    border_width
    cols
    rows
    outer

=cut

sub draw_cutting_line {
    my $self     = shift;
    my $page_img = shift;
    my $args     = shift;

    my ( $top, $left ) = ( $args->{start_y}, $args->{start_x} );

    $args->{page_width} ||= ( ( $args->{cols} + 1 ) * $args->{border_width} )
                            + ( $args->{canvas_width} * $args->{cols} ) ;

    $args->{page_height} ||= ( ( $args->{rows} + 1 ) * $args->{border_width} )
                            + ( $args->{canvas_height} * $args->{rows} );

    for ( my $col = 0 ; $col <= $args->{cols} ; 
                        $left += ($args->{canvas_width} + $args->{border_width}) , 
                        $col++ ) {

        for ( 0 .. $args->{border_width} - 1 ) {
            $page_img->line( x1 => $left + $_,
                             y1 => $args->{start_y} - $args->{outer},
                             x2 => $left + $_,
                             y2 => $args->{start_y} );

            $page_img->line( x1 => $left + $_,
                             y1 => $args->{start_y} + $args->{page_height},
                             x2 => $left + $_,
                             y2 => $args->{start_y} + $args->{page_height} + $args->{outer} );
        }

        $top = $args->{start_y};
        for ( my $row = 0 ; $row <= $args->{rows} ; 
                            $top += ($args->{canvas_height} + $args->{border_width}), 
                            $row++ ) {

                for ( 0 .. $args->{border_width} - 1 ) {
                    $page_img->line( x1 => $args->{start_x} - $args->{outer},
                                     y1 => $top + $_,
                                     x2 => $args->{start_x},
                                     y2 => $top + $_ );

                    $page_img->line( x1 => $args->{start_x} + $args->{page_width},
                                     y1 => $top + $_,
                                     x2 => $args->{start_x} + $args->{page_width} + $args->{outer},
                                     y2 => $top + $_ );
                }
        }
    }
}

=item B<_set_resolution>

default resolution is 600 dpi

    $self->_set_resolution( $filename , 600 );
    $self->_set_resolution( $imager  );

=cut
sub _set_resolution {
    my $self = shift;
    my $src  = shift;
    my $res  = shift || 600;
    if ( "$src" =~ m/^Imager/ ) {
        # use Imager to set resolution
        $src->settag( name => 'i_xres', value => $res );
        $src->settag( name => 'i_yres', value => $res );
    }
    elsif ( ref(\$src) eq 'SCALAR' ) { # it's a filename
        my $image = Imager->new();
        $image->read( file => $src );    # read from file
        $image->settag( name => 'i_xres', value => $res );
        $image->settag( name => 'i_yres', value => $res );
        $image->write( file => $src, type => 'png' );    # write to reference
    }
    else {
        warn "Can't setup resolution";
    }
}

=back

=head1 SEE ALSO 
L<Imager>.

=head1 AUTHOR

Cornelius, C<< <c9s at aiink.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-imager-montage at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Imager-Montage>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Imager::Montage

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Imager-Montage>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Imager-Montage>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Imager-Montage>

=item * Search CPAN

L<http://search.cpan.org/dist/Imager-Montage>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2007 Cornelius, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut


1;    # End of Imager::Montage
