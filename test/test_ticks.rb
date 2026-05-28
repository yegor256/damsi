# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'loog'
require 'minitest/autorun'
require_relative '../lib/damsi/ticks'
require_relative 'tex'

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
      assert_path_exists(pdf)
    end
  end

  def test_broken_latex
    ticks = Damsi::Ticks.new
    ticks.push(1, '\ & # % \boom }{ ][ ><')
    ticks.to_latex(TeX.new)
  end

  def test_empty
    tex = TeX.new
    Damsi::Ticks.new.to_latex(tex)
    Dir.mktmpdir do |dir|
      pdf = File.join(dir, 'a.pdf')
      tex.to_pdf(path: pdf)
      assert_path_exists(pdf)
    end
  end
end
