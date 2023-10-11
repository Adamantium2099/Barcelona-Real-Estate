# Barcelona-Real-Estate
Project for Applied Probability and Statistics

The data file BarcelonaRE_Data consists of 11 variables of our initial interest, including "City Zone", "m^2", "Rooms", "Bathrooms", "Elevator", "Atico", "Terrasse", "Parking", "Kitchen", "Type", and "Yard". With these elements serving as independent/explanatory variables, we leverage them in our attempt to predict our dependent/response variable e "Price".
Only using the simple linear model (all variables) without any advanced modification, we can obtain quite a predictive capability as evidenced by the statistical metrics:

Multiple R-squared: 0.8316 Adjusted R-squared: 0.8235 Correlation: 0.9119

While the model seems to be sufficiently veracious indicating a linear link between variables and estates’ price, the p values for some of the variables are too large. We are interested to see what additional adjustments to the design can offer.
In the simplest model above, we found that the p value for Rooms, Elevator, Terrasse, and Type are greater than 0.1. To improve this, we first eliminated these four variables and got model 1. Although all variables’ p-value looked valid, the R^2 decreased slightly which was not what we wanted. To better isolate the effect of these four variables, we added interaction terms: Terrasse*`m^2` + Elevator*`m^2` + Rooms*`m^2` + Type*`m^2` to model 1. Now Model 2 has achieved a higher R^2 of 0.8427. Every variable seems to be significant except for Room and `m^2`: Rooms. We realized that the number of rooms is somehow correlated to m^2. Therefore, we decided to completely eliminate the variable Room and its interaction as well in modeling. Model 3 gave us Multiple R-squared: 0.8423, Adjusted R-squared: 0.8338, plus acceptable p values. Better performance than all above.
In Model 4 and 5, we were trying to add or drop some interaction terms or some city zones that were not significant throughout. However, there was barely a change in p values and entire model performance. We are determined to wrap up our analysis and prediction with Model 3.
