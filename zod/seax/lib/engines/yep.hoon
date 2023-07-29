/-  *seax

^-  engine
=<
|%
++  url
  |=  query=tape
  ^-  tape
  %+  weld
  "https://api.yep.com/fs/1/?type=web&no_correct=false&limit=100&q="
  (en-urlt:html query)
++  results
  |=  response=mime-data:iris
  ^-  (list search-result)
  =/  body  q.data.response
  =/  jon  (need (de:json:html body))
  (apex jon)
--
::
|%
++  apex
  |=  jon=json
  =,  dejs:format
  =/  [* results=(list search-result)]
  %-  (at ~[so (ot ~[results+(ar parse-search-result)])])  jon
  results
++  parse-search-result
  =,  dejs:format
  %-  ot
  ~[title+so url+so]
--
