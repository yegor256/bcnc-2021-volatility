[![latex](https://github.com/yegor256/ctors-vs-size/workflows/latex/badge.svg)](https://github.com/yegor256/ctors-vs-size/actions?query=latex)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/ctors-vs-size/blob/master/LICENSE.txt)

Question: What happens to constructors when class size grows?
The amont of them grows as fast as the amount of methods?
No, it's not. Why? The research makes an attempt to answer this question.

The paper was published in the
[Proceedings of the 1st ACM SIGPLAN International Workshop on Beyond Code: No Code (BCNC 2021)](https://dl.acm.org/doi/abs/10.1145/3486949.3486961).
Here is the [PDF](https://www.yegor256.com/pdf/2021/volatility.pdf).

You need to have installed:

  * LaTeX
  * Make
  * Git
  * Python 3.7+
  * Ruby 2.6+

Just run `make` and in a few <del>seconds</del> hours, you will get
`article.pdf` file ready inside `/paper`.

Don't want to compile? Just read the [PDF](https://github.com/yegor256/ctors-vs-size/releases/latest/download/article.pdf).
