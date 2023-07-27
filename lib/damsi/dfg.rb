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

class Damsi::DFG
  def initialize(p)
    @p = p
    @cells = {}
    @ops = {}
  end

  def send(v, args)
    @cells[v] = {} if @cells[v].nil?
    args.each { |k, a| @cells[v][k] = a }
  end

  def recv(v, &block)
    @ops[v] = block
  end

  def simulate
    eval(@p)
    cycles = 0
    loop do
      execs = 0
      before = @cells.clone
      before.each do |v, c|
        next if @ops[v].nil?
        blk = @ops[v]
        reqs = blk.parameters.select { |p| p[0] == :opt }
        args = reqs.map { |p| c[p[1]] }.compact
        next if args.size < reqs.size
        blk.call(*args)
        execs += 1
        @cells.delete(v)
      end
      break if execs.zero?
      cycles += 1
      break if cycles > 100
    end
    p @cells
  end
end
