#' Knit .Rmd file into a jekyll blog post 
#'  
#' Code modified from https://github.com/jfisher-usgs/jfisher-usgs.github.com/blob/master/R/KnitPost.R
#' Also includes ideas from https://github.com/supstat/vistat/blob/gh-pages/_bin/knit
#' @export
#' @examples
#' \dontrun{library(devtools); install_github('knitPost', 'cpsievert')}
#' library(knitPost)
#' setwd("~/Desktop/github/local/cpsievert.github.com/")
#' knitPost("2013-05-15-hello-jekyll.Rmd")

knitPost <- function(post="superpac-receipts.Rmd", baseUrl="http://schnee.github.io/") {
  sourcePath <- file.path(getwd(), "_source", post)
  opts_knit$set(base.url=baseUrl)
  base <- sub("\\.[Rr]md$", "", basename(sourcePath))
  fig.path <- paste0("figs/", base, "/")
  opts_chunk$set(fig.path=fig.path)
  opts_chunk$set(fig.cap="center")
  render_jekyll()
  knit(sourcePath, paste('_posts/', base, '.md', sep = ''), envir=parent.frame())
}