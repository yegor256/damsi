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

# Ticks accumulated after the evaluation of a DFG.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class Damsi::Ticks
  def initialize
    @ticks = {}
  end

  # Add a message in properly formatted LaTeX. If the TeX syntax
  # is broken, there will be a runtime problem later.
  def push(tick, tex)
    @ticks[tick] = [] if @ticks[tick].nil?
    @ticks[tick].push(tex)
  end

  def to_latex(log)
    total = @ticks.count
    if total.zero?
      log.info('no ticks')
      return
    end
    log.info("\\begin{tabular}{#{'l' * total}}")
    pos = 0
    @ticks.each do |_n, t|
      log.info("#{'&' * pos} \\multicolumn{#{total - pos}}{l}{\\begin{tabular}{|l}")
      t.each do |e|
        log.info(e)
        log.info('\\\\')
      end
      log.info('\\end{tabular}} \\\\')
      pos += 1
    end
    log.info('\\end{tabular}')
  end
end