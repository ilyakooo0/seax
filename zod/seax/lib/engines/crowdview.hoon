/-  *seax

^-  engine
=<
|%
++  url
  |=  query=tape
  ^-  tape
  %+  weld
  "https://crowdview-next-js.onrender.com/api/search-v3?query="
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
  ~[title+so link+so]
--

