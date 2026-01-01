# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'loog'
require_relative 'tex'
require_relative '../lib/damsi/ticks'

# Test for Ticks.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
# License:: MIT
class TestTicks < Minitest::Test
  def test_simple_render
    ticks = Damsi::Ticks.new
    ticks.push(1, 'hello')
    ticks.push(2, 'world')
    tex = TeX.new
    ticks.to_latex(tex)
    Dir.mktmpdir do |dir|
      pdf = File.join(dir, 'a.pdf')
      tex.to_pdf(path: pdf)
      assert(File.exist?(pdf))
    end
  end

  def test_broken_latex
    ticks = Damsi::Ticks.new
    ticks.push(1, '\ & # % \boom }{ ][ ><')
    tex = TeX.new
    ticks.to_latex(tex)
  end

  def test_empty
    ticks = Damsi::Ticks.new
    tex = TeX.new
    ticks.to_latex(tex)
    Dir.mktmpdir do |dir|
      pdf = File.join(dir, 'a.pdf')
      tex.to_pdf(path: pdf)
      assert(File.exist?(pdf))
    end
  end
end
