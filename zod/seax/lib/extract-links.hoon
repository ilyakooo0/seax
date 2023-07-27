=<
|=  [root=hart:eyre html=tape]
^-  (list tape)
=/  root-url=tape
  %-  en-purl:^html
  [root *pork:eyre *quay:eyre]
=/  links  (rust html apex)
?~  links  ~
%+  turn  `(list tape)`+.links
|=  link=tape
?~  (de-purl:^html (crip link))
  (weld root-url link)
link
::
|%
++  apex
  ;~  pfix
    %-  star  not-href
    %-  star  ;~(sfix href (star not-href))
  ==
++  not-href
  ;~(less (jest 'href') next)
++  href
  ;~(pfix (jest 'href=') quote url)
++  url
  (star ;~(less quote (just '#') next))
++  quote
  ;~(pose (just '"') (just '\''))
--