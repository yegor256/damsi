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

require 'loog'

# TeX accumulated through a log.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2023 Yegor Bugayenko
# License:: MIT
class TeX < Loog::Buffer
  # Makes a PDF at the provided path, returns nothing
  def to_pdf(path: '/tmp/damsi.pdf')
    Dir.mktmpdir do |dir|
      name = 'paper.tex'
      tex = File.join(dir, name)
      body = "\\documentclass{article}\\usepackage[T1]{fontenc}\\begin{document}#{self}\\end{document}"
      File.write(tex, body)
      cmd = "set -x && cd #{dir} && ls -al && pdflatex -shell-escape -halt-on-error #{name} 2>&1"
      system(cmd)
      pdf = File.join(dir, 'paper.pdf')
      raise "The PDF was not generated at #{pdf}" unless File.exist?(pdf)
      FileUtils.copy(pdf, path)
    end
  end
end
