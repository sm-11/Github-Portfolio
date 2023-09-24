library(readxl)
library(tidyverse)
library(dplyr)
require(mosaic)
#library(GGally)
library(tidyr)

# uploading data
pi = read_excel("C:/Users/selam/Desktop/Pluralistic Ig_Data/PI & Sexist Attitudes Scale_February 21, 2023_09.12.xlsx")
length(pi$ResponseId)

view(pi)

##### DATA CLEANING #####

#checking the variables in the df
names(pi)

#deleting the 1st row(the questions) & the 2nd row(the preview survey)
df <- pi[-c(1,2),]

#checking the responses in the column
unique(df$Finished)

#separating the incomplete surveys 
Inc = df %>% filter(Finished==0)

#removing the incomplete surveys
df <- df[df$Finished !=0,]  

#removing columns where all the values are null
all_na <- function(x) any(!is.na(x))
df = df %>% select(where(all_na))

#cleaning up the df by removing irrelevant columns for the analyses
names(df)
drop <- c("StartDate", "EndDate", "Status", "Progress","Duration (in seconds)", "Finished", "RecordedDate", "LocationLatitude",
          "LocationLongitude", "DistributionChannel", "UserLanguage", "Informed_consent", "IPAddress")

df = df[,!(names(df) %in% drop)]

#counting the number of null values in each row
df$count_na <- rowSums(is.na(df[,]))

#removing rows if there are too many null values
df = df[df$count_na <= 5,]   
view(df)


##### DATA TRANSFORMATION ######

### transforming data format from wide to long

# gathering each scenario by the 3 views & matching them with their IDs
lg1 <- gather(df, "din_scen", "din_resp", dinner_scenario_1, dinner_scenario_2, dinner_scenario_3)
lg1 <- lg1[, c('ResponseId', 'din_scen', 'din_resp')]

lg2 <- gather(df, "pres_scen", "pres_resp", presentations_1, presentations_2, presentations_3)
lg2 <- lg2[, c('pres_scen', 'pres_resp')]

lg3 <- gather(df, "fb_scen", "fb_resp", football_invites_1, football_invites_2, football_invites_3)
lg3 <- lg3[, c('fb_scen', 'fb_resp')]

lg4 <- gather(df, "cowk_scen", "cowk_resp", coworkers_argument_1, coworkers_argument_2, coworkers_argument_3)
lg4 <- lg4[, c('cowk_scen', 'cowk_resp')]

lg5 <- gather(df, "stem_scen", "stem_resp", stem_discussion_1, stem_discussion_2, stem_discussion_3)
lg5 <- lg5[, c('stem_scen', 'stem_resp')]

lg6 <- gather(df, "eng_scen", "eng_resp", engineering_class_1, engineering_class_2, engineering_class_3)
lg6 <- lg6[, c('eng_scen', 'eng_resp')]

lg7 <- gather(df, "math_scen", "math_resp", math_tutoring_1, math_tutoring_2, math_tutoring_3)
lg7 <- lg7[, c('math_scen', 'math_resp')]

lg8 <- gather(df, "doc_scen", "doc_resp", "doctor's_visit_1", "doctor's_visit_2", "doctor's_visit_3")
lg8 <- lg8[, c('doc_scen', 'doc_resp')]

lg9 <- gather(df, "soc_scen", "soc_resp", soccer_highlights_1, soccer_highlights_2, soccer_highlights_3)
lg9 <- lg9[, c('soc_scen', 'soc_resp', 'gender', 'gender_3_TEXT', 'age', 'race', 'race_6_TEXT',
                'campus_residency', 'class_standing', 'follow-up_study', 'follow-up_study_1_TEXT')]

# df with both the scenario questions & the resposes
final_df <- bind_cols(lg1, lg2, lg3, lg4, lg5, lg6, lg7, lg8, lg9)
view(final_df)

# removing cols
main_df = subset(final_df, select = -c(pres_scen, fb_scen, cowk_scen, stem_scen, eng_scen, math_scen,
                                      doc_scen, soc_scen))

# labeling the view types clearly
main_df$din_scen <- ifelse(main_df$din_scen == "dinner_scenario_1","own views",
                        ifelse (main_df$din_scen == "dinner_scenario_2",
                          "avg MV", "avg FM"))
# sort df by Response_ID
main_df <- main_df[order(main_df$ResponseId),]

main_df$eng_resp <- ifelse(main_df$eng_resp == "26.0",5,main_df$eng_resp) 

# rename second column to target
colnames(main_df)[2] ="Target"

view(main_df)
###write.csv(main_df, "C:/Users/selam/Desktop/Pluralistic Ig_Data/incentives.csv", row.names=FALSE)


# Selecting columns 
ed_df = main_df %>% select(1:11)
view(ed_df)

# gathering the df into 4 columns
gathered_df <- gather(ed_df, "Scenarios", "Responses", din_resp, pres_resp, fb_resp, cowk_resp,
                      stem_resp, eng_resp, math_resp, doc_resp, soc_resp)

# sort df by Response_ID
gathered_df <- gathered_df[order(gathered_df$ResponseId),]
view(gathered_df)




## DATA ANALYSES

# checking data types
class(gathered_df$Responses)

# averaging the gathered data by grouping Response Id & Target
agg_df <- gathered_df %>% 
  group_by(ResponseId, Target) %>%
  summarise(scenario_avg = mean(as.numeric(Responses)))

view(agg_df)

# responses 
histogram(agg_df$scenario_avg)

# b/n subjects ANOVA
summary(aov(scenario_avg ~ Target + Error(ResponseId), data=agg_df))


####################

