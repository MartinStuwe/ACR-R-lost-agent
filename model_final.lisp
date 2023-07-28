(clear-all)

(define-model lost-agent

(sgp :egs 0.2)  ; Dieses Modell verwendet Utility. Der utility noise kann ausgeschaltet werden, indem dieser Parameter auf 0 gesetzt wird.
(sgp :esc t)    ; Dieses Modell verwendet subsymbolische Verarbeitung


;trace-detail low/medium 
(sgp :v t :show-focus t :trace-detail low)

(chunk-type goal state intention BORDER-LEFT-X BORDER-right-X BORDER-UPPER-Y BORDER-Lower-Y 
goalcolor bodycolor rewardcolor penaltycolor blockcolor score xsight ysight)
(chunk-type control intention button)
(chunk-type tile-type color type)
(chunk-type tile color type screen-x screen-y)

(chunk-type movetotarget leftbound rightbound upbound downbound currentx currenty nextx nexty tilecolor) 

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

    (first-goal isa goal state i-dont-know-the-board intention left-border
                         goalcolor unknown bodycolor unknown rewardcolor unknown penaltycolor unknown blockcolor unknown
                         border-left-x unknown border-right-x unknown border-lower-y unknown border-upper-y unknown
                         score "0" xsight 25 ysight 25)

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
        screen-y lowest
)

;englisch seminar  4 ects , fachuebergreifen pflicht

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
        processor free

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
    ?visual>
        state free
        processor free
    =imaginal>
==>
    +visual-location>
        :attended nil  
        kind oval
        screen-y =y
    =goal>
        state check-for-others
    =imaginal>
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
        processor free
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
        intention request
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
    +visual>
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
    ?visual>
        state busy

==>
    =goal>
        state i-am-this
        intention request
        bodycolor =color    

    +visual-location>
        color =color
        kind oval
    +visual>
        cmd clear
)

(p request-body-location
    =goal>
        state i-am-this
        intention request
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
        bodycolor =bodycol

    =visual-location>
        color =bodycol
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
        processor free
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
        goalcolor =goalcol
    ?visual>
        buffer full
        processor free
    ?manual>
        state free
    ==>
    +visual-location>
        kind oval
        color =goalcol
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
        processor free
==>
    =goal>
        state search-goal
        ;intention move
        intention find-tiles
    ;-imaginal>
)

(p what-are-those-tiles
    =goal>
        state search-goal
        intention find-tiles
        bodycolor =bodycol
        goalcolor =goalcol
        rewardcolor =rewardcol
        penaltycolor =penaltycol
        blockcolor =blockcol
    
    
==>
    +visual-location>
        kind oval
    -   color =bodycol
    -   color =goalcol
    -   color =rewardcol
    -   color =penaltycol
    -   color =blockcol
    =goal>
        state search-goal
        intention interact
)

(p nothing-new
    =goal>
        state search-goal
        intention interact
        goalcolor =goalcol
    ?visual-location>
        state error
        ;buffer failure
==>
    =goal>
        state search-goal
        intention move
    +visual-location>
        kind oval
        color =goalcol
)

(p is-there-a-reward
    =goal>
        state search-goal
        intention find-tiles
        bodycolor =bodycol
        goalcolor =goalcol
        rewardcolor =rewardcol
    -   rewardcolor unknown
    
==>
    +visual-location>
        kind oval
        color =rewardcol
    -   color unknown
    =goal>
        intention interact
)

(p move-visual-location-into-bounded-imaginal-tile
    =goal>
        state search-goal
        intention interact
        bodycolor =bodycol
        goalcolor =goalcol
    =visual-location>
        kind oval
    -   color =bodycol
    -   color =goalcol
        color =tilecol
        screen-x =x 
        screen-y =y
    ?retrieval>
        state free
    ?imaginal>
        state free
==>
    +imaginal>
        isa movetotarget
        leftbound =x
        rightbound =x 
        upbound =y 
        downbound =y
        tilecolor =tilecol
        nextx unknown
        nexty unknown


    =goal>
        state move-to-goal
        intention imagine
    +visual-location>
        color =bodycol
)

(p move-visual-location-into-bounded-imaginal-current
    =goal>
        state move-to-goal
        intention imagine
        bodycolor =bodycol
    =visual-location>
        screen-x =x
        color =bodycol
        screen-y =y
    =imaginal>
==>
    =imaginal>
        currentx =x
        currenty =y
    =goal>
        state move-to-goal
        intention find-direction
)

