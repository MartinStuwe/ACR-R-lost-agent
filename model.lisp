(clear-all)

(define-model lost-agent

(sgp :egs 0.2)  ; Dieses Modell verwendet Utility. Der utility noise kann ausgeschaltet werden, indem dieser Parameter auf 0 gesetzt wird.
(sgp :esc t)    ; Dieses Modell verwendet subsymbolische Verarbeitung

(sgp :v t :show-focus t :trace-detail high)

(chunk-type goal state intention)
(chunk-type control intention button)
(chunk-type tile-type color type)
(chunk-type tile color type screen-x screen-y)

(chunk-type sight viewrange)

(set-visloc-default screen-y lowest kind oval)
(set-parameter-value :visual-num-finsts 25)


(add-dm
    (move-left) (move-right)
    (move-up)  (move-down)
    (w) (a) (s) (d)
    (i-dont-know-who-i-am)
    (tile-distance) (color-meaning)
    (i-dont-know-where-to-go)
    (something-should-change)
    (i-want-to-do-something)
    (up-control isa control intention move-up button w)
    (down-control isa control intention move-down button s)
    (left-control isa control intention move-left button a)
    (right-control isa control intention move-right button d)

    (goal-tile isa tile-type color green type goal)
    (reward-tile isa tile-type color type type reward)
    (trap-tile isa tile-type color unknown type trap)
    (block-tile isa tile-type color unknown type block)

    (fog-of-war isa )

    (first-goal isa goal state i-dont-know-the-board intention left-border)

)

(goal-focus first-goal)

(p identify-left-border
    =goal>
        state i-dont-know-the-board
        intention left-border
    =visual-location>
    -   kind line
==>
    +visual-location>
        kind line
        screen-x lowest  
)

(p save-left-border
    =goal>
        state i-dont-know-the-board
        intention left-border
    =visual-location>
        kind line
        screen-x =x
==>
    =goal>
        state i-dont-know-the-board
        intention right-border
        border-left-x =x
)

(p identify-right-border
    =goal>
        state i-dont-know-the-board
        intention right-border
    =visual-location>
    -   kind line
==>
    +visual-location>
        kind line
        screen-x highest)

(p save-right-border
    =goal>
        state i-dont-know-the-board
        intention right-border
    =visual-location>
        kind line
        screen-x =x
==>
    =goal>
        state i-dont-know-the-board
        border-right-x =x
        intention upper-border
)

(p identify-upper-border
    =goal>
        state i-dont-know-the-board
        intention upper-border
    =visual-location>
    -   kind line
==>
    +visual-location>
        kind line
        screen-y lowest)

(p save-upper-border
    =goal>
        state i-dont-know-the-board
        intention upper-border
    =visual-location>
        kind line
        screen-y =y
==>
    =goal>
        state i-dont-know-the-board
        border-upper-y =y
        intention lower-border
)

(p identify-lower-border
    =goal>
        state i-dont-know-the-board
        intention lower-border
    =visual-location>
    -   kind line
==>
    +visual-location>
        kind line
        screen-y highest
)

(p save-lower-border
    =goal>
        state i-dont-know-the-board
        intention lower-border
    =visual-location>
        kind line
        screen-y =y
==>
    =goal>
        state i-dont-know-the-goal
        border-lower-y =y
)
        
(p retrieve-goal-color
    =goal>
        state i-dont-know-the-goal
    ?retrieval>
        buffer empty
        state free
==>
    +retrieval>
        type goal
)

(p i-retrieved-the-goal-color
    =goal>
        state i-dont-know-the-goal
    =retrieval>
        type goal
        color =goalcolor
==>
    =goal>
        state i-dont-know-who-i-am
        goalcolor =goalcolor
)

(p locate-first
    =goal>
    state i-dont-know-who-i-am
    =visual-location>
        isa visual-location
        kind oval
        screen-x =x
        screen-y =y
        color =color
    ?visual>
        state free
    ?imaginal>
        state free
==>
    =goal>
        state watch-for-others
    +visual>
        cmd move-attention
        screen-pos =visual-location
    +imaginal>
        isa tile
        color =color
        screen-x =x
        screen-y =y
)

(p request-second
    =goal>
        state watch-for-others
    =visual-location>
        screen-y =y
    =imaginal>
==>
    +visual-location>
        :attended nil  
        kind oval
        screen-y =y
    =imaginal>
    =goal>
        state check-for-others
)

(p check-for-others-tiles
    =goal>
        state check-for-others
    =visual>
        - state busy
    =visual-location>
        screen-y =y
    ?visual-location>
       - state error
    ?visual>
        state free
==>
    =goal>
        state check-for-others
        intention attend
    +visual>
        cmd move-attention
        screen-pos =visual-location
    +visual-location>
        :attended nil  
        screen-y =y
        kind oval
    -imaginal>
)

(P no-other-bodies
    =goal>
        state check-for-others
    ?visual-location>
        ;buffer failure
        state error
    =imaginal>
        color =color
    ?imaginal>
        state free
==>
    =goal>
        state i-am-this
        bodycolor =color
        intention scan
    +imaginal>
        isa tile
        color =color
        type body
)

(P no-more-bodies
    =goal>
        state check-for-others
    ?visual-location>
        ;buffer failure
        state error
    ?imaginal>
        buffer empty
==>
    =goal>
        state who-am-i
)

(p do-i-move
    =goal>
        state who-am-i
    -   intention do-i-move
    ?manual>
        state free
    =visual>
    ?retrieval>
        state free
==>
    =visual>
        cmd start-tracking
    +manual>
        cmd press-key
        key s
    =goal>
        state did-i-move
        intention request
)

(p did-i-move-request
    =goal>
        state did-i-move
        intention request
    ?visual-location>
    -  buffer failure
    =visual-location>
    ?retrieval>
        state free
    ?manual>
        state free
    
==>
    +retrieval>
        kind oval
        :recently-retrieved nil
    =goal>
        intention check
)

(p did-i-move
    =goal>
        state did-i-move
        intention check

    =retrieval>
        color =color2
        screen-x =x
        screen-y =y
        kind oval
    
    ?retrieval>
        state free
    
==>
    =retrieval>
    +visual-location>
        color =color2
        screen-x =x
        screen-y =y
        kind oval
    =goal>
        intention request
)

(p i-moved-this
    =goal>
        state did-i-move
        intention request
    =retrieval>
        color =color
        screen-x =x
        screen-y =y
        kind oval
    ?visual-location>
        buffer failure
        state error
==>
    =goal>
        state i-am-this
        intention scan
        bodycolor =color    
    +imaginal>
        isa tile-type
        color =color
        type body
    -visual-location>
    +visual-location>
        color =color
        kind oval
)

(p initial-scan-request
    =goal>
        state  i-am-this
        intention scan
        bodycolor =body
    ?visual>
        state free
==>
    +visual-location>
        :attended nil
        ;:attended new
        - color =body
        kind oval
    =goal>
        intention attend
)

(p initial-scan-attend
    =goal>
        state  i-am-this
        intention attend
        bodycolor =body
    =visual-location>
    -   color =body
        kind oval
    ?visual>
        state free
==>
    +visual>
        cmd move-attention
        screen-pos =visual-location
    =goal>
        intention scan
)

(p initial-scan-stop
    =goal>
        state i-am-this
        intention attend
        bodycolor =body
    ?visual-location>
        state error
    ;    buffer failure
==>
    =goal>
        state i-am-this
        intention locate
    +visual-location>
        color =body
        kind oval
)

(p track-body-request
    =goal>
        state i-am-this
        intention locate
    =imaginal>
        type body
        color =color
    =visual-location>
        color =body
    ==>
    +visual>
        cmd move-attention
        screen-pos =visual-location
    =goal>
        intention track
    )

(p track-body-track
    =goal>
        state i-am-this
        intention track
    =visual>
    ?manual>
        state free
    ?visual>
        state free
    ?retrieval>
        state free
    ==>
    +visual>
        cmd start-tracking
    +manual>
        cmd press-key
        key s
    =goal>
        state find-goal
        intention search
)

(p search-goal
    =goal>
        state find-goal
        intention search
        goalcolor =col
    ?visual>
        buffer full
    ?manual>
        state free
    ==>
    +visual-location>
        kind oval
        color =col
    =goal>
        intention check
)

(p not-found-goal
    =goal>
        state find-goal
        intention check
        bodycolor =body
    ?visual-location>
        ;buffer failure
        state error
    ?visual>
        ;state busy
        buffer full
==>
    =goal>
        state search-goal
        ;intention move
        intention find-tiles
    -imaginal>
)

(p what-are-those-tiles
    =goal>
        state search-goal
        intention find-tiles
        bodycolor =bodycol
        goalcolor =goalcol
    
==>
    +visual-location>
        kind oval
    -   color =bodycol
    -   color =goalcol
    =goal>
        intention interact
)


(p move-visual-location-into-bounded-imaginal
    =goal>
        state search-goal
        intention interact
        bodycolor =bodycol
        goalcolor =goalcol
    =visual-location>
        kind oval
    -   color =bodycol
    -   color =goalcol
        color =tilecolor
        screen-x =x 
        screen-y =y
==>
    +imaginal>
        leftbound =x
        rightbound =x 
        upbound =y 
        downbound =y
    =goal>
        state move-to-goal
        intention find-direction
)

(p i-want-to-move-to-this-position-range
    =goal>
        state search-goal
        intention interact
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    
==>
    +visual-location>
        kind oval
        color =bodycolor
)

;(p block-tile-check
;    =goal>
;        state
;        intention
;    I DIDN'T MOVE
;    =visual-location>
;    same as before    
;)

;(p reward-tile-check
;    +visual-location>
;        kind text
;        color red
;    color red kind text value '+'
;)

;(p penalty-tile-check
;    color red kind text value '-'
;)


(p leftcheck
    =goal>
        state search-goal
        intention move
        border-left-x =leftborderx
    =visual-location>
        screen-x =x
    >   screen-x =leftborderx

        screen-y =y

    !eval! (> =x (+ =leftborderx 12))

    ?imaginal>
        buffer empty
        state free
==>
    
    !bind! =leftmove (- =x 25)

    +imaginal>
        leftbound =leftmove
        rightbound =leftmove
        upbound =y 
        downbound =y
)


(p i-want-to-move-to-this-position-range-checkleft
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    =visual-location>
        kind oval
        color =bodycolor
    >   screen-x =leftbound

==>
    +manual>
        cmd press-key
        key a
    =goal>
        state find-goal
        intention search
)

(p rightcheck
    =goal>
        state search-goal
        intention move
        border-right-x =rightborderx
    =visual-location>
        screen-x =x
    <   screen-x =rightborderx
        screen-y =y
    
    !eval! (< =x (- =rightborderx 13))

    ?imaginal>
        buffer empty
        state free
==>

    !bind! =rightmove (+ =x 25)

    +imaginal>
        leftbound =rightmove
        rightbound =rightmove
        upbound =y 
        downbound =y
    =visual-location>
)

(p i-want-to-move-to-this-position-range-checkright
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    =visual-location>
        kind oval
        color =bodycolor
    <   screen-x =rightbound
    
==>
    +manual>
        cmd press-key
        key d
    =goal>
        state find-goal
        intention search
)


(p downcheck
    =goal>
        state search-goal
        intention move
        border-lower-y =downbordery
    =visual-location>
        screen-x =x

    <   screen-y =downbordery
        screen-y =y

    !eval! (< =y (- =downbordery 12))

    ?imaginal>
        buffer empty
        state free

==>

    !bind! =downmove (- =y 25)
    +imaginal>
        leftbound =x
        rightbound =x
    
        upbound =downmove
        downbound =downmove
)


(p i-want-to-move-to-this-position-range-checkdown
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    =visual-location>
        kind oval
        color =bodycolor
    >   screen-y =downbound
    
==>
    +manual>
        cmd press-key
        key s
    =goal>
        state find-goal
        intention search

)


(p upcheck
    =goal>
        state search-goal
        intention move
        border-upper-y =upbordery
    =visual-location>
        screen-x =x

    >   screen-y =upbordery
        screen-y =y

    !eval! (> =y (+ =upbordery 12))


    ?imaginal>
        buffer empty
        state free
==>
    =visual-location>

    !bind! =upmove (+ =y 25)
    +imaginal>
        leftbound =x
        rightbound =x
        upbound =upmove
        downbound =upmove
)

(p i-want-to-move-to-this-position-range-checkup
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    =visual-location>
        kind oval
        color =bodycolor
    <   screen-y =upbound
    
==>
    +manual>
        cmd press-key
        key w
    =goal>
        state find-goal
        intention search
)




(p found-goal
    =goal>
        state find-goal
        intention check
        goalcolor =goalcol
        bodycolor =bodycol
    =visual-location>
        kind oval
        color =goalcol
        screen-x =x
        screen-y =y
    ==>
    =goal>
        state move-to-goal
        intention find-direction
    +visual-location>
        color =bodycol
        kind oval
    +imaginal>
        leftbound =x
        rightbound =x
        upbound =y
        downbound =y

)


(p target-check
    =goal>
        state move-to-goal
        intention find-direction
    =imaginal>
        leftbound =x
        rightbound =x
        upbound =y
        downbound =y
    ?retrieval>
        state free
    ==>
    =goal>
        state move-to-goal
        intention move
    =imaginal>
)




(p target-tile-check-down
    =goal>
        state move-to-goal
        intention move

    =visual-location>
        screen-x =x
        screen-y =y
    =imaginal>
    >    upbound =y
    >    downbound =y

    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key s
    =goal>
        intention find-direction
    =imaginal>
)

(p target-tile-check-up
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x
        screen-y =y
    
    =imaginal>
    <    upbound =y
    <    downbound =y
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key w
    =goal>
        intention find-direction
    =imaginal>
)


(p target-tile-check-left
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x
        screen-y =y

    =imaginal>
    <   leftbound =x
    <   rightbound =x
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key a
    =goal>
        intention find-direction
    =imaginal>
)


(p target-tile-check-right
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x
        screen-y =y

    =imaginal>
    >   leftbound =x
    >  rightbound =x

    
    ?manual>
            state free
==>
    +manual>
        cmd press-key
        key d
    =goal>
        intention find-direction
    =imaginal>
)


(p target-tile-check-left
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x
        screen-y =y

    =imaginal>
    <   leftbound =x
    <   rightbound =x
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key a
    =goal>
        intention find-direction
    =imaginal>
)


(p target-tile-check-reached
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x
        screen-y =y

    =imaginal>
    =   leftbound =x
    =  rightbound =x
    =    upbound =y
    =    downbound =y
    
    ?manual>
            state free
==>
    =goal>
        intention halt
    =imaginal>
)



)