/-  *seax
/+  engines

=<
|=  results=(list [engine=term results=(list search-result)])
^-  (list search-result)
=/  url-to-engine-map
  ^-  (list (map @t [engines=(list term) ords=(list @u) result=search-result]))
  %-  zing
  %+  turn  results
  |=  [engine=term results=(list search-result)]
  %+  turn  (zip (gulf 1 (lent results)) results)
  |=  [ord=@u result=search-result]
  %-  malt  ~[[url.result [~[engine] ~[ord] result]]]
=/  url-to-engines-map
  ^-  (map @t [engines=(list term) ords=(list @u) result=search-result])
  %+  roll  url-to-engine-map
  |=  
    $:
      a=(map @t [engines=(list term) ords=(list @u) result=search-result]) 
      b=(map @t [engines=(list term) ords=(list @u) result=search-result])
    ==
  %-  (~(uno by a) b)
  |=
    $:
      *
      [engines-lhs=(list term) ords-lhs=(list @u) result=search-result]
      [engines-rhs=(list term) ords-rhs=(list @u) *]
    ==
  [(weld engines-lhs engines-rhs) (weld ords-lhs ords-rhs) result]
=/  ranking
  ^-  (list [ord=@rs result=search-result])
  %+  turn  ~(val by url-to-engines-map)
  |=  [engines=(list term) ords=(list @u) result=search-result]
  =/  engine-weights
    ^-  (list @rs)
    %+  turn  engines
    |=  engine=term
    =/  engine  (~(got by ^engines) engine)
    weight.engine
  =/  engine-weights
    ^-  @rs
    %+  roll  engine-weights
    |=  [a=_.1 b=_.1]
    (mul.rs a b)
  =/  position-weights
    ^-  @rs
    %+  mul.rs  (lent ords)
    %+  roll
    (turn ords |=(ord=@u (div.rs 1 (sun:rs ord))))
    add
  =/  rank
    ^-  @rs
    (mul.rs engine-weights position-weights)
  [ord=rank result=result]
=/  sorted-results
  %+  sort  ranking
  |=  [[lhs=@rs *] [rhs=@rs *]]
  %+  gth  lhs  rhs
~&  sorted-results
%+  turn  sorted-results
|=  [* result=search-result]
result

|%
++  zip
  |*  [a=(list) b=(list)]
  ?~  a  ~
  ?~  b  ~
  [[i.a i.b] $(a t.a, b t.b)]
--