# gathering the df into 4 columns
gathered_ov <- gather(main_df, "Scenarios", "Responses", din_resp, pres_resp, fb_resp, cowk_resp,
                      stem_resp, eng_resp, math_resp, doc_resp, soc_resp)
view(gathered_ov)

# df from own views only
ov_df <- gathered_ov[gathered_ov$Target == "own views",]

# excluding gender = prefer not to say
ov_df <- ov_df[!ov_df$gender == "4.0",]

# excluding gender = other
ov_df <- ov_df[!ov_df$gender == "3.0",]

# excluding race = prefer not to say
#ov_df <- ov_df[!ov_df$race == "5",]

# excluding race = other
#ov_df <- ov_df[!ov_df$race == "6",]

# excluding 
ov_df <- ov_df[!ov_df$class_standing == "3.0",]

view(ov_df)

# aggregating the ov_df by grouping Response Id & Target
ov_agg <- ov_df %>% 
  group_by(ResponseId) %>%
  mutate(scenario_avg = mean(as.numeric(Responses)))

# selecting distinct rows in df based on response id
ov_agg <- ov_agg %>% distinct(ResponseId, .keep_all = TRUE)

# removing cols
ov_agg <- subset(ov_agg, select = -c(Scenarios, Responses, Target))

# rearranging cols
ov_agg <- ov_agg %>% relocate(scenario_avg, .before = gender)

# averaging the gathered data by grouping Response Id & Target
gender_df <- ov_df %>% 
  group_by(ResponseId, gender, class_standing, campus_residency, age, race) %>%
  summarise(scenario_avg = mean(as.numeric(Responses)))

view(gender_df)



######
### Graphs relevant for Sexist Attitudes

# labels for gender axis
label=c("Man", "Woman","Non-binary")

# sexist attitudes by gender
boxplot(scenario_avg~gender, data=gender_df, col=(c("blue", "red", "lightblue",
                                                    "lightblue", "lightblue")),
        main="Sexist Attitudes by Gender", xlab="Gender", ylab="Responses", names=label)


# labels for race axis
label_r=c("Asian", "Black", "Black&White", "Hispanic", "White", "White&Hispanic")

# sexist attitudes by race
boxplot(scenario_avg~race, data=gender_df, names=label_r,
        main="Sexist Attitudes by Race", xlab="Race", ylab="Responses")


# labels for class standing
label_cl=c("Freshman", "Transfer Student")

# sexist attitudes by class standing
boxplot(scenario_avg~class_standing, data=gender_df, names=label_cl,
        main="Sexist Attitudes by Class Standing", xlab="Class standing", ylab="Responses")



######
### Graphs relevant for Pluralistic Ig

# gathering the df into 4 columns
pi_df <- gather(main_df, "Scenarios", "Responses", din_resp, pres_resp, fb_resp, cowk_resp,
                      stem_resp, eng_resp, math_resp, doc_resp, soc_resp)
view(pi_df)

# excluding gender = prefer not to say
av_df <- pi_df[!pi_df$gender == "4.0",]

# excluding gender = other
av_df <- av_df[!av_df$gender == "3.0",]

# excluding race = prefer not to say
#av_df <- av_df[!av_df$race == "5",]

# excluding race = other
#av_df <- av_df[!av_df$race == "6",]

# excluding class standing = other
av_df <- av_df[!av_df$class_standing == "3.0",]
view(av_df)


# averaging the gathered data by grouping Response Id & Target
df_pi <- av_df %>% 
  group_by(ResponseId, Target, gender, class_standing, campus_residency, age, race) %>%
  summarise(scenario_avg = mean(as.numeric(Responses)))

view(df_pi)

#write.csv(df_pi, "C:/Users/selam/Desktop/Pluralistic Ig_Data/overallViews.csv", row.names=FALSE)
#write.csv(gender_df, "C:/Users/selam/Desktop/Pluralistic Ig_Data/ownViews_df.csv", row.names=FALSE)


# PI by target views
boxplot(scenario_avg~Target, data=df_pi, 
        main="PI by Views", xlab="Target", ylab="Responses")


# PI by gender
p <- ggplot(df_grouped, aes(fill=gender, y=scenario_avg, x=Target)) +
  geom_bar(position='dodge', stat='identity') +
  ggtitle("Pluralistic Ignorance across Gender")+
  theme(plot.title = element_text(size=15, face = "bold", hjust = 0.5))+
  ylab('Responses')+
  xlab('Target')

# Edit legend title and labels
p + scale_fill_discrete(name = "Gender", labels = c("Man", "Woman", "Non-Binary")
                        )


df_pi %>% ungroup() %>% select(ResponseId, gender) %>% distinct() %>% count(gender)


df_grouped <- df_pi %>% 
  group_by(Target, gender) %>%
  summarise(scenario_avg = mean(scenario_avg))

view(df_grouped)
#write.csv(df_grouped, "C:/Users/selam/Desktop/Pluralistic Ig_Data/grouped_scenarios.csv", row.names=FALSE)



########## Sexist Attitudes ##########
## t-test
mn = mean(gender_df$scenario_avg)
mean_scn <-rep(mn,times=length(gender_df$scenario_avg))

##
t.test(gender_df$scenario_avg, mu=mean(gender_df$scenario_avg))


# b/n subjects ANOVA
summary(aov(scenario_avg ~ gender + Error(ResponseId),data=gender_df))


###################
# average mean for both males & females
mean(s_attitudes$scenario_avg)
#mu = mean(s_attitudes$scenario_avg)

# setting the mean value to 3 since in scale 3 is neither appropirate nor inappropirate', 
#thus it can be a midpoint to indicate participants sexist attitudes.
     