(p leftcheck
    =goal>
        state search-goal
        intention move
        border-left-x =leftborderx
        blockcolor =blockcol
    =visual-location>
        screen-x =x
    >   screen-x =leftborderx
        screen-y =y

    !eval! (> =x (+ =leftborderx 12))

    =imaginal>
==>
    
    !bind! =leftmove (- =x 25)

    =imaginal>
        leftbound =leftmove
        rightbound =leftmove
        upbound =y 
        downbound =y
        nextx unknown
        nexty unknown

    =visual-location>
)

(p i-want-to-move-to-this-position-range-checkleft-block-penalty
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
        penaltycolor =penaltycol
        blockcolor =blockcol
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
    +visual-location>
        screen-x =leftbound
        screen-y =downbound
        color =penaltycol
        color =blockcol
        kind oval
    =goal>
        state search-goal
        intention presskey
    =imaginal>
    +retrieval>
        button a
)


(p i-want-to-move-to-this-position-range-presskey
    =goal>
        state search-goal
        intention presskey
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    ?visual-location>
        state error
       ; buffer failure
    =retrieval>
        button =keytopress
    ?manual>
        state free

==>
    +manual>
        cmd press-key
        key =keytopress
    =goal>
        state find-goal
        intention search
    =imaginal>
)


(p i-want-to-move-to-this-position-range-checkleft-not-good
    =goal>
        state search-goal
        intention presskey
        bodycolor =bodycol
        goalcolor =goalcol
    =imaginal>
        leftbound =leftbound
        rightbound =rightbound 
        upbound =upbound 
        downbound =downbound
    ?visual-location>
    -    state error
    -    buffer failure

==>
    =goal>
        state find-goal
        intention search
    =imaginal>
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

    =imaginal>

==>

    !bind! =rightmove (+ =x 25)

    =imaginal>
        leftbound =rightmove
        rightbound =rightmove
        upbound =y 
        downbound =y

    =visual-location>
)

(p i-want-to-move-to-this-position-range-checkright-block-penalty
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
        blockcolor =blockcol
        penaltycolor =penaltycol
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
    +visual-location>
        screen-x =leftbound
        screen-y =downbound
        color =penaltycol
        color =blockcol
        kind oval
    =goal>
        state search-goal
        intention presskey
    =imaginal>
    +retrieval>
        button d
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

    =imaginal>

==>
    !bind! =downmove (- =y 25)

    =imaginal>
        leftbound =x
        rightbound =x
        upbound =downmove
        downbound =downmove
        nextx unknown
        nexty unknown

    =visual-location>
)


(p i-want-to-move-to-this-position-range-checkdown-block-penalty
    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
        blockcolor =blockcol
        penaltycolor =penaltycol

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
    +visual-location>
        screen-x =leftbound
        screen-y =downbound
        color =penaltycol
        color =blockcol
        kind oval
    =goal>
        state search-goal
        intention presskey
    =imaginal>
    +retrieval>
        button s
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


    =imaginal>

==>
    =visual-location>

    !bind! =upmove (+ =y 25)

    =imaginal>
        leftbound =x
        rightbound =x
        upbound =upmove
        downbound =upmove
        nexty =upmove
        nextx unknown
)

(p i-want-to-move-to-this-position-range-checkup

    =goal>
        state search-goal
        intention move
        bodycolor =bodycol
        goalcolor =goalcol
        blockcolor =blockcol
        penaltycolor =penaltycol

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
    +visual-location>
        screen-x =leftbound
        screen-y =downbound
        color =penaltycol
        color =blockcol
        kind oval
    =goal>
        state search-goal
        intention presskey
    =imaginal>
    +retrieval>
        button w
)


(p found-goal-check-for-reward
    =goal>
        state find-goal
        intention check
        goalcolor =goalcol
        bodycolor =bodycol
        rewardcolor =rewardcol
    ;-   rewardcolor unknown

    =visual-location>
        kind oval
        color =goalcol
        screen-x =x
        screen-y =y
    ?visual>
        processor free

==>
    =goal>
        state find-goal
        intention checkreward
        screen-x =x
        screen-y =y

    +visual-location>
        color =rewardcol
        kind oval
)


(p found-goal-found-reward
    =goal>
        state find-goal
        intention checkreward
        goalcolor =goalcol
        bodycolor =bodycol
        rewardcolor =rewardcol
    -   rewardcolor unknown

    =visual-location>
        kind oval
        color =rewardcol
        screen-x =x
        screen-y =y
    =imaginal>
==>
    =goal>
        state move-to-goal
        intention find-direction

    ;+visual-location>
    ;    color =rewardcol
    ;    kind oval
    =imaginal>
        leftbound =x
        rightbound =x
        upbound =y
        downbound =y
        tilecolor =rewardcol

        
)


