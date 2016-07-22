####Run Analysis

###Download, move and load the data

getwd()

library(reshape2)

#Download and unzip the data
UCIHARZipFile <- "GetData_UCIHARDataSet.zip"

if(!file.exists(UCIHARZipFile)) {
        URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(URL, UCIHARZipFile, method = "curl")
}
if(!file.exists("UCI HAR Dataset")) {
        unzip(UCIHARZipFile)
}


#Load data for activity-labels and features
ActivityLabels <- read.table("/Users/jonathan.mcnulty/Downloads/UCIHARDataset/activity_labels.txt")
ActivityLabels[, 2] <- as.character(ActivityLabels[, 2])
class(ActivityLabels)
class(ActivityLabels[, 2])
Features <- read.table("/Users/jonathan.mcnulty/Downloads/UCIHARDataset/features.txt")
Features[, 2] <- as.character(Features[, 2])
class(Features)
class(Features[, 2])


#Extract the data for means and standard deviations

FeaturesStdDevMean <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesStdDevMean.names <- Features[FeaturesStdDevMean, 2]
FeaturesStdDevMean.names <- gsub('-mean', 'Mean', FeaturesStdDevMean.names)
FeaturesStdDevMean.names <- gsub('-std', 'Std', FeaturesStdDevMean.names)
FeaturesStdDevMean.names <- gsub('[-()]', '', FeaturesStdDevMean.names)


#Load the data sets

train <- read.table("UCIHARDataset/train/X_train.txt")[FeaturesStdDevMean]
TrainActivity <- read.table("UCIHARDataset/train/Y_train.txt")
TrainSubjects <- read.table("UCIHARDataset/train/subject_train.txt")
Train <- cbind(TrainActivity, TrainSubjects, train)

test <- read.table("UCIHARDataset/test/X_test.txt")[FeaturesStdDevMean]
TestActivity <- read.table("UCIHARDataset/test/Y_test.txt")
TestSubjects <- read.table("UCIHARDataset/test/subject_test.txt")
Test <- cbind(TestActivity, TestSubjects, test)


#Merge/combine the two data sets and add labels

TotalData <- rbind(Train, Test)
colnames(TotalData) <- c("Subject", "Activity", FeaturesStdDevMean.names)


#Transform subjects and activity into factor-variables

TotalData$Activity <- factor(TotalData$Activity, levels = ActivityLabels[, 1], labels = ActivityLabels[, 2])
TotalData$Subject <- as.factor(TotalData$Subject)

MeltedTotalData <- melt(TotalData, id = c("Subject", "Activity"))
MeanMeltedTotalData <- dcast(MeltedTotalData, Subject + Activity + FeaturesStdDevMean.names ~ variable, mean)

write.table(MeanMeltedTotalData, "TidyData.txt", row.names = FALSE, quote = FALSE)

library(data.table)
TidyData <- read.table("TidyData.txt", header = TRUE) #Perfect! 

