/-  *seax

^-  engine
=<
|%
++  url
  |=  query=tape
  ^-  tape
  %+  weld
  "https://urbit.org/api/dev-search?q="
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
  ~[glossary+(ar parse-search-result)]
++  parse-search-result
  =,  dejs-soft:format
  %-  ot
  ~[[%'name' so] [%'url' so]]
--
