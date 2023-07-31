/-  *seax
/+  dbug, engines, rank, sink

|%
+$  query  cord
+$  search-state
$:
  number-of-subscriptions=@u
  search-results=(map term (unit (list search-result)))
==
+$  state-0
$:
  search-subscriptions=(map query search-state)
==
+$  poke
  $%
    [%search query=tape]
  ==
++  rank-results
  |=  search-results=(map term (unit (list search-result)))
  %-  rank
  %-  cat-units
  %+  turn  ~(tap by search-results)
  |=  [engine=term results=(unit (list search-result))]
  %+  bind  results
  |=  results=(list search-result)
  [engine results]
++  cat-units
  |*  x=(list (unit *))
  ?~  x  ~
  ?~  i.x  $(x t.x)
  [+.i.x $(x t.x)]
++  search-cards
  |=  =query
  ^-  (list card:agent:gall)
  %+  turn  ~(tap by engines)
  |=  [engine-name=term engine=engine *]
  =/  req
    ^-  task:iris
    [%request [%'GET' (crip (url.engine (trip query))) ~ ~] *outbound-config:iris]
  [%pass ~[%search-result query engine-name] %arvo %i req]
--

=/  state  *state-0
=*  search-results
  |=  =query
  %-  rank-results
  =/  search-state=search-state
    (~(got by search-subscriptions.state) query)
  search-results.search-state
=*  sink
  |=  =query
  ((sink:^sink ~[%search query]) (search-results query))
:: =/  sinks  *(map query _(sink ''))

^-  agent:gall
%-  agent:dbug
|_  =bowl:gall
+*  this  .
++  on-init   `..on-init
++  on-save   !>(state)
++  on-load   
  |=  =vase
  =/  state  !<(state-0 vase)
  :-  ~
  %=  this
  state  state
  ==
++  on-poke   
  |=  =cage
  ^-  (quip card:agent:gall _this)
  `this

++  on-watch  
  |=  =path 
  ?+  path  !!
    [%search query ~]
  =/  query  +<.path
  =/  subscription=(unit search-state)
    (~(get by search-subscriptions.state) query)
  ?~  subscription
    =.  search-subscriptions.state
      (~(put by search-subscriptions.state) query [1 ~])
    =/  cards  (search-cards query)
    [cards this]
  =/  subscription=search-state  +.subscription
  =.  subscription
    [+(number-of-subscriptions.subscription) search-results.subscription]
  =.  search-subscriptions.state
    (~(put by search-subscriptions.state) query subscription)
  [~[flush:(sink query)] this]
  ==

:: This was not tested because it requires waiting 12 hours.
++  on-leave
  |=  =path
  ~&  path
  ?+  path  !!
    [%search query ~]
    =/  query  +<.path
    ~&  path
    =/  search-state  (~(got by search-subscriptions.state) query)
    =/  number-of-subscriptions  (dec number-of-subscriptions.search-state)
    =.  search-subscriptions.state
      ?~  number-of-subscriptions 
        (~(del by search-subscriptions.state) query)
      (~(put by search-subscriptions.state) query search-state(number-of-subscriptions number-of-subscriptions))
    `this
  ==

++  on-peek   
  |=  path
  ~
++  on-agent  |=([wire sign:agent:gall] !!)
++  on-arvo
  |=  [=wire =sign-arvo] 
  ^-  (quip card:agent:gall _this)
  ~&  wire
  ?+  wire  `this
    [%search-result query=@t engine=term ~]
  ?>  ?=([%iris %http-response %finished *] sign-arvo)
  =/  query=@t  +<.wire
  =/  engine-name=term  +>-.wire
  =/  [=engine *]  (~(got by engines) engine-name)
  =/  search-subscription  (~(got by search-subscriptions.state) query)
  =/  results=(unit (list search-result))
    ;<  data=mime-data:iris  _biff  full-file.client-response.sign-arvo
    (results.engine data)
  ~&  results
  =.  search-results.search-subscription
    (~(put by search-results.search-subscription) engine-name results)
  =.  search-subscriptions.state
    (~(put by search-subscriptions.state) query search-subscription)  
  `this
  ==
++  on-fail   |=([term tang] `..on-init)
--

