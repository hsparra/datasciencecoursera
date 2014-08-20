d <- read.csv("electric_cars_addl.csv",header=T,stringsAsFactor=F)
d <- subset(d, year > 2009, select = -c(orig.row, id, trans, cyl, displ, fuel))
d$class <- factor(el3$class, levels = c("Two Seaters", "Minicompact","Subcompact","Compact","Midsize","Large","Small SUV","SUV"))
d$year <- factor(d$year)

d2 <- subset(d, make != "Azure Dynamics" & make != "CODA Automotive")
d2 <- subset(d2, model != "Model S" & model != "Model S (40 kW-hr)")

library(ggplot2)
qplot(x=mi.per.kwh, y=interior.volume, data=subset(d2, !is.na(d2$interior.volume)))
ggplot(subset(d2, !is.na(d2$interior.volume)), aes(x=interior.volume, y=mi.per.kwh)) + geom_point(aes(color=make), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))

ggplot(subset(d2, !is.na(d2$interior.volume)), aes(x=interior.volume, y=mi.per.kwh)) + geom_point(aes(color=year), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))
ggplot(subset(d2, !is.na(d2$interior.volume)), aes(x=lbs, y=mi.per.kwh)) + geom_point(aes(color=year), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))
ggplot(subset(d2, !is.na(d2$interior.volume)), aes(x=lbs, y=kwh.p.100mi)) + geom_point(aes(color=year), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))
ggplot(subset(d2, !is.na(d2$interior.volume)), aes(x=lbs, y=kwh.t)) + geom_point(aes(color=year), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))
# Cost per mi
ggplot(subset(d2, !is.na(msrp)), aes(x=msrp, y=range)) + geom_point(aes(color=year), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))
line <- lm(kwh.t ~ msrp, data=d2)
a <- coef(line)[1]
b <- coef(line)[2]
ggplot(subset(d2, !is.na(msrp)), aes(x=msrp, y=kwh.t)) + geom_point(aes(color=year), size=3) + 
    geom_text(aes(vjust=-1, label=model, size=.5))   # + geom_smooth() + geom_abline(intercept=a, slope=b)


ggplot(subset(d2, !is.na(d2$interior.volume)), aes(x=interior.volume, y=mi.per.kwh)) + geom_point(aes(color=make), size=3) + geom_text(aes(vjust=-2, label=model, size=.5)) + geom_smooth()

ggplot(d2, aes(x=lbs, y=mi.per.kwh)) + geom_point(aes(color=make), size=3) + geom_text(aes(vjust=-2, label=model, size=.5)) + geom_smooth()
ggplot(d2, aes(x=lbs, y=kwh.p.100mi)) + geom_point(aes(color=make), size=3) + geom_text(aes(vjust=-2, label=model, size=.5)) + geom_smooth()

ggplot(d2, aes(x=year, y=mi.per.kwh, colour=make)) + geom_point() + geom_text(aes(label=model)) + geom_smooth()

lm1 <- lm(mi.per.kwh ~ lbs + range + kwh.t, data=d2)
lm2 <- lm(range ~ kwh.t, data=d2)