(p found-goal-no-reward
    =goal>
        state find-goal
        intention checkreward
        goalcolor =goalcol
        bodycolor =bodycol
        screen-x =x
        screen-y =y

    ?visual-location>
        state error
        buffer failure
    =imaginal>

==>
    =goal>
        state move-to-goal
        intention find-direction

    +visual-location>
        color =bodycol
        kind oval

    =imaginal>
        isa movetotarget
        leftbound =x
        rightbound =x
        upbound =y
        downbound =y
)

(p target-check
    =goal>
        state move-to-goal
        intention find-direction
        bodycolor =bodycol
    =imaginal>
        leftbound =targetlx
        rightbound =targetrx
        upbound =targetuy
        downbound =tagetdy
    ?retrieval>
        state free
        buffer empty
    ?visual-location>
    -   buffer failure
    ;-   state error
    ?visual>
        processor free
        buffer unrequested

    ?manual>
        state free  
    =visual-location>
        color =bodycol
        screen-x =x
        screen-y =y

    ==>
    =goal>
        state move-to-goal
        intention move
    =imaginal>
    ;    currentx =x
    ;    currenty =y
    ;    nextx =x
    ;    nexty =y
)


(p target-down
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol

    =visual-location>
        screen-x =x
        screen-y =y
        color =bodycol

    =imaginal>
    >    upbound =y
    >    downbound =y
        leftbound =targetx
        upbound =targety
        currentx =currentx
        currenty =currenty

    !eval! (not (and (= =targety (+ =y 25)) (= =targetx =x)))

    ?manual>
        state free
==>
    !bind! =downmove (+ =y 25)    
    =imaginal>
        currentx =x
        currenty =y
        nextx =x
        nexty =downmove


    +retrieval>
        button s

    =goal>
        intention check-for-tile

    +visual-location>
        screen-x =x
        screen-y =downmove
        kind oval
)

(p target-down-next-to
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol

    =visual-location>
        color =bodycol
        screen-x =x
        screen-y =y
    =imaginal>
        upbound =targety
        leftbound =targetx
        leftbound =x
    !eval! (= =targety (+ =y 25))

    ?manual>
        state free
==>
    !bind! =downmove (+ =y 25)    
    =imaginal>
        nextx =x
        nexty =downmove
        currentx =x
        currenty =y
        

    +retrieval>
        button s
        
    =goal>
        intention check-for-tile

    +visual-location>
        screen-x =x
        screen-y =downmove
        kind oval


)
(p target-up
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol
    =visual-location>
        screen-x =x
        screen-y =y
        color =bodycol
    
    =imaginal>
    <    upbound =y
    <    downbound =y
    downbound =targety
    leftbound =targetx

    !eval! (not (and (= =targety (- =y 25)) (= =targetx =x)))

    ?manual>
        state free
==>
    !bind! =upmove (- =y 25)

    =imaginal>
        nextx =x
        nexty =upmove
        currentx =x
        currenty =y


    +retrieval>
        button w
    =goal>
        intention check-for-tile

    +visual-location>
        screen-x =x
        screen-y =upmove
        kind oval
)

(p target-up-next-to
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol

    =visual-location>
        screen-x =x
        screen-y =y
        color =bodycol
    =imaginal>
        upbound =targety
        leftbound =targetx
        leftbound =x
    
    !eval! (= =targety (- =y 25))

    ?manual>
        state free
==>
    !bind! =upmove (- =y 25)

    =imaginal>
        nextx =x
        nexty =upmove
        currentx =x
        currenty =y

    +retrieval>
        button w
    =goal>
        intention check-for-tile
    
    +visual-location>
        screen-x =x
        screen-y =upmove
        kind oval

)

(p target-left
    =goal>
        state move-to-goal
        intention move
        border-left-x =leftborderx
        bodycolor =bodycol

    =visual-location>
        screen-x =x
        screen-y =y
        color =bodycol

    =imaginal>
    <   leftbound =x
    <   rightbound =x
    rightbound =targetx
    upbound =targety
    
    ?manual>
        state free

    !eval! (not (and (= =targetx (- =x 25))  (= =targety =y)))

==>
    !bind! =leftmove (- =x 25) 
       
    =imaginal>
        nextx =leftmove
        nexty =y
        currentx =x
        currenty =y

    +retrieval>
        button a
    =goal>
        intention check-for-tile

    +visual-location>
        screen-x =leftmove
        screen-y =y
        kind oval
    
)

