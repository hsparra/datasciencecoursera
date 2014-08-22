#
compDailyCost <- function(x, c, kwh.price = 0.12, gas.price = 3.50) {
  cost <- 0
  if (x$Type == "EV") {
    cost <- c * x$Kwh.100mi.Combined/100 * kwh.price
  } else {
    if (c <= x$Range) {
      cost <- c * x$Kwh.100mi.Combined/100 * kwh.price
    } else {
      cost <- (x$Range * x$Kwh.100mi.Combined/100 * kwh.price) + 
        ((c-x$Range)/x$MPG.Combined.Gas * gas.price)
    }
  }
  cost
}