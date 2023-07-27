=<  |=(a=cord (rush a (star apex)))
|_  ent=_`(map term @t)`[[%apos '\''] ~ ~]
::                                                  ::  ++apex:de-xml:html
++  apex                                            ::  top level
  =+  spa=;~(pose comt whit)
  %+  knee  *manx  |.  ~+
  %+  ifix
    [;~(plug (punt decl) (star spa)) (star spa)]
  ;~  pose
    %+  sear  |=([a=marx b=marl c=mane] ?.(=(c n.a) ~ (some [a b])))
      ;~(plug head many tail)
    ;~(plug head many)
    empt
  ==
::                                                  ::  ++attr:de-xml:html
++  attr                                            ::  attributes
  %+  knee  *mart  |.  ~+
  %-  star
  ;~  plug
    ;~(pfix (plus whit) name)
    ;~  pose
      %+  ifix
        :_  doq
        ;~(plug (ifix [. .]:(star whit) tis) doq)
      (star ;~(less doq escp))
    ::
      %+  ifix
        :_  soq
        ;~(plug (ifix [. .]:(star whit) tis) soq)
      (star ;~(less soq escp))
    ::
      (easy ~)
    ==
  ==
::                                                  ::  ++cdat:de-xml:html
++  cdat                                            ::  CDATA section
  %+  cook
    |=(a=tape ^-(mars ;/(a)))
  %+  ifix
    [(jest '<![CDATA[') (jest ']]>')]
  %-  star
  ;~(less (jest ']]>') next)
::                                                  ::  ++chrd:de-xml:html
++  chrd                                            ::  character data
  %+  cook  |=(a=tape ^-(mars ;/(a)))
  (plus ;~(pose (just `@`10) escp))
::                                                  ::  ++comt:de-xml:html
++  comt                                            ::  comments
  =-  (ifix [(jest '<!--') (jest '-->')] (star -))
  ;~  pose
    ;~(less hep prn)
    whit
    ;~(less (jest '-->') hep)
  ==
::
++  decl                                            ::  ++decl:de-xml:html
  %+  ifix                                          ::  XML declaration
    [(jest '<?xml') (jest '?>')]
  %-  star
  ;~(less (jest '?>') prn)
::                                                  ::  ++escp:de-xml:html
++  escp                                            ::
  ;~(pose ;~(less gal gar pam prn) enty)
::                                                  ::  ++enty:de-xml:html
++  enty                                            ::  entity
  %+  ifix  pam^mic
  ;~  pose
    =+  def=^+(ent (my:nl [%gt '>'] [%lt '<'] [%amp '&'] [%quot '"'] ~))
    %+  sear  ~(get by (~(uni by def) ent))
    (cook crip ;~(plug alf (stun 1^31 aln)))
    %+  cook  |=(a=@c ?:((gth a 0x10.ffff) '�' (tuft a)))
    =<  ;~(pfix hax ;~(pose - +))
    :-  (bass 10 (stun 1^8 dit))
    (bass 16 ;~(pfix (mask "xX") (stun 1^8 hit)))
  ==
::                                                  ::  ++empt:de-xml:html
++  empt                                            ::  self-closing tag
  %+  ifix  [gal (jest '/>')]
  ;~(plug ;~(plug name attr) (cold ~ (star whit)))
::                                                  ::  ++head:de-xml:html
++  head                                            ::  opening tag
  (ifix [gal gar] ;~(plug name attr))
::                                                  ::  ++many:de-xml:html
++  many                                            ::  contents
  ;~(pfix (star comt) (star ;~(sfix ;~(pose apex chrd cdat) (star comt))))
::                                                  ::  ++name:de-xml:html
++  name                                            ::  tag name
  =+  ^=  chx
      %+  cook  crip
      ;~  plug
          ;~(pose cab alf (just ' ') (just '!'))
          (star ;~(pose cab dot alp))
      ==
  ;~(pose ;~(plug ;~(sfix chx col) chx) chx)
::                                                  ::  ++tail:de-xml:html
++  tail                                            ::  closing tag
  (ifix [(jest '</') gar] name)
::                                                  ::  ++whit:de-xml:html
++  whit                                            ::  whitespace
  (mask ~[' ' `@`0x9 `@`0xa `@`0xd])
--
