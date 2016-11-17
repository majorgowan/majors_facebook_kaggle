training <- read.csv('../Data/train_short.csv')

# assuming time is in units of 1000ths of day
training$day <- training$time / 1000

print('Computing scale factors for x and y . . . ')
# std for x and y values for places with "many" check-ins
ptab <- sort(table(training$place_id),decreasing=TRUE)
over100 <- subset(training, place_id %in% names(ptab[ptab>100]))
xscale <- mean(tapply(over100$x, over100$place_id, sd)) 
yscale <- mean(tapply(over100$y, over100$place_id, sd))
print(paste('xscale, yscale:',xscale,yscale))

print('rescaling x and y . . . ')
training$xs <- training$x/xscale
training$ys <- training$y/yscale
