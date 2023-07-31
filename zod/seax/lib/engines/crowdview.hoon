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
  ^-  (unit (list search-result))
  =/  body  q.data.response
  ;<  jon=json  _biff  (de:json:html body)
  (apex jon)
--
::
|%
++  apex
  =,  dejs-soft:format
  %-  ot
  ~[results+(ar parse-search-result)]
++  parse-search-result
  =,  dejs-soft:format
  %-  ot
  ~[title+so link+so]
--