(p target-left-next-to
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol

    =visual-location>
        screen-x =x
        screen-y =y
        color =bodycol

    =imaginal>
        upbound =targety
        leftbound =targetx
        upbound =y

    ?manual>
        state free

    !eval! (= =targetx (- =x 25))

==>
    !bind! =leftmove (- =x 25)

    =imaginal>
        nextx =leftmove
        nexty =y
        currentx =x
        currenty =y

    +retrieval>
        button a
    =goal>
        intention check-for-tile
    
    +visual-location>
        screen-x =leftmove
        screen-y =y
        kind oval
)
(p target-right
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol
    =visual-location>
        screen-x =x
        screen-y =y
        color =bodycol

    =imaginal>
    >   leftbound =x
    >  rightbound =x
        rightbound =targetx
        upbound =targety
    
    ?manual>
        state free

    !eval! (not (and (= =targetx (+ =x 25)) (= =targety =y)))

==>
    !bind! =rightmove (+ =x 25)    

    +retrieval>
        button d
    =goal>
        intention check-for-tile

    =imaginal>
        nextx =rightmove
        nexty =y
        currentx =x
        currenty =y

    +visual-location>
        screen-x =rightmove
        screen-y =y
        kind oval
)

(p target-right-next-to
    =goal>
        state move-to-goal
        intention move
        bodycolor =bodycol

    =visual-location>
        color =bodycol
        screen-x =x
        screen-y =y

    =imaginal>
        isa movetotarget
        downbound =y
        upbound =y
        leftbound =targetx
        rightbound =targetx
    
    ?manual>
        state free

    !eval! (= =targetx (+ =x 25))

==>
    !bind! =rightmove (+ =x 25)  

    =imaginal>
        nextx =rightmove
        nexty =y
        currentx =x
        currenty =y

    +retrieval>
        button d

    =goal>
        intention check-for-tile

    +visual-location>
        screen-x =rightmove
        screen-y =y
        kind oval

)

(p target-tile-check-reached-position
    =goal>
        state move-to-goal
        intention check-move-block
        bodycolor =bodycol

    =imaginal>
        leftbound =x
        rightbound =x
        upbound =y
        downbound =y
        nextx =newx
        nexty =newy

    =visual-location>
        screen-x =newx
        screen-y =newy
        color =bodycol
    
    ?manual>
            state free
    ?visual>
        state busy
    ?retrieval>
        state free

    ;!eval! ((string-equal =rewardcol "unknown") (string-equal =penaltycol "unknown"))

==>
    =goal>
        intention scan-bonus-request
    =imaginal>
    
    +visual-location>
    >=   screen-x 355
    <   screen-x 455
        screen-y 308
        kind TEXT

    +retrieval>
        screen-x =x
        screen-y =y
    -   color =bodycol

    +visual>
        cmd clear

)

(p penalty-reward-tile-check1
    =goal>
        state move-to-goal
        intention scan-bonus-request
        penaltycolor =penaltycol
        rewardcolor =rewardcol
        ;!eval! (or(string-equal =rewardcol "unknown") (string-equal =penaltycol "unknown"))

    =visual-location>
        kind text
        color black
    ?visual>
        buffer empty
        state free
        processor free
    =retrieval>
==>
    =goal>
        intention attend-score
    +visual>
        cmd move-attention
        screen-pos =visual-location
    =retrieval>
)

(p penalty-tile-check2
    =goal>
        state move-to-goal
        intention attend-score
        ;penaltycolor unknown
        bodycolor =bodycol
        score =score
    ?visual>
        state free
        processor free
    =visual>
        value =newscore

    !eval! (>= (parse-integer =score) (parse-integer =newscore))

    =retrieval>
        color =penaltycol
==>
    =goal>
        penaltycolor =penaltycol
        score =newscore

        state move-to-goal
        intention scan-score-move-read-score-reached

    +visual-location>
        color =bodycol
        kind oval
)
(p reward-tile-check2
    =goal>
        state move-to-goal
        intention attend-score
        ;rewardcolor unknown
        bodycolor =bodycol
        score =score

    =visual>
        value =newscore
    
    !eval! (< (parse-integer =score) (parse-integer =newscore))
     

    =retrieval>
        color =rewardcol
    ?visual>
        state free
        processor free
==>
    =goal>
        rewardcolor =rewardcol
        state move-to-goal
        intention scan-score-move-read-score-reached
        score =newscore

    +visual-location>
        color =bodycol
        kind oval
)


