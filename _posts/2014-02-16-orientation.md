---
layout: post
title: SuperPAC Spending Orientation by State
tags: [R, politics]
---

A [prior entry](/2014/02/11/superpac-receipts/) looked at Super PAC receipts for the 2011-2012 election cycle and showed a bit of R code. Here, we use the [same data](http://reporting.sunlightfoundation.com/outside-spending-2012/file-downloads/) and break it down by supporting and opposing spending by state.

*Technical note: I took this opportunity to start exploring the [dplyr](http://cran.r-project.org/web/packages/dplyr/index.html) R package. I think I like it.*


{% highlight r %}
suppressPackageStartupMessages(require(ggplot2))
suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(maps))
suppressPackageStartupMessages(require(grid))
suppressPackageStartupMessages(require(mapproj))
suppressPackageStartupMessages(require(scales))

pac <- read.csv("./committee_summary.csv", header = TRUE)

superpac.spend = pac %.% group_by(state) %.% summarise(or = sum(IEs.oppose.reps), 
    od = sum(IEs.oppose.dems), sr = sum(IEs.support.reps), sd = sum(IEs.support.dems)) %.% 
    arrange(state)

states_map <- map_data("state")

superpac.spend$statelc <- tolower(state.name[match(superpac.spend$state, state.abb)])

superpac.spend$statelc[9] <- "district of columbia"

superpac.spend$support <- (superpac.spend$sr - superpac.spend$sd)/(superpac.spend$sd + 
    superpac.spend$sr)
superpac.spend$oppose <- (superpac.spend$or - superpac.spend$od)/(superpac.spend$od + 
    superpac.spend$or)
{% endhighlight %}


At this point, superpac.spend is a nice little table

{% highlight r %}
suppressMessages(head(tbl_dt(superpac.spend)))
{% endhighlight %}



{% highlight text %}
##   state      or      od      sr      sd    statelc support  oppose
## 1             0       0       0       0       <NA>     NaN     NaN
## 2    AK       0       0       0       0     alaska     NaN     NaN
## 3    AL       0       0       0       0    alabama     NaN     NaN
## 4    AR       0       0       0       0   arkansas     NaN     NaN
## 5    AZ       0  182040  301577       0    arizona 1.00000 -1.0000
## 6    CA 2569098 2022101 3164335 2792334 california 0.06245  0.1191
{% endhighlight %}


"Support" measures the fraction (from -1 to 1) of spending in support of a political orientation. Full Republican support is "1"; full Democratic support is "-1". Likewise, "oppose" is the fraction of spending is opposition to a political orientation. Complete Republican opposition is "1"; complete Democratic opposition is "-1". In the above table, you can see that Super PACs registered in Arizona completely supported Republican causes and completely opposed Democratic ones.

We went to all the trouble of getting the state names (statelc). Let's use it to plot:


{% highlight r %}
clean_theme <- theme(axis.title = element_blank(), axis.text = element_blank(), 
    panel.background = element_blank(), panel.grid = element_blank(), axis.ticks.length = unit(0, 
        "cm"), complete = TRUE)

ggplot(superpac.spend, aes(map_id = statelc, fill = support)) + geom_map(map = states_map) + 
    expand_limits(x = states_map$long, y = states_map$lat) + coord_map("polyconic") + 
    scale_fill_gradient2(high = muted("red"), low = muted("blue"), mid = "white", 
        labels = c("Democratic", "Mostly Democratic", "Even", "Mostly Republican", 
            "Republican")) + labs(fill = "Supporting\nOrientation") + ggtitle("Statewise Spending Orientation\n2011-2012 Election Cycle\n[Supporting]") + 
    clean_theme
{% endhighlight %}

![center](http://schnee.github.com/figs/2014-02-16-orientation/unnamed-chunk-3.png) 

and

{% highlight r %}
ggplot(superpac.spend, aes(map_id = statelc, fill = oppose)) + geom_map(map = states_map) + 
    expand_limits(x = states_map$long, y = states_map$lat) + coord_map("polyconic") + 
    scale_fill_gradient2(high = muted("red"), low = muted("blue"), mid = "white", 
        labels = c("Democratic", "Mostly Democratic", "Even", "Mostly Republican", 
            "Republican")) + labs(fill = "Opposing\nOrientation") + ggtitle("Statewise Spending Orientation\n2011-2012 Election Cycle\n[Opposing]") + 
    clean_theme
{% endhighlight %}

![center](http://schnee.github.com/figs/2014-02-16-orientation/unnamed-chunk-4.png) 

Examining the graphs, the battleground state of Ohio spent on both supporting Republican causes and opposing democratic causes. As did Arizona and Florida (and others). Texas had a large spend supporting Republicans and an even larger spend opposing Republicans. Montana was neutral on supporting, but very strong on opposing Democratic causes and people. I'm told that it was a pretty nasty area for negative campaigning, and [PBS](http://www.pbs.org/wgbh/pages/frontline/big-sky-big-money/) even did a documentary on it.

Fun analysis, and maybe something that can be spun into the Sunlight Foundations [CodeAcross](http://sunlightfoundation.com/blog/2014/02/06/codeacross-is-here/) effort.