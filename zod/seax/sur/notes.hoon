|%
+$  diary
  $:  *
      *
      *
      *
      *
      =notes
      *
  ==
+$  seal
  $:  =time
      *  :: =quips
      *  :: feels=(map ship feel)
  ==
+$  note  [seal essay]
+$  verse
  $%  [%block p=block]
      [%inline p=(list inline)]
  ==
+$  listing
  $%  [%list p=?(%ordered %unordered) q=(list listing) r=(list inline)]
      [%item p=(list inline)]
  ==
+$  block
  $%  [%image src=cord height=@ud width=@ud alt=cord]
      [%cite *]  :: =cite:c]
      [%header p=?(%h1 %h2 %h3 %h4 %h5 %h6) q=(list inline)]
      [%listing p=listing]
      [%rule ~]
      [%code code=cord lang=cord]
  ==
+$  inline
  $@  @t
  $%  [%italics p=(list inline)]
      [%bold p=(list inline)]
      [%strike p=(list inline)]
      [%blockquote p=(list inline)]
      [%inline-code p=cord]
      [%ship p=ship]
      [%block p=@ud q=cord]
      [%code p=cord]
      [%tag p=cord]
      [%link p=cord q=cord]
      [%break ~]
  ==
+$  essay
  $:  title=@t
      image=@t
      content=(list verse)
      author=ship
      sent=time
  ==
++  notes
  =<  rock
  |%
  +$  rock
    ((mop time note) lte)
  ++  on
    ((^on time note) lte)
  +$  diff
    (pair time delta)
  +$  delta
    $%  [%add p=essay]
        [%edit p=essay]
        [%del ~]
        [%quips *]  :: p=diff:quips]
        [%add-feel p=ship *]  ::  q=feel]
        [%del-feel p=ship]
    ==
  --
+$  shelf  (map flag diary)
+$  flag  (pair ship term)
--
