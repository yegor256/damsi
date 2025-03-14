# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'loog'
require_relative 'tex'
require_relative '../lib/damsi/dfg'
require_relative '../lib/damsi/ticks'

# Test for DFG.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class TestDFG < Minitest::Test
  def test_edges_finding
    dfg = Damsi::DFG.new(
      '
      edge :a, :v1, :v2
      edge :b, :v1, :v2
      ',
      Loog::NULL
    )
    dfg.simulate
    assert(dfg.e?(:a, :v1, :v2))
  end

  def test_edges_finding_by_mask
    dfg = Damsi::DFG.new(
      '
      edge :a, :v1, :v2
      edge :b, :v1, :v2
      ',
      Loog::NULL
    )
    dfg.simulate
    assert_equal(:v2, dfg.e?(:a, :v1, nil))
  end

  def test_links_finding
    dfg = Damsi::DFG.new(
      '
      link :v1, "foo"
      link :v2, "bar"
      ',
      Loog::NULL
    )
    dfg.simulate
    assert(dfg.m?(:v1, 'foo'))
    assert(!dfg.m?(:v1, 'bar'))
  end

  def test_links_finding_by_mask
    dfg = Damsi::DFG.new(
      '
      link :v1, "foo"
      link :v2, "bar"
      ',
      Loog::NULL
    )
    dfg.simulate
    assert_equal(:v1, dfg.m?(nil, 'foo'))
    assert_equal('bar', dfg.m?(:v2, nil))
  end

  def test_primitive_summator
    dfg = Damsi::DFG.new(
      '
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
<<<<<<< Updated upstream
      @data = 42
      def next_random(n)
        (n * n) / 16 & 0xffff
      end
      recv :r1 do
        msg "Read #{@data} from RAM"
        send :nxt1, :d, @data
      end
      recv :nxt1 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w1, :d, n
      end
      recv :w1 do |d|
        @data = d
        msg "Write #{d} to RAM"
        send :r2, :k, 1
      end
      recv :r2 do |k|
        msg "Read #{@data} from RAM"
        send :nxt2, :d, @data
      end
      recv :nxt2 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w2, :d, n
        send :seq, :d, n
      end
      recv :seq do |d|
        send :stop, :x, d
      end
      ',
      Loog::VERBOSE
    )
    ticks = dfg.simulate
    assert_equal(756, dfg.cell(:stop)[:x])
    tex = TeX.new
    ticks.to_latex(tex)
    tex.to_pdf(path: '/tmp/damsi.pdf', tex: '/tmp/damsi.tex')
  end

  def test_prng_with_links
    dfg = Damsi::DFG.new(
      '
      @data = 42
      def next_random(n)
        (n * n) / 16 & 0xffff
      end

      edge :d, :r1, :nxt1
      edge :d, :nxt1, :w1
      edge :k, :w1, :r2
      edge :d, :r2, :nxt2
      edge :d, :nxt2, :w2
      edge :d, :nxt2, :seq

      link :r1, "RAM"
      recv :r1 do
        msg "Read #{@data} from RAM"
        send :nxt1, :d, @data
      end
      recv :nxt1 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w1, :d, n
      end
      link :w1, "RAM"
      recv :w1 do |d|
        @data = d
        msg "Write #{d} to RAM"
        send :r2, :k, 1
      end
      link :r2, "RAM"
      recv :r2 do |k|
        msg "Read #{@data} from RAM"
        send :nxt2, :d, @data
      end
      link :w2, "RAM"
      recv :nxt2 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w2, :d, n
        send :seq, :d, n
      end
      ',
      Loog::VERBOSE
    )
    ticks = dfg.simulate
    assert_equal(756, dfg.cell(:seq)[:d])
    tex = TeX.new
    ticks.to_latex(tex)
    tex.to_pdf(path: '/tmp/damsi.pdf', tex: '/tmp/damsi.tex')
  end

  def test_prng_optimized
    dfg = Damsi::DFG.new(
      '
      @data = 42
      def next_random(n)
        (n * n) / 16 & 0xffff
      end
      recv :r1 do
        msg "Read #{@data} from RAM"
        send :nxt1, :d, @data
      end
      recv :nxt1 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :nxt2, :d, n
      end
      recv :nxt2 do |d|
        n = next_random(d)
        msg "Shift from #{d} to #{n}"
        send :w2, :d, n
        send :seq, :d, n
      end
      recv :seq do |d|
        send :stop, :x, d
      end
      ',
      Loog::VERBOSE
    )
    ticks = dfg.simulate
    assert_equal(756, dfg.cell(:stop)[:x])
    tex = TeX.new
    ticks.to_latex(tex)
    tex.to_pdf(path: '/tmp/damsi.pdf', tex: '/tmp/damsi.tex')
=======
      recv :start do
        send :last, x:17
        send :main, \kappa:15
      end
      recv :sum do |a, b|
        send :mul, x: (a+b)
      end
      recv :mul do |x|
        send :stop, x: x
      end
      '
    )
    ticks = dfg.simulate(Loog::NULL)
    assert_equal(25, dfg.cell(:stop)[:x])
    tex = TeX.new
    ticks.to_latex(tex)
    tex.to_pdf(path: '/tmp/damsi.pdf')
>>>>>>> Stashed changes
  end
end
