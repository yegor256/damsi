# SPDX-FileCopyrightText: Copyright (c) 2023-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'loog'
require_relative '../lib/damsi/ticks'
require_relative '../lib/damsi/advisor'

# Test for Advisor.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2025 Yegor Bugayenko
# License:: MIT
class TestAdvisor < Minitest::Test
  def test_simple_redirect
    dfg = Damsi::DFG.new('', Loog::NULL)
    da = Damsi::Advisor.new(dfg, Damsi::Ticks.new, Loog::NULL)
    cell = {}
    ics = da.redirect(cell)
    assert_equal(1, ics.length)
  end
end
