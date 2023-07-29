/-  *seax

^-  engine
=<
|%
++  url
  |=  query=tape
  ^-  tape
  %+  weld
  "https://wiby.me/json/?q="
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
  (ar parse-search-result)
++  parse-search-result
  =,  dejs:format
  %-  ot
  ~[[%'Title' so] [%'URL' so]]
--


