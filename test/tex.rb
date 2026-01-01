# SPDX-FileCopyrightText: Copyright (c) 2023-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'loog'

# TeX accumulated through a log.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023-2026 Yegor Bugayenko
# License:: MIT
class TeX < Loog::Buffer
  def debug(msg)
    super("% #{msg}")
  end

  # Makes a PDF at the provided +path+, returns nothing. The TeX source
  # will be save to the provided +tex+ location, if it's not nil.
  def to_pdf(path: nil, tex: nil)
    Dir.mktmpdir do |dir|
      name = 'paper.tex'
      doc = File.join(dir, name)
      body = "\\documentclass{article}\n\\usepackage[T1]{fontenc}\n\\begin{document}\n\n#{self}\n\n\\end{document}\n"
      File.write(doc, body)
      cmd = "set -x && cd #{dir} && ls -al && pdflatex -shell-escape -halt-on-error #{name} 2>&1"
      system(cmd)
      pdf = File.join(dir, 'paper.pdf')
      raise "The PDF was not generated at #{pdf}" unless File.exist?(pdf)
      FileUtils.copy(pdf, path) unless path.nil?
      FileUtils.copy(doc, tex) unless tex.nil?
    end
  end
end
