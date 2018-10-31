package provide mediancut 
 
 namespace eval mediancut {
     namespace export reduce
 }
 
 proc mediancut::reduce {src dest depth} {
 
     variable new
 
     set new(count) 0
 
     set w [image width $src]
     set h [image height $src]
 
     set pixList [list]
 
     for {set y 0} {$y < $h} {incr y} {
         for {set x 0} {$x < $w} {incr x} {
             
             lappend pixList [$src get $x $y]
         }
     }
 
     subdivide $pixList $depth
 
     apply $src $dest
 
     return $new(count)
 }
 
 proc mediancut::subdivide {pixList depth} {
     
     variable new
     
     set num [llength $pixList]
     
     for {set i 0} {$i < 256} {incr i} {
         set n(r,$i) 0
         set n(g,$i) 0
         set n(b,$i) 0
     }
     
     foreach pix $pixList {
         foreach {r g b} $pix break
         incr n(r,$r)
         incr n(g,$g)
         incr n(b,$b)
     }
     
     # Work out which colour has the widest range
     
     foreach col [list r g b] {
         
         set l($col) [list]
         
         for {set i 0} {$i < 256} {incr i} {
             
             if { $n($col,$i) != 0 } {
                 lappend l($col) $i
             }
         }
         
         set range($col) [expr {[lindex $l($col) end] - [lindex $l($col) 0]}]
     }
     
     if { $depth == 0 || ($range(r) == 0 && $range(g) == 0 && $range(b) == 0) } {
         
         # Average colours
         
         # puts "Average colour for $num pixels"
         # puts "Range: $range(r) $range(g) $range(b)"
         
         foreach col [list r g b] {
             set tot 0
             foreach entry $l($col) {
                 incr tot [expr {$n($col,$entry) * $entry}]
             }
             set av($col) [expr {$tot / $num}]
         }
         
         set newpixel [list $av(r) $av(g) $av(b)]
         set fpixel [format "#%02x%02x%02x" $av(r) $av(g) $av(b)]
         
         # puts "Colour: $newpixel"
         
         foreach entry $pixList {
             
             set new($entry) $fpixel
         }
         incr new(count)
         
     } else {
         
         # Find out which colour has the maximum range (green, red, blue in order of importance)
         set maxrange -1
         foreach col [list g r b] {
             
             if { $range($col) > $maxrange } {
                 set splitcol $col
                 set maxrange $range($col)
             }
         }
         
         # Now work out where to split it
         set thres [expr {$num / 2}]
         
         set pn 0
         set tn 0
         set pl [lindex $l($splitcol) 0]
         
         foreach tl $l($splitcol) {
             
             incr tn $n($splitcol,$tl)
             
             if { $tn > $thres } {
                 
                 if { $tn - $thres < $thres - $pn } {
                     set cutnum $tl
                 } else {
                     set cutnum $pl
                 }
                 break
             }
             
             set pn $tn
             set pl $tl
         }
         
         # puts "Need to split $splitcol at $cutnum"
         
         # Now split the pixels into the 2 lists
         
         set hiList [list]
         set loList [list]
         
         set i [lsearch [list r g b] $splitcol]
         foreach entry $pixList {
             if { [lindex $entry $i] <= $cutnum } {
                 lappend loList $entry
             } else {
                 lappend hiList $entry
             }
         }
         
         incr depth -1
         
         subdivide $loList $depth
         subdivide $hiList $depth
     }
 }
 
 proc mediancut::apply {src dest} {
     
     variable new
     
     set w [image width $src]
     set h [image height $src]
     $dest configure -width $w -height $h
     
     for {set y 0} {$y < $h} {incr y} {
         
         set row [list]
         
         for {set x 0} {$x < $w} {incr x} {
             
             lappend row $new([$src get $x $y])
         }
         $dest put -to 0 $y [list $row]
         update idletasks
     }
 }