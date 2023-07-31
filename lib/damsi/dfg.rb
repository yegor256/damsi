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

require_relative 'ticks'

# Dataflow Graph (DFG)
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class Damsi::DFG
  def initialize(prog)
    @prog = prog
    @cells = {}
    @ops = {}
    @ticks = Damsi::Ticks.new
    @tick = 0
  end

  def cell(vtx)
    @cells[vtx]
  end

  def send(vtx, args)
    @cells[vtx] = {} if @cells[vtx].nil?
    args.each do |k, a|
      @cells[vtx][k] = a
      @ticks.push(@tick, "\\texttt{#{a}} $\\to$ \\texttt{#{vtx}\\textbar{}1.#{k}}")
    end
  end

  def recv(vtx, &block)
    @ops[vtx] = block
  end

  # Returns an instance of +Ticks+.
  def simulate(log)
    # rubocop:disable Security/Eval
    eval(@prog)
    # rubocop:enable Security/Eval
    send(:start, {})
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
        log.debug("#{@tick}: #{v} called with #{args}")
        execs += 1
        @cells.delete(v)
      end
      break if execs.zero?
      @tick += 1
      raise 'Ran out of ticks' if @tick > 100
    end
    @ticks
  end
end
