train <- read.csv("pendigits.tra.csv",header = FALSE)
test  <- read.csv("pendigits.tes.csv",header = FALSE)

# compute indices of K nearest neighbours
# input data must be matrix or data frame
# with res columns of independent variables
# and integer-valued class in column res+1
knn_classify <- function(x,data,K,res=16) {
  # compute distance of test row to each row
  # in data using sweep function
  # default sweep operation is "subtract vector"
  # vector always interpreted as column vector, so
  # transpose to apply to rows of "data"
  distance  <- rowSums((sweep(data[,1:res],
                              2,
                              t(x[1:res]))^2
                        ))
  # consider the classes of the K nearest 
  # neighbours (order rows by distance)
  classes <- (data[order(distance),res+1])[1:K]
  # use tabulate to sort pure integers
  # (alternative table uses tabulate plus
  # overhead to handle arbitrary data types)
  return(which.max(tabulate(classes+1))-1)
}

# example:
# classify first 100 test digits with K=5
# pred <- apply(test[1:100,],
#              1,
#              knn_classify,data=train,K=5,res=16))
#
# table(pred,test[1:100,17])