ptab <- sort(table(training$place_id),decreasing=TRUE)
more30 <- subset(training, place_id %in% names(ptab[ptab>30]))

# ranges
#minnieMouseX <- tapply(more30$x, more30$place_id, max) - 
#                tapply(more30$x, more30$place_id, min)
#minnieMouseY <- tapply(more30$y, more30$place_id, max) - 
#                tapply(more30$y, more30$place_id, min)

# standard-dev
minnieMouseX <- tapply(more30$x, more30$place_id, sd) 
minnieMouseY <- tapply(more30$y, more30$place_id, sd) 

dev.new()
hist(minnieMouseX,breaks=c(seq(0,5,by=0.5),by=0.5),
     main='Histogram of x-ranges of 30 most popular places',
     xlab='xrange')

dev.new()
hist(minnieMouseY,breaks=c(seq(0,0.5,by=0.025),max(minnieMouseY)),
     xlim=c(0,1), main='Histogram of y-ranges of 30 most popular places',
     xlab='yrange')