(p target-reached-move-attention-to-body

    =goal>
        intention scan-score-move-read-score-reached
        blockcolor =blockcol
        bodycolor =bodycol
  
    =visual-location>
        color =bodycol
        kind oval
    ?manual>
        state free



==>
    =goal>
        intention retrack-reached
    +visual>
        cmd move-attention
        screen-pos =visual-location
)


(p target-tile-reached-retrack

    =goal>
        intention retrack-reached
  
    =visual>
    ;    state free
    ?visual>
        state free
        processor free
    ;=visual-location>

==>
    =goal>
        state find-goal
        intention search
    +visual>
        cmd start-tracking
)


(p score-check-done-reattend-body

    =goal>
        state move-to-goal
        intention reattend
        bodycolor =bodycol
    =visual-location>
        color =bodycol
        kind oval
==>
    +visual>
        cmd move-attention
        screen-pos =visual-location
    =goal>    
        intention find-direction
    
)

(p block-tile-check
    =goal>
        state move-to-goal
        intention find-direction
        blockcolor unknown
    ?visual-location>
        ;buffer failure
        state error
    =imaginal>
        leftbound =x
        upbound =y
        nextx =newx
        nexty =newy
==>
    +visual-location>
        screen-x =newx
        screen-y =newy
    =imaginal>
    =goal>
        intention identify-block
)
(p block-tile-color-ident
    =goal>
        state move-to-goal
        intention identify-block
    =imaginal>
        leftbound =x
        upbound =y
        nextx =newx
        nexty =newy
    =visual-location>
       screen-x =newx
       screen-y =newy
       color =blockcol

==>
    =goal>
        state find-goal
        intention search
        blockcolor =blockcol
    =imaginal>

)
(P move-onto-check-after-move
    =goal>
        state move-to-goal
        intention check-after-move
        bodycolor =bodycol
    ?manual>
        state free
    =imaginal>
        upbound =targety
        leftbound =targetx
==>
    +visual-location>
        screen-x =targetx
        screen-y =targety
        color =bodycol
    =imaginal>
    =goal>
        intention find-direction
)


(p target-tile-check-not-blocked-but-there-is-tile
    =goal>
        intention check-blocked
        blockcolor =blockcol
    -   blockcolor unknown
    =visual-location>
        kind oval
    -   color =blockcol
    ?visual-location>
    -   state error
    -   buffer failure
    ?visual>
        processor free
    =retrieval>
        button =but
    ?manual>
        state free
==>
    +manual>
        cmd press-key
        key =but
    =goal>
        intention find-direction
)

(p target-tile-check-blocked-color-unknown
    =goal>
        intention check-blocked
        blockcolor unknown

    ?visual-location>
    -   state error
    -   buffer failure
    ?visual>
        processor free
    =retrieval>
        button =but
    ?manual>
        state free
    =imaginal>
        nextx =nextX
        nexty =nextY
        leftbound =targetlx
        rightbound =targetrx
        downbound =targetdy
        upbound  =targetuy

    =visual-location>
        screen-x =supposedy
        screen-y =supposedy
        color =blockcol
        kind oval
==>
    ;+manual>
    ;    cmd press-key
    ;    key =but
    =goal>
        intention find-direction
        ;intention am-i-blocked
        blockcolor =blockcol
    =imaginal>

)

(p check-blocked-unknown-check-not-target-color
    =goal>
        intention check-blocked
        bodycolor =bodycol
        blockcolor unknown
    =imaginal>
        leftbound =lx
        rightbound =rx
        downbound =dy
        upbound =uy
        tilecolor =targetcol
    =visual-location>
        screen-x =newX
        screen-y =newY
    -   color =bodycol
    -   color =targetcol
        color =blockcol 
==>
    =goal>
        blockcolor =blockcol 
        intention find-direction
    =imaginal>
    )

(p check-blocked-unknown-its-the-target-color
    =goal>
        intention check-blocked
        bodycolor =bodycol
        blockcolor unknown
    =imaginal>
     leftbound =lx
     rightbound =rx
     downbound =dy
     upbound =uy
     tilecolor =targetcol
    =visual-location>
        screen-x =newX
        screen-y =newY
    -   color =bodycol
        color =targetcol
        color =blockcol 

==>
    =goal>
        blockcolor =blockcol 
        state find-goal
        intention search
    =imaginal>
    )

