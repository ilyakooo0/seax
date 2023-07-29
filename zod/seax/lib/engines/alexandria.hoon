/-  *seax

^-  engine
=<
|%
++  url
  |=  query=tape
  ^-  tape
  %+  weld
  "https://api.alexandria.org/?a=1&q="
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
  =,  dejs:format
  %-  ot
  ~[results+(ar parse-search-result)]
++  parse-search-result
  =,  dejs:format
  %-  ot
  ~[title+so url+so]
--



