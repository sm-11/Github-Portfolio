#Install package 'qualtRics'
install.packages("qualtRics")

#Import package
library(qualtRics)

#Enter API info
qualtrics_api_credentials(
  api_key = "API KEY HERE", 
  base_url = "datacenterid.qualtrics.com/"
)

#This fetches a list of all of the surveys 
surveys <- all_surveys() 

#Set Time Zone
Sys.setenv(TZ = "UTC")

#Select survey to download
mysurvey <- fetch_survey(surveyID = "SURVEY ID HERE")

#Save responses to a CSV file
write.csv(mysurvey, file = "Demo_survey_responses.csv", row.names = FALSE)