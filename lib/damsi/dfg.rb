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
require_relative 'advisor'

# Dataflow Graph (DFG).
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class Damsi::DFG
  def initialize(prog, log)
    @prog = prog
    @log = log
    @cells = {}
    @ops = {}
    @ticks = Damsi::Ticks.new
    @tick = 0
    @op = nil
    @started = []
    @advisor = Damsi::Advisor.new
  end

  def cell(vtx)
    @cells[vtx]
  end

  def msg(tex)
    @ticks.push(@tick, "\\texttt{\\frenchspacing{}#{@op}: #{tex}}")
  end

  # Send "data" through the "arc" to the vertex "vtx"
  def send(vtx, arc, data)
    @advisor.redirect({ vtx: vtx, arc: arc, data: data }).each do |ic|
      @cells[ic[:vtx]] = {} if @cells[ic[:vtx]].nil?
      @cells[ic[:vtx]][ic[:arc]] = ic[:data]
      @ticks.push(@tick, "\\texttt{\\frenchspacing{}#{@op}: \"#{ic[:data]}\" → #{ic[:vtx]}.#{ic[:arc]}}")
      @log.debug("#{@tick}| #{ic[:data]} -> #{ic[:vtx]}.#{ic[:arc]}")
    end
  end

  def recv(vtx, &block)
    @ops[vtx] = block
  end

  # Returns an instance of +Ticks+.
  def simulate
    # rubocop:disable Security/Eval
    eval(@prog)
    # rubocop:enable Security/Eval
    loop do
      execs = 0
      before = @cells.clone
      before.each do |v, c|
        next if @ops[v].nil?
        blk = @ops[v]
        reqs = blk.parameters.select { |p| p[0] == :opt }.map { |p| p[1] }
        args = reqs.map { |r| [r, c[r]] }.to_h
        bound = args.map { |p| p[1] }.compact
        if bound.size < args.size
          @log.debug("#{@tick}| :#{v}(#{reqs.join(', ')}) is not ready to start with #{args}")
          next
        end
        @log.debug("#{@tick}| :#{v} starts with #{args} ...")
        @op = v
        blk.call(*bound)
        @log.debug("#{@tick}| :#{v} finished")
        execs += 1
        @cells.delete(v)
      end
      @ops.each do |v, blk|
        reqs = blk.parameters.select { |p| p[0] == :opt }.map { |p| p[1] }
        next unless reqs.empty?
        next if @started.include?(v)
        @started.push(v)
        @log.debug("#{@tick}| :#{v} starts empty ...")
        @op = v
        blk.call
        @log.debug("#{@tick}| :#{v} finished")
        execs += 1
      end
      if execs.zero?
        @log.debug("#{@tick}| no executions at #{before.count} operators, we stop here:\n#{before}")
        break
      end
      @tick += 1
      raise 'Ran out of ticks' if @tick > 100
    end
    @ticks
  end
end
