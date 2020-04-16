# The MIT License (MIT)
#
# Copyright (c) 2020 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

all: install search clone calc summary draw article

install:
	bundle update
	gem install volatility

clean:
	rm -rf *.tex
	rm -rf repos.txt
	rm -rf summary.csv
	rm -rf clones
	cd paper; latexmk -c

search:
	ruby find-repos.rb | tee repos.txt

clone:
	while read line; do \
		p="clones/$${line}"; \
		if [ -e "$${p}/.git" ]; then \
			echo "$${p} already here"; \
		else \
			mkdir -p "$${p}"; \
			git clone --depth=1 "https://github.com/$${line}" "$${p}"; \
		fi \
	done < repos.txt

uncalc:
	find metrics -name 'scv.m' -exec rm \{} \;

metrics=files bytes dirs scv

calc:
	for f in $$(find clones/ -type directory -depth 2); do \
	  f=$${f/clones\/\//}; \
	  mkdir -p "metrics/$${f}"; \
		p="metrics/$${f}/files.m"; \
		if [ ! -e "$${p}" ]; then \
			find "clones/$${f}" -type file -not -path '.git/*' | wc -l > "$${p}"; \
		fi; \
		p="metrics/$${f}/dirs.m"; \
		if [ ! -e "$${p}" ]; then \
			find "clones/$${f}" -type directory -not -path '.git/*' | wc -l > "$${p}"; \
		fi; \
		p="metrics/$${f}/bytes.m"; \
		if [ ! -e "$${p}" ]; then \
			du -s -b "clones/$${f}" | awk '{ print $$1 }' > "$${p}"; \
		fi; \
		p="metrics/$${f}/scv.m"; \
		if [ ! -e "$${p}" ]; then \
			/code/volatility/bin/volatility --home="clones/$${f}" > "$${p}"; \
		fi; \
	done

summary:
	for i in ${metrics}; do \
		rm -rf "summary-$${i}.csv"; \
		touch "summary-$${i}.csv"; \
		for f in $$(find metrics -name $${i}.m); do \
			cat "$${f}" >> summary-$$i.csv; \
		done; \
		echo "$$(wc -l < summary-$${i}.csv) repos measured $${i}"; \
	done

draw: summary-files.csv summary-bytes.csv summary-dirs.csv
	ruby draw.rb --xaxis=summary-files.csv '--xlabel=log_{10}(M_1)' > paper/files.tex
	ruby draw.rb --xaxis=summary-bytes.csv '--xlabel=log_{10}(M_2)' > paper/bytes.tex
	ruby draw.rb --xaxis=summary-dirs.csv '--xlabel=log_{10}(M_3)' > paper/dirs.tex

metrics: summary-files.csv
	rm -f paper/total.tex
	echo "\\\def\\\thetotalrepos{$$(find metrics -name 'files.m' | wc -l)}" > paper/total.tex

article: paper/files.tex paper/bytes.tex paper/total.tex
	cd paper; rm -f article.pdf; latexmk -pdf article
