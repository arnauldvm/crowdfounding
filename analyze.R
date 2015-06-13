if (FALSE) {
# https://github.com/ropensci/elastic
install.packages("devtools")
devtools::install_github("ropensci/elastic")

install.packages("data.table")
install.packages("ggplot2")
install.packages("zoo")
}

library('data.table')
library('elastic')
library('ggplot2')
library('scales')
library("zoo")

PAGE_SIZE=100
SCROLL_TIMEOUT="30s"
FIELDS=c('timestamp', 'pledged')

day_s = 24*60*60
interval_d = 1/6
interval_s = interval_d*day_s
window_width = 9
weights=c(1,2,3,4,5,4,3,2,1)
# weights=c(1,1,1,1,1,1,1,1,1)
# weights=c(0,0,0,0,1,0,0,0,0)

stop_time_str = "20150705-180000"
stop_time2_str = "20150010-180000"

str2time = function(str) {
  return(as.POSIXct(str, format="%Y%m%d-%H%M%S"))
}

from_list = function(l, name) {
  if (length(l)<1) {
    cat("Warning, received empty", name, "attribute for:")
    print(x)
    return(NA)
  } else {
    val = l[[1]]
    if (is.null(val)) {
      cat("Warning, received NULL", name, "attribute for:")
      print(l)
      return(NA)
    } else if (val=="NULL") {
      cat("Warning, received \"NULL\"", name, "attribute for:")
      print(l)
      return(NA)
    }
  }
  return(val)
  #pl = ifelse(length(l>0), ifelse(is.null(l[[1]]), NA, pl_list[[1]]), NA)
}

stop_time = str2time(stop_time_str)
stop_time2 = str2time(stop_time2_str)

connect()

results = data.frame(stringsAsFactors=FALSE)
current = 0
first = TRUE
repeat {
  if (first) {
    found = Search(index="logstash-kickstarter-*", sort="@timestamp", fields=FIELDS, scroll=SCROLL_TIMEOUT, size=PAGE_SIZE)
  } else {
    found = scroll(scroll_id=found$`_scroll_id`)
  }
  if (0==length(found$hits$hits)) {
    cat("Reached end")
    break
  }
  hits = as.vector(found$hits$hits)
  hits = hits[sapply(hits, function(x) !is.null(x$fields))]
  rows=t(sapply(hits, function(x) {
    ts = from_list(x$fields$timestamp, "timestamp")
    pl = from_list(x$fields$pledged, "pledged")
    return(list(timestamp=ts, pledged=pl))
  }))
  results = rbind(results, rows)
  first=FALSE
}
colnames(results) = c("timestamp", "pledged")
results$timestamp = as.character(results$timestamp)
results$pledged = as.numeric(as.character(results$pledged))
results$time = str2time(results$timestamp)

results$delta = c(NA, diff(results$pledged))
results = results[is.na(results$delta) | (results$delta!=0), ]
results$elapsed = c(NA, diff(results$time))

results = data.table(results)
results$interval = as.POSIXct(interval_s * ( 1+ as.numeric(results$time) %/% interval_s), origin = "1970-01-01")
aggs = results[, list(pledged=max(pledged), rate=sum(delta)/interval_d), by=interval]
aggs$sliding_rate = rollapply(aggs$rate, window_width, function(x) weighted.mean(x, weights))

results$continuous = results$elapsed<=60*60
results$category = ifelse(!is.na(results$continuous) & results$continuous, "continuous", "interrupted")

results$pledged_cont = results$pledged
breaks = results[results$category=="interrupted",]
breaks$pledged_cont = NA
results = rbind(results, breaks)
results = results[order(results$time, results$pledged_cont, na.last=FALSE),]

sg = c(15,25,35,45,55,60,70,75,85,90,100,
       110,120,130,140,150,170,180,200,
       220,240,260,270,280,290,300,
       310,320,330,335,345,355)*1000

g = ggplot(results, aes(x=time)) +
  geom_line(aes(y=pledged), linetype="dotted") +
  geom_line(aes(y=pledged_cont), linetype="solid") +
  geom_hline(yintercept=sg, size=0.5, alpha=0.2) +
  scale_y_continuous("pledged ($)", limits=c(0,NA), labels=function(x) format(x, big.mark="'", scientific=FALSE), breaks=pretty_breaks(n=8)) +
  #scale_y_continuous(pledged ($)", limits=c(0,NA), labels=function(x) sprintf("%.3f", x/1000), breaks=pretty_breaks(n=8)) +
  scale_x_datetime("date", limits=c(min(results$time), stop_time), minor_breaks=pretty_breaks(n=45))

print(g)

# g2 = ggplot(aggs, aes(x=interval)) +
#   geom_line(aes(y=pledged), linetype="solid") +
#   geom_hline(yintercept=sg, size=0.5, alpha=0.2) +
#   scale_y_continuous(limits=c(0,NA), labels=function(x) format(x, big.mark="'", scientific=FALSE), breaks=pretty_breaks(n=8)) +
#   scale_x_datetime("date", limits=c(min(results$time), stop_time), minor_breaks=pretty_breaks(n=45))
# 
# print(g2)

g3 = ggplot(aggs, aes(x=interval)) +
  geom_line(aes(y=rate, ymin=sliding_rate), linetype="dotted", size=0.5) +
  geom_line(aes(y=sliding_rate), linetype="solid") +
  geom_smooth(aes(y=sliding_rate)) +
  scale_y_continuous("rate ($/d)", limits=c(min(aggs$rate),75000), labels=function(x) format(x, big.mark="'", scientific=FALSE), breaks=pretty_breaks(n=8)) +
  scale_x_datetime("date", limits=c(min(results$time), stop_time2), minor_breaks=pretty_breaks(n=45))

print(g3)

cat(max(results$pledged))