(p check-blocked-unknown-check-intermediate
    =goal>
        intention check-blocked
        bodycolor =bodycol
        blockcolor =bodycol
    =visual-location>
        screen-x =newX
        screen-y =newY
        color =bodycol
        color =blockcol
==>
    =goal>
        blockcolor =blockcol 
        intention find-direction
    )


(p target-tile-check-not-blocked-nothing-intermediate
    =goal>
        intention check-for-tile
        blockcolor =blockcol
        bodycolor =bodycol
    ?visual-location>
        state error
    =retrieval>
        button =buttontopress
    ?manual>
        state free

    =imaginal>
        nextx =nextx
        nexty =nexty

==>
    +manual>
        cmd press-key
        key =buttontopress
    =goal>
        intention find-direction
        
    =imaginal>
        ;currentx =nextx
        ;currenty =nexty 

    +visual-location>
        color =bodycol
        kind oval

)

(p target-tile-check-blocked-intermediate
    =goal>
        intention check-blocked
        blockcolor =blockcol
    =visual-location>
        kind oval
        color =blockcol
    =retrieval>
        button =but
==>
    =goal>
        state find-goal
        intention search

)

(p target-move-there-is-a-tile-move
    =goal>
        intention check-for-tile
        bodycolor =bodycol
    =imaginal>
        nextx =newx
        nexty =newy

    =visual-location>
        screen-x =newx
        screen-y =newy
        color =col
        kind oval
    =retrieval>
        button =buttontopress
    ?manual>
        state free
    

==>
    +manual>
        cmd press-key
        key =buttontopress
    =goal>
        state move-to-goal
        intention check-for-new-loc
    =imaginal>
    =visual-location>

    ;=retrieval>

    
    )

(p target-move-there-is-a-tile-did-i-move

    =goal>
        intention check-for-new-loc
        bodycolor =bodycol
    =imaginal>
        nextx =newx
        nexty =newy
    ?manual>
        state free
    ?visual>
        processor free
        buffer unrequested
==>
    +visual-location>
        kind oval
        screen-x =newx 
        screen-y =newy
        color =bodycol
    =goal>
        intention check-move-block
    =imaginal>
        

)

;;;;
(p target-tile-check-reached-position-not-target
    =goal>
        state move-to-goal
        intention check-move-block
        bodycolor =bodycol

    =imaginal>
        leftbound =targetlx
        rightbound =targetrx
        upbound =targetyu
        downbound =targetyd
        nextx =newx
        nexty =newy

    =visual-location>
        screen-x =newx
        screen-y =newy
        color =bodycol
    -   screen-x =targetlx
    -   screen-x =targetrx
    -   screen-y =targetyd
    -   screen-y =targetyu
    
    ?manual>
            state free
    ?visual>
        state busy
    ?retrieval>
        state free

    ;!eval! ((string-equal =rewardcol "unknown") (string-equal =penaltycol "unknown"))

==>
    =goal>
        intention scan-bonus-not-target
    =imaginal>
    
    +visual-location>
    >=   screen-x 355
    <   screen-x 455
        screen-y 308
        kind TEXT

    +retrieval>
        screen-x =newx
        screen-y =newy
    -   color =bodycol

    +visual>
        cmd clear

)

(p penalty-reward-tile-check1-not-target
    =goal>
        state move-to-goal
        intention scan-bonus-not-target
        penaltycolor =penaltycol
        rewardcolor =rewardcol
        !eval! (or (string-equal =rewardcol "unknown") (string-equal =penaltycol "unknown"))

    =visual-location>
        kind text
        color black
    ?visual>
        buffer empty
        state free
        processor free
    =retrieval>
==>
    =goal>
        intention attend-score-not-target
    +visual>
        cmd move-attention
        screen-pos =visual-location
    =retrieval>
)

(p penalty-tile-check2-not-target
    =goal>
        state move-to-goal
        intention attend-score-not-target
        ;penaltycolor unknown
        bodycolor =bodycol
        score =score
    ?visual>
        state free
        processor free
    =visual>
        value =newscore
    !eval! (>= (parse-integer =score) (parse-integer =newscore))
    =retrieval>
        color =penaltycol
==>
    =goal>
        penaltycolor =penaltycol
        score =newscore

        state move-to-goal
        intention scan-score-move-read-score2

    +visual-location>
        color =bodycol
        kind oval
    !output! (parse-integer =newscore)
)

