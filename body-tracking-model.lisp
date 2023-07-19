(clear-all)

(define-model lost-agent

(sgp :egs 0.2)  ; Dieses Modell verwendet Utility. Der utility noise kann ausgeschaltet werden, indem dieser Parameter auf 0 gesetzt wird.
(sgp :esc t)    ; Dieses Modell verwendet subsymbolische Verarbeitung

(sgp :v t :show-focus t :trace-detail high)

(chunk-type goal state intention)
(chunk-type control intention button)
(chunk-type tile-type color type)
(chunk-type tile color type screen-x screen-y)

(set-visloc-default screen-y lowest kind oval)


(add-dm
    (move-left) (move-right)
    (move-up)  (move-down)
    (w) (a) (s) (d)
    (i-dont-know-who-i-am)
    (tile) (color-meaning)
    (i-dont-know-where-to-go)
    (something-should-change)
    (i-want-to-do-something)
    (up-control isa control intention move-up button w)
    (down-control isa control intention move-down button s)
    (left-control isa control intention move-left button a)
    (right-control isa control intention move-right button d)
    (first-goal isa goal state i-dont-know-who-i-am)

)

(goal-focus first-goal)



;Identify Actuator Tile
(p try-to-locate-myself

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
        state check-for-others

    +visual>
        cmd move-attention
        screen-pos =visual-location

    +imaginal>
        isa tile
        color =color
        screen-x =x
        screen-y =y
)


(p check-for-others-tiles
    =goal>
        state check-for-others
   ; -   intention attend
    ;-   intention retrieve
    =visual>
    =visual-location>
        screen-y =y
    ?visual-location>
       - buffer failure
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

)

;(p attend-other-tiles
;    =goal>
;        state check-for-others
;        intention attend
;    =visual-location>
;    ==>
;    +visual>
;        cmd move-attention
;        screen-pos =visual-location
;    +retrieval>
;        oval t
;    =goal>
;        state retrieve
;    )

(p retrieval-check
    =goal>
        state retrieve
    =retrieval>
        oval t
    ==>
    =goal>
        state check-for-others
        intention retrieve
    )


;(P no-other-bodies
;    =goal>
;        state check-for-others
;    ?visual-location>
;        buffer failure
;    =imaginal>
;        color =color
;==>
;    =goal>
;        state i-found-myself
;        color =color
;
;    +imaginal>
;        isa tile
;        color =color
;        type body
;)

(P no-more-bodies
    =goal>
        state check-for-others
    ?visual-location>
        buffer failure
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
    ?retrieval>
    ;    buffer empty 
    -   state busy
    ;=visual-location>
    ;    color =color
==>
    +retrieval>
        kind oval
        :recently-retrieved nil
    ;+imaginal>
    ;    color
    =goal>
        intention check
)


(p did-i-move
    =goal>
        state did-i-move
        intention check
    ;=visual-location>
    ;    color =color1
    =retrieval>
    ;-   color =color1
        color =color2
        screen-x =x
        screen-y =y
        kind oval
    
==>
    +visual-location>
        color =color2
        screen-x =x
        screen-y =y
        kind oval
        ;attended :nil
    ;+visual>
    ;    cmd move-attention
    ;    screen-pos =visual-location
    =retrieval>
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
    ==>
    =goal>
        state i-am-this
        intention locate
        color =color    
    +imaginal>
        isa tile-type
        color =color
        type body
    -visual-location>
    +visual-location>
        color =color
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
    ==>
    +visual>
        cmd start-tracking
    +manual>
        cmd press-key
        key s
    =goal>
        state find-goal
)

(p find-direction
    =goal>
        state find-goal
    ==>
    +visual-location>
        kind oval
        color green
)

(p found-goal
    =goal>
        state find-goal
    =visual-location>
        kind oval
        color green
    ==>
    !output! "I found the goal")

;(p track-to-move
;    =goal>
;        state i-track-myself
;    ==>
;    =goal>
;        state i-want-to-move        
;)

;How to connect to random moves?
;(p move-randomly)


)