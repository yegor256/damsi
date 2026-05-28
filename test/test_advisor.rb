# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'loog'
require 'minitest/autorun'
require_relative '../lib/damsi/advisor'
require_relative '../lib/damsi/ticks'

# Test for Advisor.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
# License:: MIT
class TestAdvisor < Minitest::Test
  def test_simple_redirect
    assert_equal(
      1,
      Damsi::Advisor.new(Damsi::DFG.new('', Loog::NULL), Damsi::Ticks.new, Loog::NULL).redirect({}).length
    )
  end
end
