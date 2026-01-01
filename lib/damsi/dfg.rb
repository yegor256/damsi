# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'ticks'
require_relative 'advisor'

# Dataflow Graph (DFG).
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
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
    @advisor = Damsi::Advisor.new(self, @ticks, log)
    @links = []
    @edges = []
  end

  # Add edge (only for information).
  def edge(arc, left, right)
    @edges.push({ arc: arc, v1: left, v2: right })
  end

  # The edge exists?
  def e?(arc, left, right)
    @edges.each do |e|
      next if !arc.nil? && e[:arc] != arc
      next if !left.nil? && e[:v1] != left
      next if !right.nil? && e[:v2] != right
      return e[:arc] if arc.nil?
      return e[:v1] if left.nil?
      return e[:v2] if right.nil?
      return true
    end
    false
  end

  # Add link to external entity, like RAM.
  def link(vtx, ext)
    @links.push({ vtx: vtx, ext: ext })
  end

  # The semantic of the vertex is memory related?
  def m?(vtx, ext)
    @links.each do |l|
      next if !vtx.nil? && l[:vtx] != vtx
      next if !ext.nil? && l[:ext] != ext
      return l[:vtx] if vtx.nil?
      return l[:ext] if ext.nil?
      return true
    end
    false
  end

  def cell(vtx)
    @cells[vtx]
  end

  def msg(tex)
    @ticks.push(@tick, "\\texttt{\\frenchspacing{}#{@op}: #{tex}}")
  end

  # Send "data" through the "arc" to the vertex "vtx"
  def send(vtx, arc, data)
    @advisor.redirect({ tick: @tick, v1: @op, v2: vtx, arc: arc, data: data }).each do |ic|
      @cells[ic[:v2]] = {} if @cells[ic[:v2]].nil?
      @cells[ic[:v2]][ic[:arc]] = ic[:data]
      @ticks.push(@tick, "\\texttt{\\frenchspacing{}#{@op}: \"#{ic[:data]}\" → #{ic[:v2]}.#{ic[:arc]}}")
      @log.debug("#{@tick}| #{ic[:data]} -> #{ic[:v2]}.#{ic[:arc]}")
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
