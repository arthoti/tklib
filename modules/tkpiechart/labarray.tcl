set rcsId {$Id: labarray.tcl,v 1.17 1998/05/03 10:53:38 jfontain Exp $}

class canvasLabelsArray {

    proc canvasLabelsArray {this canvas x y args} switched {$args} {
        set canvasLabelsArray::($this,canvas) $canvas
        # use an empty image as an origin marker with only 2 coordinates
        set canvasLabelsArray::($this,origin) [$canvas create image $x $y -tags canvasLabelsArray($this)]
        set canvasLabelsArray::($this,labels) {}
        switched::complete $this
    }

    proc ~canvasLabelsArray {this} {
        eval ::delete $canvasLabelsArray::($this,labels)
        $canvasLabelsArray::($this,canvas) delete canvasLabelsArray($this)                                 ;# delete remaining items
    }

    proc options {this} {
        # force width initialization for internals initialization
        return [list\
            [list -justify left left]\
            [list -xoffset 0 0]\
            [list -width 100]\
        ]
    }

    foreach option {-justify -xoffset} {
        proc set$option {this value} "
            if {\$switched::(\$this,complete)} {
                error {option $option cannot be set dynamically}
            }
        "
    }

    proc set-width {this value} {
        set canvasLabelsArray::($this,width) [winfo fpixels $canvasLabelsArray::($this,canvas) $value]
        update $this
    }

    proc update {this} {
        set index 0
        foreach label $canvasLabelsArray::($this,labels) {
            position $this $label $index
            incr index
        }
    }

    proc manage {this label} {                                                                              ;# must be a canvasLabel
        $canvasLabelsArray::($this,canvas) addtag canvasLabelsArray($this) withtag canvasLabel($label)
        set index [llength $canvasLabelsArray::($this,labels)]
        lappend canvasLabelsArray::($this,labels) $label
        position $this $label $index
    }

    proc delete {this label} {
        set index [lsearch -exact $canvasLabelsArray::($this,labels) $label]
        if {$index<0} {
            error "invalid label $label for canvas labels array $this"
        }
        set canvasLabelsArray::($this,labels) [lreplace $canvasLabelsArray::($this,labels) $index $index]
        ::delete $label
        foreach label [lrange $canvasLabelsArray::($this,labels) $index end] {
            position $this $label $index
            incr index
        }
    }

    proc position {this label index} {
        set canvas $canvasLabelsArray::($this,canvas)

        foreach {x y} [$canvas coords $canvasLabelsArray::($this,origin)] {}
        set x [expr {$x+(($index%2?1:-1)*$switched::($this,-xoffset))}]     ;# offset horizontally, left column gets negative offset
        set coordinates [$canvas bbox canvasLabel($label)]
        set y [expr {$y+(($index/2)*([lindex $coordinates 3]-[lindex $coordinates 1]))}]           ;# take label height into account

        switch $switched::($this,-justify) {                                                        ;# arrange labels in two columns
            left {
                set x [expr {$x+(($index%2)*($canvasLabelsArray::($this,width)/2.0))}]
                set anchor nw
            }
            right {
                set x [expr {$x+((($index%2)+1)*($canvasLabelsArray::($this,width)/2.0))}]
                set anchor ne
            }
            default {                                                                                            ;# should be center
                set x [expr {$x+((1.0+(2*($index%2)))*$canvasLabelsArray::($this,width)/4)}]
                set anchor n
            }
        }
        switched::configure $label -anchor $anchor
        set coordinates [$canvas coords canvasLabel($label)]                           ;# do an absolute positioning using label tag
        $canvas move canvasLabel($label) [expr {$x-[lindex $coordinates 0]}] [expr {$y-[lindex $coordinates 1]}]
    }

    proc labels {this} {
        return $canvasLabelsArray::($this,labels)
    }

}
