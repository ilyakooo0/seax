=<
|=  html=tape
^-  (unit tape)
=/  processed-html 
  %+  drop-tag  "script"
  %+  drop-tag  "style"
  html
=/  parse-result
  ^-  (unit (list tape))
  %+  rust  processed-html  apex
=/  fragments  (skip ((list tape) +.parse-result) is-all-whitespace)
`(zing (join " " fragments))
|%
++  apex
  %-  star
  ;~(pfix (star tag) not-tag)
++  tag
  (ifix [gal gar] (plus ;~(less gar next)))
++  not-tag
  (plus ;~(less gal next))
++  is-whitespace
  |=  text=@t
  ^-  ?
  ?!  ?=(~ (rush text ;~(pose ;~(less prn next) gaw)))
++  is-all-whitespace
  |=  =tape
  ^-  ?
  %+  levy  tape  is-whitespace
++  drop-tag
  |=  [tag=tape html=tape]
  ^-  tape
  =/  start  (find "<{tag}" html)
  ?~  start  html
  =/  end-tag  "</{tag}>"
  =/  end  (find end-tag html)
  ?~  end  html
  ?:  (lth +.end +.start)  html :: Malformed html
  =/  removed-one  %+  weld
  (scag +.start html)
  (slag (add +.end (lent end-tag)) html)
  $(html removed-one)
--
