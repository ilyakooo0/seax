|%
+$  search-result
  $:
    title=@t
    url=@t
  ==
++  engine
  $_  ^|
  |%
  ++  url  |~  tape  *tape
  ++  results  |~  mime-data:iris  *(list search-result)
  --
+$  engines  (list [=engine weight=@rs])
--
