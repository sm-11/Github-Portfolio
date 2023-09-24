require(ggpattern)
library(tidyverse)
library(tidyr)
library(ggplot2)
library(emmeans)
library(ggpubr)
library(gtable)
library(gridExtra)
library(cowplot)
library(grid)

#### Import and wrangle data into wide format ####
cleanedRaw_df = read_csv("C:/Users/selam/Desktop/Pluralistic Ig_Data/overallViews.csv")

pl_wide <- cleanedRaw_df %>%
  # Move scenario response to wide format:
  spread(key = Target, value = scenario_avg) %>%
  rename(avg_f = 'avg FM', avg_m = 'avg MV', own_views = 'own views') %>%
  # Get rid of unnecessary columns:
  select(ResponseId, gender, avg_f, avg_m, own_views) %>%
  # Set gender as factor
  mutate(gender = factor(gender, levels = c(1,2,5), labels = c('Male', 'Female', 'Other'))) %>%
  # Only want to analyze male and female participants
  filter(gender != 'Other') 
head(pl_wide)
count(pl_wide, gender)

#### Calculate means for "actual" perceptions ####
male_actual <- mean(filter(pl_wide, gender == 'Male')$own_views)
female_actual <- mean(filter(pl_wide, gender == 'Female')$own_views)


#### Calculate Pluralistic Ignorance as Individual Difference 
# (difference between perception and reality)
pl_wide <- pl_wide %>% 
  mutate(PI_m = avg_m - male_actual,
         PI_f = avg_f - female_actual, 
         PI_all = PI_m + PI_f)

#### Correlations: ####
# Overall:
cor.test(~PI_m+PI_f, data=pl_wide)
cor.test(~own_views+PI_m, data=pl_wide)
cor.test(~own_views+PI_f, data=pl_wide)
cor.test(~own_views+PI_all, data=pl_wide)

# Separately for male participants:
cor.test(~own_views+PI_m, data=filter(pl_wide, gender == 'Male'))
cor.test(~own_views+PI_f, data=filter(pl_wide, gender == 'Male'))
cor.test(~own_views+PI_all, data=filter(pl_wide, gender == 'Male'))

# Separately for female participants:
cor.test(~own_views+PI_m, data=filter(pl_wide, gender == 'Female'))
cor.test(~own_views+PI_f, data=filter(pl_wide, gender == 'Female'))
cor.test(~own_views+PI_all, data=filter(pl_wide, gender == 'Female'))

# Does the relationship between PI and own_views differ by gender?
# Nope.
summary(lm(PI_m~own_views*gender, data=pl_wide))
summary(lm(PI_f~own_views*gender, data=pl_wide))
summary(lm(PI_all~own_views*gender, data=pl_wide))

#### Scatterplots ####
pl_wide %>%
  ggplot(aes(x = own_views, y = PI_all, color = gender)) +
  theme_bw() +
  theme(axis.title = element_text(face = 'bold', size = 14),
        legend.title = element_text(face = 'bold', size = 14),
        legend.position = c(0.3, 0.9)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", 
              formula = y ~ x,
              se = TRUE, 
              color = "#f8961e") +
  #scale_fill_manual(values = c("#2b2d42", "#B71E42")) +
  ggtitle("Perception Ratings by Gender")+
  labs(x = 'Sexist Attitudes (Own Views)', 
       y = 'Pluralistic Ignorance (Perception - Reality)', 
       color = 'Participant Gender') + 
  ggtitle('Pluralistic Ignorance and Sexist Attitudes (overall perceptions)')
ggsave('Scatterplot_PI_all.pdf')

###
pl_wide %>%
  ggplot(aes(x = own_views, y = PI_all, color = gender)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", 
              formula = y ~ x,
              se = TRUE, 
              color = "green") +

  scale_color_manual(values = c("#2b2d42", "#B71E42"), 
                    name = "Participants\nGender", labels = c("Male", "Female")) +
  
  ggtitle('PI and Sexist Attitudes\n (overall perceptions)') +
  theme(
    plot.title = element_text(size=22, hjust = 0.5, face = "bold"),
    axis.text.x=element_text(size=12),
    axis.ticks.x=element_blank(),
    axis.text.y=element_text(size=12),
    axis.ticks.y=element_blank(), 
    axis.title=element_text(size=20),
    legend.position = "none"
  )+
  ylab('PI (Perception - Reality)') +
  xlab('Sexist Attitudes (Own Views)') 


pl_wide %>%
  ggplot(aes(x = own_views, y = PI_m, color = gender)) +
  theme_classic() +
  theme(axis.title = element_text(face = 'bold', size = 14),
        legend.title = element_text(face = 'bold', size = 14),
        legend.position = c(0.3, 0.9)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", 
              formula = y ~ x,
              se = TRUE, 
              color = "#B71E42") +
  labs(x = 'Sexist Attitudes (Own Views)', 
       y = 'Pluralistic Ignorance (Perception - Reality)', 
       color = 'Participant Gender') + 
  ggtitle('Pluralistic Ignorance and Sexist Attitudes (perceptions of Avg Male)')
ggsave('Scatterplot_PI_male perceptions.pdf')

pl_wide %>%
  ggplot(aes(x = own_views, y = PI_f, color = gender)) +
  theme_classic() +
  theme(axis.title = element_text(face = 'bold', size = 14),
        legend.title = element_text(face = 'bold', size = 14),
        legend.position = c(0.3, 0.9)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", 
              formula = y ~ x,
              se = TRUE, 
              color = "#B71E42") +
  labs(x = 'Sexist Attitudes (Own Views)', 
       y = 'Pluralistic Ignorance (Perception - Reality)', 
       color = 'Participant Gender') + 
  ggtitle('Pluralistic Ignorance and Sexist Attitudes (perceptions of Avg Female)')
ggsave('Scatterplot_PI_female perceptions.pdf')

##### Means Plots ##### 
overall_gend.aov <- aov(scenario_avg ~ Target*gender + Error(ResponseId), data = pl)
summary(overall_gend.aov)
overall_gend.em <- emmeans(overall_gend.aov, specs = pairwise~Target|gender)
overall_gend.em$emmeans
overall_gend.em$contrasts

overall_gend.em$emmeans %>% 
	as_tibble() %>%
	ggplot(aes(x = Target, y = emmean, fill=gender, group = gender)) + 
	coord_cartesian(ylim = c(1, 4)) +
    geom_text(aes(label = round(emmean, 2)), 
            size = 3, position = position_dodge(0.9), vjust = -3) +
	geom_col(col="black", position = position_dodge()) + 
	geom_errorbar(aes(ymin = emmean - SE, ymax = emmean + SE), width = 0.15, position = position_dodge(0.9)) +
  ggtitle("Male & Female Participant's Perceptions") +
  theme(plot.title = element_text(size=15, face = "bold", hjust = 0.5)) +
  ylab('Marginal means')+
  xlab('Target groups')


