It's a simulator of a dataflow machine.

First, you define a dataflow graph and save it to `fibo.dfg` 
(this is the calculator of the 5th Fibonacci number):

```
send :fibo n:5
send :if f:1
recv :fibo [:n] do
  send :gt n:n
  send :dec1 n:n
  send :dec2 n:n
  send :sum a:n  # if tagged
  send :sum b:n  # if tagged right
end
recv :if [:c, :t, :f] do
  if c
    send :fibo n:t
  else
    send :fibo n:f
  end
end
recv :sum [:a, :b] do
  send :if (a + b)
end
recv :dec1 [:n] do
  send :fibo n:(n-1)
end
recv :dec2 [:n] do
  send :fibo n:(n-2)
end
```

This is a Ruby dialect.
