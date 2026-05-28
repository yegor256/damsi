# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# Distribution Advisor.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
# License:: MIT
class Damsi::Advisor
  def initialize(dfg, ticks, log)
    @dfg = dfg
    @ticks = ticks
    @log = log
  end

  # The instruction cell (IC) is coming here and the method
  # should return a possibly empty array of ICs.
  def redirect(cell)
    origin = cell[:v1]
    vw = cell[:v2]
    target = vw
    arc = cell[:arc]
    data = cell[:data]
    a = @dfg.m?(vw, nil)
    vr = @dfg.e?(:k, vw, nil)
    @log.debug("DA: a:#{a}, vr:#{vr}")
    if @dfg.e?(:d, origin, vw) && @dfg.m?(vr, a)
      target = @dfg.e?(:d, vr, nil)
      @log.debug("DA: v1:#{origin}, v2:#{vw}->#{target}, arc:#{arc}, data:#{data}")
      @ticks.push(cell[:tick], "\\texttt{\\frenchspacing{}DA: #{vw}.#{arc} → #{target}.#{arc}}")
    else
      @log.debug("DA: v1:#{origin}, v2:#{target}, arc:#{arc}, data:#{data}")
    end
    after = cell
    after[:v2] = target
    [after]
  end
end
