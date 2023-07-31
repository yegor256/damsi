# Copyright (c) 2023 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require 'loog'
require_relative 'tex'
require_relative '../lib/damsi/dfg'
require_relative '../lib/damsi/ticks'

# Test for DFG.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class TestDFG < Minitest::Test
  def test_primitive_summator
    dfg = Damsi::DFG.new(
      '
      recv :start do
        send :sum, a:10
        send :sum, b:15
      end
      recv :sum do |a, b|
        send :mul, x: (a+b)
      end
      recv :mul do |x|
        send :stop, x: x
      end
      ',
      Loog::NULL
    )
    ticks = dfg.simulate
    assert_equal(25, dfg.cell(:stop)[:x])
    tex = TeX.new
    ticks.to_latex(tex)
    tex.to_pdf(path: '/tmp/damsi.pdf')
  end

  def test_prng
    dfg = Damsi::DFG.new(
      '
      @data = 42
      def next_random(n)
        (n * n) / 16 & 0xffff
      end
      recv :r1 do
        msg "Read #{@data} from RAM"
        send :nxt1, d:@data
      end
      recv :nxt1 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w1, d:n
      end
      recv :w1 do |d|
        @data = d
        msg "Write #{d} to RAM"
        send :r2, k:1
      end
      recv :r2 do |k|
        msg "Read #{@data} from RAM"
        send :nxt2, d:@data
      end
      recv :nxt2 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w2, d:n
        send :seq, d:n
      end
      recv :seq do |d|
        send :stop, x:d
      end
      ',
      Loog::VERBOSE
    )
    ticks = dfg.simulate
    assert_equal(756, dfg.cell(:stop)[:x])
    tex = TeX.new
    ticks.to_latex(tex)
    tex.to_pdf(path: '/tmp/damsi.pdf')
  end
end
