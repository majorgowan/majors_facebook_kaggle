# compute indices of K nearest neighbours
# input data must be matrix or data frame
# with res columns of independent variables
# and integer-valued class in column res+1

# calculate difference between two vectors
# if moddim
modDiff <- function(x,data,clockdim=NULL) {
    d <- data-x
    if (!is.null(clockdim)) {
        if (is.null(dim(data))) {
            dd <- d %% clockdim[2]
            d <- 2 * (pmin(dd, abs(dd-clockdim[2]))) / sqrt(clockdim[2])
        } else {
            dd <- d[,clockdim[1]] %% clockdim[2]
            d[,clockdim[1]] <- 2 * (pmin(dd, 
                                         abs(dd-clockdim[2]))) / sqrt(clockdim[2])
        }
    }
    return(d)
}

knn_list <- function(x,data,classes,K,clockdim=NULL) {
  # compute distance of test row to each row
  # in data using sweep function
  # default sweep operation is "subtract vector"
  # vector always interpreted as column vector, so
  # transpose to apply to rows of "data"
  if (is.null(dim(data))) {
      distance <- (modDiff(x,data,clockdim=clockdim))^2
  } else {
      distance  <- rowSums(sweep(data,
                                 2,
                                 t(x),
                                 FUN=modDiff,
                                 clockdim=clockdim
                          )^2)
  }
  # consider the classes of the K nearest 
  # neighbours (order rows by distance)
  if (is.null(dim(data))) {
      df <- data.frame((data[order(distance)])[1:K])
  } else {
      df <- data.frame((data[order(distance),])[1:K,])
  }
  df$distance <- sort(distance)[1:K]
  df$class <- (classes[order(distance)])[1:K]
  return(df)
  # use tabulate to sort pure integers
  # (alternative table uses tabulate plus
  # overhead to handle arbitrary data types)
  ######return(which.max(tabulate(classes+1))-1)
}

knn_leave_one_out <- function(ind,data,classes,K,clockdim=NULL) {
    if (is.null(dim(data))) {
        x <- data[ind]
        traindata <- data[-ind]
    } else {
        x <- data[ind,]
        traindata <- data[-ind,]
    }
    return(knn_list(x,traindata,classes[-ind],K,clockdim=NULL))
}

knn_in_Top3 <- function(ind,data,classes,K,clockdim=NULL,verbose=FALSE) {
    candidates <- knn_leave_one_out(ind,data,classes,K,clockdim=clockdim)
    top3 <- names(sort(table(candidates$class),decreasing=TRUE))[1:3]
    if (verbose) {
        print(paste(c(classes[ind] %in% top3, top3, '...', classes[ind]),collapse=" "))
    }
    return (classes[ind] %in% top3)
}

knn_test <- function(inds,data,classes,K,clockdim=NULL,verbose=FALSE) {
    accuracy <- 
        apply(array(inds),1,
              knn_in_Top3,data=data,classes=classes,K=K,clockdim=clockdim,verbose=verbose)
    return(accuracy)
}

# example:
# classify first 100 check-ins
#     pred <- knn_test(1:100,training[1:200000,c("xs","ys")],training[1:200000,6],K=20,verbose=TRUE))
#
# table(pred)
