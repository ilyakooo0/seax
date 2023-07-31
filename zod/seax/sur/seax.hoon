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
  ++  results  |~  mime-data:iris  *(unit (list search-result))
  --
+$  engines  (map name=term [=engine weight=@rs])
--
