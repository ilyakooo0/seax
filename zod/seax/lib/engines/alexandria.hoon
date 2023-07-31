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
  ~[title+so url+so]
--



