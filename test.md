Title
========================================================

This is an R Markdown document. Markdown is a simple formatting syntax for authoring web pages (click the **Help** toolbar button for more details on using R Markdown).

When you click the **Knit HTML** button a web page will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:


{% highlight r %}
require(ggplot2)

df = data.frame(x = runif(100), y = runif(100))
ggplot(df, aes(x, y)) + geom_point()
{% endhighlight %}

![center](/figs/test/unnamed-chunk-1.png) 


You can also embed plots, for example:


{% highlight r %}
plot(cars)
{% endhighlight %}

![center](/figs/test/unnamed-chunk-2.png) 


