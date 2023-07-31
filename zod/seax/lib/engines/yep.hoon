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
  =/  body  q.data.response
  ;<  jon=json  _biff  (de:json:html body)
  (apex jon)
--
::
|%
++  apex
  |=  jon=json
  ^-  (unit (list search-result))
  =,  dejs-soft:format
  ;<  [* results=(list search-result)]  _biff  %-  (at ~[so (ot ~[results+(ar parse-search-result)])])  jon
  `results
++  parse-search-result
  =,  dejs-soft:format
  %-  ot
  ~[title+so url+so]
--
