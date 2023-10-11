'''
Team 51 Code (section C)  

Lakshman Balaji, lb463 
Evelyn Bian, cb618 
Fei (Adam) Cheng, fc143 
Caiqing Xie, cx88 
Ellen (Ruoxian) Xu, rx33 
'''
# Install and load the readxl package
install.packages("readxl")
install.packages("openxlsx")
library(openxlsx)
library(readxl)
library(dplyr)
library(ggplot2)

# Set the working directory, please edit this to your own folder
setwd("C:/users/Adamantium2099/Documents/Duke University/Applied Probability & Statistics")

# Read data from the Excel file, specifying the sheet and range
BarcelonaData <- read_excel("BarcelonaRE_Data.xlsx", sheet = "413 properties for analysis", range = "A1:M414")
View(BarcelonaData)

# Get the column names
column_names <- colnames(BarcelonaData)
print(column_names)

# Rename using names() function
names(BarcelonaData)[names(BarcelonaData) == "Price             [euros]"] <- "Price"


# Get the total number of columns
total_columns <- ncol(BarcelonaData)
cat("Total number of columns:", total_columns, "\n")

# Get the total number of rows
total_rows <- nrow(BarcelonaData)
cat("Total number of rows:", total_rows, "\n")

# Check for missing data
sum(is.na(BarcelonaData))
# 0 missing data nice

# Summary statistics
summary(BarcelonaData)

# Get unique values and their counts for 'City Zone' from BarcelonaData
city_zone_counts <- table(BarcelonaData$`City Zone`)

# Print the results
print(city_zone_counts)


'''
Q1 Linear (referring as Model 1 in the report, check further below for our final Model, Model 3)
'''
# Fit the model
model <- lm(Price ~ `City Zone` + `m^2` + Rooms + Bathrooms + Elevator + `"Atico"` + Terrasse + Parking + Kitchen + Type + Yard, data = BarcelonaData)

# Print the summary of the model
summary(model)

# Calculate the predicted prices
BarcelonaData$Predicted_Price <- predict(model, newdata = BarcelonaData)

# Now create the plot
p <- ggplot(BarcelonaData, aes(x = Price, y = Predicted_Price)) + 
  geom_point(aes(color = `City Zone`), alpha = 0.6) +  # Color points by 'City Zone'
  geom_smooth(method = 'lm', color = 'red') +          # Add a linear regression line
  ggtitle("Actual vs Predicted Prices") +
  xlab("Actual Price") +
  ylab("Predicted Price") +
  theme_minimal()

print(p)

# Load the '200 properties to be priced' data
PriceSubmissionData <- read_excel("BarcelonaRE_Data.xlsx", sheet = "200 properties to be priced")

# Predict prices using the model for this new data
PriceSubmissionData$Predicted_Price <- predict(model, newdata = PriceSubmissionData)

# Load the workbook
wb <- loadWorkbook("BarcelonaRE_Data.xlsx")

# Add a new sheet and write the new data
addWorksheet(wb, "Predicted Prices")
writeData(wb, sheet = "Predicted Prices", PriceSubmissionData)

# Save the workbook
saveWorkbook(wb, "BarcelonaRE_Data.xlsx", overwrite = TRUE)

# Create the plot for M^2 vs predicted price of the "200 properties to be priced" data.
p <- ggplot(PriceSubmissionData, aes(x = `m^2`, y = Predicted_Price)) + 
  geom_point(aes(color = `City Zone`), alpha = 0.6) +  # Color points by 'City Zone'
  geom_smooth(method = 'lm', color = 'red') +          # Add a linear regression line
  ggtitle("m^2 vs Predicted Prices for 200 Properties") +
  xlab("m^2 (Square Meters)") +
  ylab("Predicted Price") +
  theme_minimal()

print(p)



'''
Q1 Correlation against Price
'''

# Exclude the columns '...1', 'Price', and 'City Zone'
numeric_data <- BarcelonaData[, !names(BarcelonaData) %in% c('...1', 'Price', 'City Zone')]

# Compute correlations for the numeric columns
correlations <- sapply(numeric_data, function(x) cor(BarcelonaData$Price, x, use = "complete.obs"))

# Sort the correlations in decreasing order
sorted_correlations <- sort(correlations, decreasing = TRUE)

# Print the sorted correlations
print(sorted_correlations)


'''
Q1 Corr among all
'''
# Using the previously defined numeric_data

# Compute the correlation matrix
cor_matrix <- cor(numeric_data, use = "complete.obs")

# Print the correlation matrix
print(cor_matrix)

