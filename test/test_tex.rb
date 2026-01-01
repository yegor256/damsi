# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require_relative 'tex'

# Test for TeX.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
# License:: MIT
class TestTeX < Minitest::Test
  def test_primitive_document
    tex = TeX.new
    tex.info('Hello, world!')
    tex.info('Hello, \\LaTeX!')
    Dir.mktmpdir do |dir|
      pdf = File.join(dir, 'a.pdf')
      tex.to_pdf(path: pdf)
      assert(File.exist?(pdf))
    end
  end
end
