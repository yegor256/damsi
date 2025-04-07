[![DevOps By Rultor.com](https://www.rultor.com/b/yegor256/damsi)](https://www.rultor.com/p/yegor256/damsi)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/damsi/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/damsi/actions/workflows/rake.yml)
[![PDD status](https://www.0pdd.com/svg?name=yegor256/damsi)](https://www.0pdd.com/p?name=yegor256/damsi)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/damsi)](https://hitsofcode.com/view/github/yegor256/damsi)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/damsi/blob/master/LICENSE.txt)

It's a simulator of a dataflow machine.

First, you define a dataflow graph and save it to `test.dfg`:

```
recv :start do
  send :sum, :a, 10
  send :sum, :b, 15
end
recv :sum do |a, b|
  send :mul, :x, (a+b)
end
recv :mul do |x|
  send :stop, :x, x
end
```

This is a Ruby dialect.
