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

# Distribution Advisor.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class Damsi::Advisor
  def initialize(dfg, log)
    @dfg = dfg
    @log = log
  end

  # The instruction cell (IC) is coming here and the method
  # should return a possibly empty array of ICs.
  def redirect(cell)
    v1 = cell[:v1]
    vw = cell[:v2]
    v2 = vw
    arc = cell[:arc]
    data = cell[:data]
    a = @dfg.m?(vw, nil)
    vr = @dfg.e?(:k, vw, nil)
    @log.debug("DA: a:#{a}, vr:#{vr}")
    if @dfg.e?(:d, v1, vw) && @dfg.m?(vr, a)
      v2 = @dfg.e?(:d, vr, nil)
      @log.debug("DA: v1:#{v1}, v2:#{vw}->#{v2}, arc:#{arc}, data:#{data}")
    else
      @log.debug("DA: v1:#{v1}, v2:#{v2}, arc:#{arc}, data:#{data}")
    end
    [{ v1: v1, v2: v2, arc: arc, data: data }]
  end
end
