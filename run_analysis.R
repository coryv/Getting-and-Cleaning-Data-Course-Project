#Load necessary libraries
library(dplyr)
library(data.table)

#read in data
subjectTest <- read.table('./test/subject_test.txt', col.names = 'subjectID')
subjectTrain <- read.table('./train/subject_train.txt', col.names = 'subjectID')
xTest <- read.table('./test/X_test.txt')
xTrain <- read.table('./train/X_train.txt')
yTest <- read.table('./test/y_test.txt', col.names = 'activityID')
yTrain <- read.table('./train/y_train.txt', col.names = 'activityID')
features <- read.table('features.txt')
activityLables <- read.table('activity_labels.txt', col.names = c('activityID', 'activityName'))

#rename columns in X data
colnames(xTest) <- features$V2
colnames(xTrain) <- features$V2
  
#Merge the training and the test sets to create one data set.
combinedData <- rbind(cbind(subjectTest, yTest, xTest), cbind(subjectTrain, yTrain, xTrain))

#Extract only the measurements on the mean and standard deviation for each measurement.
reducedData <- combinedData[c(1,2,grep('mean\\(\\)',colnames(combinedData)), grep('std\\(\\)',colnames(combinedData)))]

#Uses descriptive activity names to name the activities in the data set
activityLabeledData <- inner_join(reducedData, activityLables, by = 'activityID')
activityLabeledData <- activityLabeledData[c(1,2,69,3:68)]

#Appropriately label the data set with descriptive variable names.
colnames(activityLabeledData) <- gsub('^t', 'Time from ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('^f', 'Fast Fourier Transformed from ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Acc', 'Accelerometer Acceleration Signal ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Jerk', 'Jerk ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Mag', 'Magnitude ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Gyro', 'Gyroscope Acceleration Signal ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Body', 'Body ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Body Body ', 'Body ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('Gravity', 'Gravity ', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('-mean\\(\\)', 'Mean', colnames(activityLabeledData))
colnames(activityLabeledData) <- gsub('-std\\(\\)', 'Standard Deviation', colnames(activityLabeledData))

#From the data set, create a second, independent tidy data set with the average of each variable for each activity and each subject.
summaryData <- group_by(activityLabeledData, subjectID, activityID, activityName)
tidyData <- summarise_each(summaryData, funs(mean))
write.table(tidyData, "tidyData.txt", row.names = FALSE)