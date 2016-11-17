ptab <- sort(table(training$place_id),decreasing=TRUE)
pop01 <- subset(training,place_id==names(which.max(ptab)))
#plot(pop01$x,pop01$y,cex=0.01*pop01$accuracy)

# 10 most popular check-in locations
pop10 <- subset(training, place_id %in% names(ptab)[1:10])

# plot check-in locations of 10 most popular
dev.new()
par(mar=c(5.1, 4.1, 4.1, 10.1), xpd=TRUE)
plot(pop10$x,pop10$y, 
     cex=0.004*pop10$accuracy, 
     col=as.factor(pop10$place_id))
legend('right',inset=c(-0.3,0),
       legend=levels(as.factor(pop10$place_id)),
       pch=1,col=factor(pop10$place_id),cex=0.9)

