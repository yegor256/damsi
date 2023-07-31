[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/damsi)](http://www.rultor.com/p/yegor256/damsi)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/damsi/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/damsi/actions/workflows/rake.yml)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/damsi)](http://www.0pdd.com/p?name=yegor256/damsi)
![Lines of code](https://img.shields.io/tokei/lines/github/yegor256/damsi)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/damsi)](https://hitsofcode.com/view/github/yegor256/damsi)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/damsi/blob/master/LICENSE.txt)

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
