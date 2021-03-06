! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USE: accessors
USE: arrays
USE: assocs
USE: colors.constants
USE: combinators
USE: destructors
USE: fonts
USE: fry
USE: io
USE: io.streams.string
USE: io.styles
USE: kernel
USE: memoize
USE: pdf.layout
USE: pdf.text
USE: sequences
USE: splitting
USE: strings

IN: pdf.streams

<PRIVATE

! FIXME: what about "proper" tab support?

: string>texts ( string style -- seq )
    [ string-lines ] dip '[ _ <text> 1array ] map
    <br> 1array join ;

PRIVATE>


TUPLE: pdf-writer style data ;

: new-pdf-writer ( class -- pdf-writer )
    new H{ } >>style V{ } clone >>data ;

: <pdf-writer> ( -- pdf-writer )
    pdf-writer new-pdf-writer ;

: with-pdf-writer ( quot -- pdf )
    <pdf-writer> [ swap with-output-stream* ] keep data>> ; inline



TUPLE: pdf-sub-stream < pdf-writer parent ;

: new-pdf-sub-stream ( style stream class -- stream )
    new-pdf-writer
        swap >>parent
        swap >>style
    dup parent>> style>> '[ _ swap assoc-union ] change-style ;

! FIXME: M: pdf-sub-stream dispose throw ;

TUPLE: pdf-block-stream < pdf-sub-stream ;

M: pdf-block-stream dispose
    [ data>> ] [ parent>> ] bi
    [ data>> push-all ] [ stream-nl ] bi ;

TUPLE: pdf-span-stream < pdf-sub-stream ;

M: pdf-span-stream dispose
    [ data>> ] [ parent>> data>> ] bi push-all ;



! Stream protocol
M: pdf-writer stream-flush drop ;

M: pdf-writer stream-write1
    dup style>> '[ 1string _ <text> ] [ data>> ] bi* push ;

M: pdf-writer stream-write
    dup style>> '[ _ string>texts ] [ data>> ] bi* push-all ;

M: pdf-writer stream-format
    swap [ dup style>> ] dip assoc-union
    '[ _ string>texts ] [ data>> ] bi* push-all ;

M: pdf-writer stream-nl
    <br> swap data>> push ; ! FIXME: <br> needs style?

M: pdf-writer make-span-stream
    pdf-span-stream new-pdf-sub-stream ;

M: pdf-writer make-block-stream
    pdf-block-stream new-pdf-sub-stream ;

M: pdf-writer make-cell-stream
    pdf-sub-stream new-pdf-sub-stream ;

! FIXME: poor man's table cells -- just set min-width to max
! width of cells in column with cell-padding
M: pdf-writer stream-write-table
    nip data>> dup '[
        [ data>> _ push-all ] each <br> _ push
    ] each ;

M: pdf-writer dispose drop ;