(p reward-tile-check2-not-target
    =goal>
        state move-to-goal
        intention attend-score-not-target
        ;rewardcolor unknown
        bodycolor =bodycol
        score =score
    =visual>
        value =newscore
    !eval! (< (parse-integer =score) (parse-integer =newscore))

    =retrieval>
        color =rewardcol
    ?visual>
        state free
        processor free
==>
    =goal>
        rewardcolor =rewardcol
        score =newscore

        state move-to-goal
        intention scan-score-move-read-score2

    +visual-location>
        color =bodycol
        kind oval
    !output! (parse-integer =newscore)

)
;;;;;;;


(p target-move-blocked-by-a-block-tile

    =goal>
        intention check-move-block
        bodycolor =bodycol
        ;blockcolor unknown
    ?visual-location>
        state error
    =imaginal>
        currentx =x
        currenty =y
        nextx =newx
        nexty =newy
    ?manual>
        state free

    ==>

    =goal>
        intention check-blocked

    =imaginal>
            
    +visual-location>
        screen-x =newx
        screen-y =newy
 
)

(p target-move-blocked-by-a-block-tile-unknown-color-scan-it

    =goal>
        intention check-blocked
        bodycolor =bodycol
        blockcolor unknown
    =imaginal>
        currentx =x
        currenty =y
        nextx =newx
        nexty =newy
    =visual-location>
        screen-x =nextx
        screen-y =nexty
        color =blockcol

==> 
    =goal>
        blockcolor =blockcol
        ;intention find-direction
    =imaginal>
        nextx =x
        nexty =y
)
    
    

(p target-move-i-am-blocked-check-left

    =goal>
        intention check-blocked
        bodycolor =bodycol
    -   blockcolor unknown
        blockcolor =blockcol
        border-left-x =leftborderx
    =imaginal>
        currentx =x
        currenty =y
 
    ?retrieval>
        state free
    
    ;!eval! (> =x (+ =leftborderx 12))
    !eval! (> =x (+ =leftborderx 37))

    ==>

        =goal>
            intention check-blocked-move
        !bind! =leftmove (- =x 25)
        +visual-location>
            screen-x =leftmove
            screen-y =y
            kind oval
            ;-   color =blockcol


        =imaginal>
            nextx =leftmove
            nexty =y
        +retrieval>
            button a
)

(p target-move-i-am-blocked-check-right

    =goal>
        intention check-blocked
        bodycolor =bodycol
    -   blockcolor unknown
        blockcolor =blockcol
        border-right-x =rightborderx
    =imaginal>
        currentx =x
        currenty =y
  

    ?retrieval>
        state free
    
    ;!eval! (< =x (- =rightborderx 13))
    !eval! (< =x (- =rightborderx 38))


    ==>

        =goal>
            intention check-blocked-move
        !bind! =rightmove (+ =x 25)
        +visual-location>
            screen-x =rightmove
            screen-y =y
            kind oval
            ;-   color =blockcol

        =imaginal>
            nextx =rightmove
            nexty =y
        +retrieval>
            button d
)

(p target-move-i-am-blocked-check-down

    =goal>
        intention check-blocked
        bodycolor =bodycol
    -   blockcolor unknown
        blockcolor =blockcol
        border-lower-y =downbordery

    =imaginal>
        currentx =x
        currenty =y

    ?retrieval>
        state free

    ;!eval! (< =y (- =downbordery 12))
    !eval! (< =y (- =downbordery 37))



    ==>

        =goal>
            intention check-blocked-move
        !bind! =downmove (+ =y 25)
        +visual-location>
            screen-x =x
            screen-y =downmove
            kind oval
        ;-   color =blockcol

        =imaginal>
            nextx =x
            nexty =downmove

        +retrieval>
            button s
)

(p target-move-i-am-blocked-check-up

    =goal>
        intention check-blocked
        bodycolor =bodycol
    -   blockcolor unknown
        blockcolor =blockcol
        border-upper-y =upbordery

   =imaginal>
        currentx =x
        currenty =y

    ?retrieval>
        state free
    
    !eval! (> =y (+ =upbordery 37))


    ;!eval! (> =y (+ =upbordery 12))
    

    ==>

        =goal>
            intention check-blocked-move
        !bind! =upmove (- =y 25)
        +visual-location>
            screen-x =x
            screen-y =upmove
            kind oval
        ;-   color =blockcol

        =imaginal>
            nextx =x
            nexty =upmove

        +retrieval>
            button w
)


