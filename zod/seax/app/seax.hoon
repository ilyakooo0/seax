/+  extract-text, extract-links, words, dbug

|%
  +$  url  @t
  +$  word  @t
  +$  number-of-hits  @u
  +$  number-of-hits-mop  ((mop number-of-hits (set url)) gth)
  +$  rwi  (map word number-of-hits-mop)
  +$  word-index  (map url (map word @u))
  +$  search-index  [rwi=rwi wi=word-index]
  +$  state-0
    $:
      rwi=search-index
      to-crawl=(list [url=url depth=@u])
    ==
  +$  poke
    $%
      [%start-crawl url=url]
      [%crawl-next ~]
      [%search @t]
    ==
  ++  urls-per-hits
    ((on number-of-hits (set url)) gth)
  ++  normalize-word
    |=  word=tape
    ^-  tape
    (cass word)
  ++  initial-crawl-depth  2
  ++  swap
    |*  [a=* b=*]
    [b a]
  ++  second
    |*  [a=* b=*]
    b
  ++  add-to-index
    |=  [index=search-index new-words=(map word number-of-hits) =url]
    ^-  search-index
    :-  (add-to-rwi rwi.index new-words url)
    %+  ~(put by wi.index)  url  new-words
  ++  add-to-rwi
    |=  [index=rwi new-words=(map word number-of-hits) =url]
    %-  second
    ^-  [(list ~) rwi]
    %^  spin  ~(tap by new-words)  index
    |=  [[=word =number-of-hits] index=rwi]
    :-  ~
    ^-  rwi
    =/  existing-number-of-hits  (~(get by index) word)
    ?~  existing-number-of-hits
      %+  ~(put by index)  word  
      (gas:urls-per-hits *number-of-hits-mop ~[[number-of-hits (silt ~[url])]])
    =/  existing-number-of-hits
      ^-  number-of-hits-mop
      +.existing-number-of-hits
    =/  urls  (get:urls-per-hits existing-number-of-hits number-of-hits)
    ?~  urls
      %+  ~(put by index)  word
        (put:urls-per-hits existing-number-of-hits number-of-hits (silt ~[url]))
    =/  urls  ^-  (set ^url)  +.urls
    %+  ~(put by index)  word
    %^  put:urls-per-hits  existing-number-of-hits
    number-of-hits  (~(put in urls) url)
--

=/  state  *state-0

^-  agent:gall
%-  agent:dbug
|_  =bowl:gall
+*  this  .
    next-crawl-card
      [%pass / %agent [our.bowl %seax] %poke [%noun !>((poke [%crawl-next ~]))]]
++  on-init   `..on-init
++  on-save   !>(state)
++  on-load   
  |=  =vase
  =/  state  !<(state-0 vase)
  `this(state state)
++  on-poke   
  |=  =cage
  ^-  (quip card:agent:gall _this)
  ?+  -.cage  !!
    %noun
      =/  poke  !<(poke +.cage)
      ?-  -.poke
        %start-crawl
      =/  url  url.poke
      =/  req
        ^-  task:iris
        [%request [%'GET' url ~ ~] *outbound-config:iris]
      :_  this
      ~[[%pass ~[%crawl-page (scot %ud initial-crawl-depth) url] %arvo %i req]]
      ::
        %crawl-next
      ?~  to-crawl.state  `this
      =/  url  url.i.to-crawl.state
      ?:  (~(has by wi.rwi.state) url)  [~[next-crawl-card] this(to-crawl.state t.to-crawl.state)]
      =/  req
        ^-  task:iris
        [%request [%'GET' url ~ ~] *outbound-config:iris]
      :_  this(to-crawl.state t.to-crawl.state)
      ~[[%pass ~[%crawl-page (scot %ud depth.i.to-crawl.state) url.i.to-crawl.state] %arvo %i req]]
      ::
        %search
      =/  query  
        ^-  (list tape)
        (turn (words (trip +.poke)) normalize-word)
      =/  top-results  
        ^-  (list cord)
        %-  zing
        ^-  (list (list cord))
        %-  zing
        ^-  (list (list (list cord)))
        %+  turn  query
        |=  word=tape
        =/  results  (~(get by rwi.rwi.state) (crip word))
        ?~  results  ~
        %+  turn  (tap:urls-per-hits +.results)
        |=  [* set=(set cord)]
        ~(tap in set)

      ~&  top-results
      `this
      ==
  
  ==
++  on-watch  |=(path !!)
++  on-leave  |=(path `..on-init)
++  on-peek   
  |=  path
  ~
++  on-agent  |=([wire sign:agent:gall] !!)
++  on-arvo
  |=  [=wire =sign-arvo] 
  ^-  (quip card:agent:gall _this)
  ?+  wire  !!
    [%crawl-page @t @t ~]
  ~&  "crawling {<+>-.wire>}"
  ?>  ?=([%iris %http-response %finished *] sign-arvo)
  =/  url=@t  +>-.wire
  =/  depth=@u  (slav %ud +<.wire)
  =/  purl  (need (de-purl:html url))
  =/  response-body
    %-  trip  q.data:(need full-file:client-response.sign-arvo)
  =/  words
    ^-  (unit (list tape))
    %+  bind
    (extract-text response-body)
    |=  text=tape
    (turn (words text) normalize-word)
  =/  word-index-map
    ^-  (unit (list (map cord @u)))
    %+  bind  words
    |=  words=(list tape)
    %+  turn  words
    |=  word=tape
    %-  malt  ~[[(crip word) 1]]
  =/  word-index
    ^-  (map word number-of-hits)
    ?~  word-index-map  *(map word number-of-hits)
    %+  roll  `(list (map cord @u))`+.word-index-map
    |=  [lhs=(map cord @u) rhs=(map cord @u)]
    %-  %-  ~(uno by lhs)  rhs
    |=  [* a=@u b=@u]  (add a b)
  =/  index  (add-to-index rwi.state word-index url)
  =/  links=(list tape)  (extract-links p.purl response-body)
  =/  next-depth  (dec depth)
  =/  to-crawl
    ?~  next-depth  to-crawl.state
    %+  weld
      to-crawl.state
      %+  turn  links
      |=  link=tape  [(crip link) next-depth]
  :_  this(to-crawl.state to-crawl, rwi.state index)
  ~[next-crawl-card]
  ==
++  on-fail   |=([term tang] `..on-init)
--

