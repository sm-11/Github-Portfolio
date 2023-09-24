library(readxl)
library(tidyverse)
library(dplyr)
require(mosaic)
library(ggpubr)
library(Hmisc) # descriptive stats
library(plyr)



df_A = read_csv("C:/Users/selam/Desktop/Project 2-3A.csv")
head(df_A)

df_B = read_excel("C:/Users/selam/Desktop/Project 2-3B.xlsx")
head(df_B)


# getting the variables in dataframe A
names(df_A)

# selecting variables of interest
Df_A = data.frame(df_A$HorzBreak, df_A$ExitSpeed)
view(Df_A)

# descriptive stats for dataframe A
describe(Df_A)
summary(Df_A)




# descriptive stats
sapply(Df_A, count)
sapply(Df_A, mean)
sapply(Df_A, sd)


# total n
nrow(Df_A)

# df for HorzBreak less than 2
Horless2 = Df_A %>% filter(Df_A$df_A.HorzBreak < 2)
Horless2

# n for HorzBreak less than 2
n1 = count(Horless2)
nrow(n1)

# standard dev. for HorzBreak less than 2
sd1 = sd(Horless2$df_A.HorzBreak)
sd1

# mean for HorzBreak less than 2
y1 = mean(Horless2$df_A.HorzBreak)
y1


# df for HorzBreak greater than 2
horzGreater2 = Df_A %>% filter(Df_A$df_A.HorzBreak > 2)
horzGreater2

# n for HorzBreak greater than 2
n2 = nrow(horzGreater2)
n2

# standard dev. for HorzBreak greater than 2
sd2 = sd(horzGreater2$df_A.HorzBreak)
sd2

# mean for HorzBreak greater than 2
y2 = mean(horzGreater2$df_A.HorzBreak)
y2


#
# create matrix with 4 columns and 4 rows
final_df = matrix(c(n1, n2, y1, y2, sd1, sd2), ncol=3, byrow=TRUE)
final_df

# specify the column names and row names of matrix
colnames(final_df) = c('N','Mean','St.deviation')
rownames(final_df) <- c('HorzBreak less than 2','HorzBreak greater than 2')

# assign to table
final = as.table(final_df)

# display
final

final_df =  data.frame(n = c(n1, n2),
                  Mean = c(y1, y2),
                  Std = c(sd1, sd2)
)

final_df


## combining dfs for HorzBreak less than 2 & greater than 2
combined = rbind.fill(Horless2[c("df_A.HorzBreak", "df_A.ExitSpeed")], 
                      horzGreater2[c("df_A.HorzBreak", "df_A.ExitSpeed")])

combined

# output csv file for combined df
write.csv(combined,"C:/Users/selam/Desktop/output.csv", row.names = FALSE)

