#Initialize urls, filenames etc.
library(reshape2)
fname <- "getdata_dataset.zip"
fname2 <- "UCI HAR Dataset"
activity_table <- "UCI HAR Dataset/activity_labels.txt"
feature_table <- "UCI HAR Dataset/features.txt"
X_train <- "UCI HAR Dataset/train/X_train.txt"
Y_train <- "UCI HAR Dataset/train/Y_train.txt"
subject_train <- "UCI HAR Dataset/train/subject_train.txt"
X_test <- "UCI HAR Dataset/test/X_test.txt"
Y_test <- "UCI HAR Dataset/test/Y_test.txt"
subject_test <- "UCI HAR Dataset/test/subject_test.txt"
f_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "

#Get file and tables
if (!file.exists(fname)){
  download.file(f_url, fname, method="curl")
}  
if (!file.exists(fname2)) { 
  unzip(fname) 
}
act_label <- read.table(activity_table)
act_label[,2] <- as.character(act_label[,2])
features <- read.table(feature_table)
features[,2] <- as.character(features[,2])

# Mean and SD
ft_req <- grep(".*mean.*|.*std.*", features[,2])
ft_req.names <- features[ft_req,2]
ft_req.names = gsub('-mean', 'Mean', ft_req.names)
ft_req.names = gsub('-std', 'Std', ft_req.names)
ft_req.names <- gsub('[-()]', '', ft_req.names)

# Training sets
train <- read.table(X_train)[ft_req]
act_train <- read.table(Y_train)
sub_train <- read.table(subject_train)
train <- cbind(sub_train, act_train, train)

# Testing sets
test <- read.table(X_test)[ft_req]
act_test <- read.table(Y_test)
sub_test <- read.table(subject_test)
test <- cbind(sub_test, act_test, test)

# merging
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", ft_req.names)
allData$activity <- factor(allData$activity, levels = act_label[,1], labels = act_label[,2])
allData$subject <- as.factor(allData$subject)
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# Write to text file
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