# Optionally, you can visualize this matrix using the corrplot library for better interpretation
if(!require(corrplot)){
  install.packages("corrplot")
}

library(corrplot)

corrplot(cor_matrix, method = "circle", type = "upper", order = "hclust")

'''
Q1 Model 1.1. referring to Model 3 on the report. THIS IS OUR FINAL MODEL.
'''
model1.1 <- lm(Price ~ `City Zone` + `m^2` + Bathrooms + Elevator + 
               `"Atico"` + Terrasse + Parking + Kitchen + Type + Yard + 
                 Terrasse*`m^2` + Elevator*`m^2` + Type*`m^2`, data = BarcelonaData)
summary(model1.1)

library(ggplot2)
library(scales)

p <- ggplot(BarcelonaData, aes(x = Price, y = predicted_prices)) + 
  geom_point(aes(color = color), alpha = 0.6) +
  geom_smooth(method = 'lm', se = TRUE, color = "black", fill = "grey50", alpha = 0.4) +
  scale_color_identity() +
  ggtitle("Actual vs Predicted Prices in thousands with Elevator and Type Highlighted") +
  xlab("Actual Price (thousands)") +
  ylab("Predicted Price (thousands)") +
  scale_x_continuous(labels = dollar_format(scale = .001, prefix = "$", big.mark = ",")) + # Format X-axis
  scale_y_continuous(labels = dollar_format(scale = .001, prefix = "$", big.mark = ",")) + # Format Y-axis
  theme_minimal() +
  theme(axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"))

print(p)

'''
Q1 Model 3 Final M^2 vs Predicted Price
'''
library(readxl)

# Load the data
PriceSubmissionData_new <- read_excel("PriceSubmission.xlsx")

PriceSubmissionData_new$predicted_prices <- predict(model1.1, newdata = PriceSubmissionData_new)


# Adjusting color variable to a factor
PriceSubmissionData_new$color <- factor(
  case_when(
    PriceSubmissionData_new$Elevator == 1 & PriceSubmissionData_new$Type == 1 ~ "Both Elevator and Type",
    PriceSubmissionData_new$Elevator == 1 ~ "Elevator Only",
    PriceSubmissionData_new$Type == 1 ~ "Type Only",
    TRUE ~ "Neither"
  )
)

# Plotting
p <- ggplot(PriceSubmissionData_new, aes(x = `m^2`, y = predicted_prices)) + 
  geom_point(aes(color = color), alpha = 0.6) +
  geom_smooth(method = 'lm', se = TRUE, color = "black", fill = "grey50", alpha = 0.4) +
  scale_color_manual(name = "Property Type",
                     values = c("Both Elevator and Type" = "blue", 
                                "Elevator Only" = "red", 
                                "Type Only" = "green", 
                                "Neither" = "grey")) +
  ggtitle("m^2 vs Predicted Prices (thousands) with Elevator and Type Highlighted") +
  xlab("m^2") +
  ylab("Predicted Price (thousands)") +
  scale_y_continuous(labels = scales::dollar_format(scale = .001, prefix = "$", big.mark = ",")) + # Format Y-axis
  scale_x_continuous(breaks = seq(min(PriceSubmissionData_new$`m^2`), max(PriceSubmissionData_new$`m^2`), by = 50))
  theme_minimal() +
  theme(
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold"),
    axis.text.x = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12)
  )

print(p)

# Load the workbook
wb <- loadWorkbook("PriceSubmission.xlsx")

# Write the predicted prices into the desired cells (from B2 to B201)
writeData(wb, sheet = 1, x = PriceSubmissionData_new$predicted_prices, startCol = 2, startRow = 2, colNames = FALSE)

# Save the changes
saveWorkbook(wb, "PriceSubmission_updated.xlsx", overwrite = TRUE)

BarcelonaData$residuals <- residuals(model1.1)

ggplot(BarcelonaData, aes(x = `m^2`, y = residuals)) + 
  geom_point(color = "blue", alpha = 0.6) + 
  geom_hline(yintercept = 0, linetype="dashed", color = "red") +  # This line represents where residuals = 0
  ggtitle("Residuals vs m^2") +
  xlab("m^2") +
  ylab("Residuals") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12)
  )

'''
Q1 Model1.1 Car, referring to Model 3 on the report. Additional Plots just for fun.
'''

library(car)
plot(model1.1, which=1)

plot(model1.1, which=2)

plot(model1.1, which=3)

plot(model1.1, which=5)

crPlots(model1.1)

avPlots(model1.1)

conditionPlot(model1.1)
