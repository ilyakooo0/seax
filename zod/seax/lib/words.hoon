=<
|=  haystack=tape
^-  (list tape)
(scan haystack apex)
::
|%
++  apex
  ;~  pfix
    (star whit)
    %-  star
    ;~  sfix 
     (plus ;~(less whit next))
     (star whit)
    ==
  ==
++  whit
  (mask ~[' ' `@`0x9 `@`0xa `@`0xd])
--
