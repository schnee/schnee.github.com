---
layout: post
title: SuperPAC Receipts by State
---

A colleague exposed me to the [R](http://cran.r-project.org) enviroment. It smoted me and I looked for non-work datasets. I found [The Sunlight Foundation](http://sunlightfoundation.com/) and started digging through their data, and I found their reports on [Super PAC spending](http://reporting.sunlightfoundation.com/outside-spending-2012/super-pacs/). I downloaded the [Super PAC Summary](http://reporting.sunlightfoundation.com/outside-spending-2012/file-downloads/) data and broke out R.

I wanted to break out the Independent Expenditures by State, and map them. I read in the data and tidied it up a bit.


{% highlight r %}
suppressPackageStartupMessages(require(mapproj))
suppressPackageStartupMessages(require(ggplot2))
suppressPackageStartupMessages(require(grid))
suppressPackageStartupMessages(library(maps))
suppressPackageStartupMessages(require(plyr))

pac <- read.csv("./committee_summary.csv", header = TRUE)

names(pac)[12] <- "receipts"
str(pac)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	1027 obs. of  20 variables:
##  $ Name                          : Factor w/ 1025 levels "1911 UNITED",..: 782 56 681 525 428 380 997 210 815 334 ...
##  $ Committee.ID                  : Factor w/ 1027 levels "C00235929","C00363390",..: 62 30 100 23 98 120 175 31 534 60 ...
##  $ Treasurer                     : Factor w/ 449 levels "","AARON NOSBISCH",..: 397 89 395 250 60 374 49 71 128 437 ...
##  $ Street_1                      : Factor w/ 450 levels "","1 PENN PLAZA",..: 258 73 28 283 282 214 143 131 113 264 ...
##  $ Street_2                      : Factor w/ 40 levels "","#211","148 NASSAU AVE UPPER",..: 26 29 18 38 1 1 1 1 1 1 ...
##  $ City                          : Factor w/ 241 levels "","AKRON","ALBANY",..: 228 228 228 228 228 228 113 228 228 214 ...
##  $ ZIP.code                      : int  20004 20005 20005 20005 20005 20001 30043 20036 20036 33606 ...
##  $ state                         : Factor w/ 51 levels "","AK","AL","AR",..: 9 9 9 9 9 9 12 9 9 11 ...
##  $ Connected.Org.Name            : Factor w/ 28 levels "","9-9-9 FUND",..: 1 16 28 16 16 1 1 1 22 1 ...
##  $ Political.Orientation         : Factor w/ 3 levels "Backs Democrats",..: 2 2 1 1 1 2 2 2 1 2 ...
##  $ Filing.frequency              : Factor w/ 3 levels "Monthly","Quarterly",..: 1 1 1 2 2 1 1 1 2 1 ...
##  $ receipts                      : num  1.32e+08 8.01e+07 6.39e+07 3.49e+07 2.77e+07 ...
##  $ Total.unitemized.contributions: num  298 188926 279650 43230 243088 ...
##  $ cash.on.hand                  : num  24203768 6423726 10086434 7461199 5196881 ...
##  $ last.report.date              : Factor w/ 29 levels "","10/11/12",..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ total.IEs                     : num  1.43e+08 1.05e+08 6.62e+07 3.75e+07 3.08e+07 ...
##  $ IEs.support.dems              : num  0 0 0 3609417 865049 ...
##  $ IEs.oppose.dems               : num  88572359 95858190 0 0 0 ...
##  $ IEs.support.reps              : num  14090892 8477066 0 0 0 ...
##  $ IEs.oppose.reps               : num  39992095 375217 66182181 33868125 29709982 ...
{% endhighlight %}

PAC is a data frame with many columns. For this purpose, I'm interested in the receipts and the state identifiers.

I needed to summarize the receipts and ensure that the states matched the codes from the states_map object. And then I had to override the "district of columbia". At that point, I could plot out a quick view. 

{% highlight r %}
pdata <- ddply(pac, "state", summarize, Sum = sum(receipts, na.rm = TRUE))

states_map <- map_data("state")

pdata$statelc <- tolower(state.name[match(pdata$state, state.abb)])

pdata$statelc[9] <- "district of columbia"

ggplot(data = pdata, aes(x = state, y = Sum)) + geom_bar(width = 1, stat = "identity") + 
    theme(legend.position = "none") + labs(x = "State", y = "Receipts") + ggtitle("SuperPAC Receipts by State Comparison")
{% endhighlight %}

![center](/figs/superpac-receipts/unnamed-chunk-2.png) 

Unsuprisingly, most SuperPAC money flows to PACs headquartered in Washington, DC. So much money that DC will dominate subsequent plots; I decided to get rid of DC.


{% highlight r %}
pdata.noDC = subset(pdata, state != "DC")

ggplot(pdata.noDC, aes(x = state, y = Sum)) + geom_bar(width = 1, stat = "identity") + 
    theme(legend.position = "none") + labs(x = "State", y = "Receipts") + ggtitle("SuperPAC Receipts by State Comparison\nDC omitted")
{% endhighlight %}

![center](/figs/superpac-receipts/unnamed-chunk-3.png) 


Much better.

A quick coloring of the states with a gradient showed


{% highlight r %}
ggplot(pdata.noDC, aes(map_id = statelc, fill = Sum)) + geom_map(map = states_map) + 
    expand_limits(x = states_map$long, y = states_map$lat) + coord_map("polyconic")
{% endhighlight %}

![center](/figs/superpac-receipts/unnamed-chunk-4.png) 


that the gradient treatment doesn't really help distinguish between different levels: is Washington more or less than Oregon? But note that Nebraska isn't participating in Super PAC spending at all.

Quantization provided a better view.


{% highlight r %}
qs = quantile(pdata.noDC$Sum, c(0, 0.2, 0.4, 0.6, 0.8, 1))
qsf = sprintf("$%.2f", qs)
qlabels = paste(head(qsf, -1), tail(qsf, -1), sep = " - ")

pdata.noDC$Sum_q <- cut(pdata.noDC$Sum, qs, labels = qlabels, include.lowest = TRUE)

pal <- colorRampPalette(c("grey80", "darkgreen"))(5)

clean_theme <- theme(axis.title = element_blank(), axis.text = element_blank(), 
    panel.background = element_blank(), panel.grid = element_blank(), axis.ticks.length = unit(0, 
        "cm"), complete = TRUE)

ggplot(pdata.noDC, aes(map_id = statelc, fill = Sum_q)) + geom_map(map = states_map, 
    colour = "black") + scale_fill_manual(values = pal) + expand_limits(x = states_map$long, 
    y = states_map$lat) + coord_map("polyconic") + labs(fill = "Receipts", x = "Longitude", 
    y = "Latitude") + ggtitle("SuperPAC Receipts by State\nof Registration\nDC Omitted") + 
    clean_theme
{% endhighlight %}

![center](/figs/superpac-receipts/unnamed-chunk-5.png) 

Now, we can see that Super PACs in Oregon take in fewer receipts than those in Washington.

This was a quick way to take state-coded data and present it graphically. I would have been "done", except that I noticed that the data has columns such as "IEs.support.dems" and "IEs.support.reps". Sunlight [tells](http://reporting.sunlightfoundation.com/super-pac/data/about/2012-june-update/) me that this spending is either positive (support) or negative (oppose). Doing something with that information seemed interesting, and is covered in the next post.
