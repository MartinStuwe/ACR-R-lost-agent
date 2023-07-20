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
    (first-goal isa goal state i-dont-know-the-goal)

    (goal-tile isa tile-type color green type goal)
    (reward-tile isa tile-type color type type reward)
    (trap-tile isa tile-type color unknown type trap)
    (block-tile isa tile-type color unknown type block)

    

)

(goal-focus first-goal)

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



;Identify Actuator Tile
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
        color =color
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
    +retrieval>
        :recently-retrieved nil
        kind oval
)

(p did-i-move-request
    =goal>
        state did-i-move
        intention request
    ?visual-location>
    -  buffer failure
    ?retrieval>
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

(p initial-scan-request
    =goal>
        state  i-am-this
        intention scan
        color =body
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
        color =body
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
        color =body
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
    +retrieval>
        isa tile-type
        type goal
)

(p search-goal
    =goal>
        state find-goal
        intention search
    =retrieval>
        isa tile-type
        type goal
        color =col
    ?visual>
        buffer full
    ==>
    +visual-location>
        kind oval
        color =col
    =retrieval>
    =goal>
        intention check
;        goalcolor =col
)


(p not-found-goal
    =goal>
        state find-goal
        intention check
        color =body
    =retrieval>
        isa tile-type
        type goal
        color =col
    ?visual-location>
        ;buffer failure
        state error
    ?visual>
        ;state busy
        buffer full
==>
    =goal>
        state search-goal
        intention move
    ;-visual-location>
    ;+visual>
    ;    cmd clear
)

;(p what-are-those-tiles
;    =goal>
;        state search-goal
;        intention interact
;        color =col
;        goalcolor =goalcol
;==>
;    +retrieval>
;        kind oval
;    -   color =col
;    -   color =goalcol
;)

;(p i-want-to-move-to-this-tile
;    =goal>
;        state search-goal
;        intention interact
;        color =col
;        goalcolor =goalcol
;    =retrieval>
;        kind oval
;        color =col
;        screen-x =x
;        screen-y =y
;==>
;    +retrieval>
;        kind oval
;    -   color =col
;    -   color =goalcol
;)



(p moveleft
    =goal>
        state search-goal
        intention move
    ?manual>
        state free
    ?retrieval>
        state free
    ==>
    +manual>
        cmd press-key
        key a
    +retrieval>
        type goal
    =goal>
        state find-goal
        intention search
)


(p movedown
    =goal>
        state search-goal
        intention move
    ?manual>
        state free
    ?retrieval>
        state free
    ==>
    +manual>
        cmd press-key
        key s
    +retrieval>
            type goal
    =goal>
        state find-goal
        intention search
)

(p moveright
    =goal>
        state search-goal
        intention move
    ?manual>
        state free
    ?retrieval>
        state free
    ==>
    +manual>
        cmd press-key
        key d
    +retrieval>
        type goal
    =goal>
        state find-goal
        intention search
)

;(p scanright
;    =goal>
;        state find-goal
;        intention scanright
;==>
;    +retrieval>
;        kind oval
;    >   bodyx)

(p moveup
    =goal>
        state search-goal
        intention move
    ?manual>
        state free
    ?retrieval>
        state free
    ==>
    +manual>
        cmd press-key
        key w
    +retrieval>
        type goal
    =goal>
        state find-goal
        intention search
)


(p found-goal
    =goal>
        state find-goal
        intention check
    =retrieval>
        isa tile-type
        type goal
        color =col
    =visual-location>
        kind oval
        color =col
    ==>
    =goal>
        state move-to-goal
        intention find-direction
    =visual-location>
)


(p goal-check1
    =goal>
        state move-to-goal
        intention find-direction
    =visual>
        oval t
        screen-pos =visloc-chunk
    =visual-location>
        kind oval
        color green
        screen-x =x
        screen-y =y 
    ?retrieval>
        state free
    ==>
    +retrieval>
        kind oval
        color green
    =goal>
        state move-to-goal
        intention move
)


(p goal-check-down
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x1
        screen-y =y1
    =retrieval>
            screen-x =x2
        >   screen-y =y1
                color =goalcolor
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key s
    =goal>
        intention find-direction
    +visual-location>
        kind oval
        color =goalcolor
)


(p goal-check-up
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x1
        screen-y =y1
    =retrieval>
            screen-x =x2
        <   screen-y =y1
            color =goalcolor
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key w
    =goal>
        intention find-direction
    +visual-location>
        kind oval
        color =goalcolor
)


(p goal-check-left
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x1
        screen-y =y1
    =retrieval>
    <    screen-x =x1
        screen-y =y2
        color    =goalcolor
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key a
    =goal>
        intention find-direction
    +visual-location>
        kind oval
        color =goalcolor
)


(p goal-check-right
    =goal>
        state move-to-goal
        intention move
    =visual-location>
        screen-x =x1
        screen-y =y1
    =retrieval>
    >   screen-x =x1
        screen-y =y2
        color    =goalcolor
    ?manual>
            state free
==>
    +manual>
        cmd press-key
        key d
    =goal>
        intention find-direction
    +visual-location>
        kind oval
        color =goalcolor
)





)