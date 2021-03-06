! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators formatting kernel make math math.parser
sequences ;

IN: elapsed

: elapsed-time ( seconds -- string )
    dup 0 < [ "negative seconds" throw ] when [
        {
            { 60 "s" }
            { 60 "m" }
            { 24 "h" }
            {  7 "d" }
            { 52 "w" }
            {  f "y" }
        } [
            [ first [ /mod ] [ dup ] if* ] [ second ] bi swap
            dup 0 > [ number>string prepend , ] [ 2drop ] if
        ] each drop
    ] { } make [ "0s" ] [ reverse " " join ] if-empty ;

: relative-time ( seconds -- string )
    dup 0 < [ "negative seconds" throw ] when {
        { [ dup 1 < ] [ drop "just now" ] }
        { [ dup 60 < ] [ drop "less than a minute ago" ] }
        { [ dup 120 < ] [ drop "about a minute ago" ] }
        { [ dup 2700 < ] [ 60 / "%d minutes ago" sprintf ] }
        { [ dup 5400 < ] [ drop "about an hour ago" ] }
        { [ dup 86400 < ] [ 3600 / "%d hours ago" sprintf ] }
        { [ dup 172800 < ] [ drop "1 day ago" ] }
        [ 86400 / "%d days ago" sprintf ]
    } cond ;


