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
      @ticks.push(cell[:tick], "\\texttt{\\frenchspacing{}DA: #{vw}.#{arc} → #{v2}.#{arc}}")
    else
      @log.debug("DA: v1:#{v1}, v2:#{v2}, arc:#{arc}, data:#{data}")
    end
    after = cell
    after[:v2] = v2
    [after]
  end
end
