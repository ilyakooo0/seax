/-  *seax
/-  diary
/+  dbug, engines, rank, sink, strandio
|%
+$  query  cord
+$  search-state
$:
  number-of-subscriptions=@u
  search-results=(map term (unit (list search-result)))
==
+$  state-0
$:
  notes=shelf:diary
  search-subscriptions=(map query search-state)
  peers=_(silt ~[~zod ~racfer-hattes])
  alive-peers=(set @p)
==
+$  poke
  $%
    [%add-peers (set @p)]
    [%get-notes ~]
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
  ++  liveness-interval  ~s30
  ++  gossip-interval  ~s30
--

=/  state  *state-0
=*  current-engines
  |=  =query
  ^-  (list [term ?(%loading %failed %completed)])
  %+  turn  ~(tap in ~(key by engines))
  |=  engine=term
  :-  engine
  =/  results
    (~(get by search-results:(~(got by search-subscriptions.state) query)) engine)
  ?~  results  %loading
  ?~  +.results  %failed
  ?~  +>.results  %failed
  %completed
=*  search-results
  |=  =query
  %-  rank-results
  =/  search-state=search-state
    (~(got by search-subscriptions.state) query)
  search-results.search-state
=*  sink-for-query
  |=  =query
  [(current-engines query) (search-results query)]
=*  sink
  |=  =query
  ((sink:^sink ~[~[%search query]]) (sink-for-query query))

^-  agent:gall
%-  agent:dbug
|_  =bowl:gall
+*  this  .
    liveness-behn-card  [%pass /check-liveness %arvo %b %wait (add now.bowl liveness-interval)]
    gossip-behn-card  [%pass /gossip %arvo %b %wait (add now.bowl gossip-interval)]
++  on-init
  [~[liveness-behn-card gossip-behn-card] this]
++  on-save   !>(state)
++  on-load   
  |=  =vase
  =/  state  !<(state-0 vase)
  :-  ~
  %=  this
  state  state
  ==
++  on-poke   
  |=  [=mark =vase]
  ^-  (quip card:agent:gall _this)
  =/  poke  !<(poke vase)
  ~&  poke
  ?-  -.poke
      %add-peers  
        [~ this(peers.state (~(put in (~(uni in peers.state) +.poke)) src.bowl))]
      %get-notes  
        `this(notes.state .^(shelf:diary %gx /(scot %p our.bowl)/diary/(scot %da now.bowl)/shelf/noun))
  ==
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
    [[flush:(sink query) cards] this]
  =/  subscription=search-state  +.subscription
  =.  subscription
    [+(number-of-subscriptions.subscription) search-results.subscription]
  =.  search-subscriptions.state
    (~(put by search-subscriptions.state) query subscription)
  [~[flush:(sink query)] this]
    [%ping ~]
  ~&  path
  :-
  :~
    [%give %fact ~ %noun !>(%pong)]
    [%give %kick ~ ~]
  ==
  this
  
  ==

:: This was not tested because it requires waiting 12 hours.
++  on-leave
  |=  =path
  ?+  path  `this
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
++  on-agent  
  |=  [=wire =sign:agent:gall]
  ?+  wire  `this
    [%alive ~]
  ?+  -.sign  `this
    %fact
  ~&  "{<src.bowl>} is alive"
  =.  alive-peers.state  (~(put in alive-peers.state) src.bowl)
  `this
  ==
  ==
++  on-arvo
  |=  [=wire =sign-arvo] 
  ^-  (quip card:agent:gall _this)
  ~&  wire
  ?+  wire  `this
    [%search-result query=@t engine=term ~]
  ?>  ?=([%iris %http-response %finished *] sign-arvo)
  =/  query=@t  +<.wire
  =/  sink  (sink query)
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
  =^  card  sink  (sync:sink (sink-for-query query))
  ~&  (current-engines query)
  [~[card] this]
    [%check-liveness ~]
  =/  checks
    %+  turn  ~(tap in peers.state)
    |=  peer=@p
    [%pass /alive %agent [peer %seax] %watch /ping]
  =.  peers.state  alive-peers.state
  =.  alive-peers.state  *(set @p)
  =/  timer
    liveness-behn-card
  :-
  [timer checks]
  this
    [%gossip ~]
  :-
  :-  gossip-behn-card
  %+  turn  ~(tap in peers.state)
  |=  peer=@p
  [%pass / %agent [peer %seax] %poke %noun !>([%add-peers peers.state])]
  this
  ==
++  on-fail
  |=  [term =tang] 
  ((slog tang) `this)
--

