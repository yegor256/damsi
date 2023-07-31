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
require_relative '../lib/damsi/ticks'

# Test for Ticks.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
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
