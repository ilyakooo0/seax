/-  *seax
/+  dbug, engines

|%
  +$  url  @t
  +$  word  @t
  +$  number-of-hits  @u
  +$  number-of-hits-mop  ((mop number-of-hits (set url)) gth)
  +$  rwi  (map word number-of-hits-mop)
  +$  word-index  (map url (map word @u))
  +$  search-index  [rwi=rwi wi=word-index]
  +$  state-0  ~
  +$  poke
    $%
      [%search query=tape]
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
--

=/  state  *state-0

^-  agent:gall
%-  agent:dbug
|_  =bowl:gall
+*  this  .
++  on-init   `..on-init
++  on-save   !>(state)
++  on-load   
  |=  =vase
  =/  state  !<(state-0 vase)
  `this(state state)
++  on-poke   
  |=  =cage
  ^-  (quip card:agent:gall _this)
  ~&  cage
  ?+  -.cage  !!
    %noun
      =/  poke  !<(poke +.cage)
      ?-  -.poke
        %search
      =/  url
        %-  crip  (url:engines-alexandria query.poke)
      ~&  url
      =/  req
        ^-  task:iris
        [%request [%'GET' url ~ ~] *outbound-config:iris]
      :_  this
      ~[[%pass ~[%yep] %arvo %i req]]

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
  ~&  wire
  ?+  wire  !!
    [%yep ~]
  ?>  ?=([%iris %http-response %finished *] sign-arvo)
  =/  results
    %-  results:engines-alexandria  (need full-file.client-response.sign-arvo)
  ~&  results
  `this
  ==
++  on-fail   |=([term tang] `..on-init)
--