(p target-move-i-am-blocked-move-to-tile

    =goal>
        intention check-blocked-move
        bodycolor =bodycol
        blockcolor =blockcol
    -   =blockcol unknown
    =retrieval>
        button =btn
    =imaginal>
        nextx =newx
        nexty =newy
    =visual-location>
        screen-x =newx
        screen-y =newy
    -  color =blockcol
    -   color =bodycol
    
    ?visual>
        state busy
    ?manual>
        state free
    ==>

    =goal>
            intention scan-score-move-attend
    +manual>
        cmd press-key
        key =btn
    =imaginal>
        currentx =newx
        currenty =newy
        nextx =newx
        nexty =newy

    +visual-location>
        >=   screen-x 355
        <   screen-x 455
        screen-y 308
        kind TEXT
    +visual>
        cmd clear
)

(p target-check-for-tile-move-loc-i-am-blocked-move-to-tile-score

    =goal>
        intention scan-score-move-attend
        blockcolor =blockcol
        bodycolor =bodycol
  
    =visual-location>
        kind TEXT

==>
    +visual>
        cmd move-attention
        screen-pos =visual-location
    
        =goal>
            intention scan-score-move-read-score1

)

(p target-check-for-tile-move-loc-i-am-blocked-move-to-tile-score-read1

    =goal>
        intention scan-score-move-read-score1
        blockcolor =blockcol
        bodycolor =bodycol
  
    =visual>
        value =val
    ?manual>
        state free



==>
    !bind! =readvalint (parse-integer =val)
    !output! =readvalint
    !output! =val

    =goal>
        score =readvalint
        intention scan-score-move-read-score2
    +visual-location>
        color =bodycol
        kind oval
)


(p target-check-for-tile-move-loc-i-am-blocked-move-to-tile-score-read2

    =goal>
        intention scan-score-move-read-score2
        blockcolor =blockcol
        bodycolor =bodycol
  
    =visual-location>
        color =bodycol
        kind oval
    ?manual>
        state free



==>
    =goal>
        intention retrack
    +visual>
        cmd move-attention
        screen-pos =visual-location
)


(p target-check-for-tile-move-loc-i-am-blocked-move-to-tile-score-retrack

    =goal>
        intention retrack
  
    =visual>
    ;    state free
    ?visual>
        state free
        processor free
    ;=visual-location>

==>
    =goal>
        intention find-direction
    +visual>
        cmd start-tracking
)


(p target-check-for-tile-move-loc-i-am-blocked-move-nothing-there

    =goal>
        intention check-blocked-move
        bodycolor =bodycol
    -   blockcolor unknown
        blockcolor =blockcol
    =retrieval>
        button =btn
    =imaginal>
        nextx =newx
        nexty =newy
    ?visual-location>
        state error
    ?manual>
        state free

    ==>

     =goal>
            intention find-direction
    +manual>
        cmd press-key
        key =btn
    =imaginal>
        currentx =newx
        currenty =newy
        
)


(p target-check-i-am-blocked-dont-move

    =goal>
        intention check-blocked-move
        bodycolor =bodycol
    -   blockcolor unknown
        blockcolor =blockcol
    =retrieval>
        button =btn
    =imaginal>
        nextx =newx
        nexty =newy
        currentx =x
        currenty =y

    =visual-location>
        color =blockcol
        screen-x =newx
        screen-y =newy

    ==>

        =goal>
            intention check-blocked
 
        =imaginal>
)

(p i-am-trying-to-reach-a-block
    =goal>
        blockcolor =blockcol
    =imaginal>
        tilecolor =blockcol
    =retrieval>
==>
    =goal>
        state find-goal
        intention search
    =imaginal>
    )

(p i-am-looking-for-the-last-color-penalty
    =goal>
        bodycolor =bodycol
        goalcolor =goalcol
        penaltycolor unknown
    -   rewardcolor unknown
    -   blockcolor unknown
        rewardcolor =rewardcol
        blockcolor =blockcol
    =imaginal>
    -   tilecolor =bodycol
    -   tilecolor =goalcol
    -   tilecolor =rewardcol
    -   tilecolor =blockcol
        tilecolor =penaltycol
    
==>
    =goal>
        penaltycolor =penaltycol
        state find-goal
        intention search
)

(p i-am-looking-for-the-last-color-reward
    =goal>
        bodycolor =bodycol
        goalcolor =goalcol
        blockcolor =blockcol
        rewardcolor unknown
    -   penaltycolor unknown
    -   blockcolor unknown
        penaltycolor =penaltycol

    =imaginal>
    -   tilecolor =bodycol
    -   tilecolor =goalcol
    -   tilecolor =penaltycol
    -   tilecolor =blockcol
        tilecolor =rewardcol

    =retrieval>

    
==>
    =goal>
        rewardcolor =rewardcol
         state find-goal
        intention search
    =imaginal>
)

)