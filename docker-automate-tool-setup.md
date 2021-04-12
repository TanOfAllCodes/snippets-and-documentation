# DOCKER-AUTOMATE TOOL SETUP 

### This is a tool written to Automate WP-Scan Report Generation using Docker. 
https://github.com/wpscanteam/wpscan/

For a generic Automation Tool, it's better to have a singular place which multiple developers can access so that any requirement for change can be done centrally. 
This removes the need for developers to constantly keep their CLI updated. 
Hence the approach with Jenkins is used. 

##### This script can easily be converted to a bash CLI tool for developers. 
##### One may also add functionality for AWS and other storage buckets. In this case, choice based scripts can also be written.

### Assumptions:

1. There is a Machine, called Base Machine (BM) with Jenkins, Docker and GCloud / GSutils installed on it.  
2. Docker functions normally, Jenkins has access to using Docker, GCloud and GSutils preconfigured. (This is a one time process) 
3. BM will have access to the Internet.

#### In this project, I have access to only a Windows Machine and GCP (Instead of AWS). 

#### First, Create a jenkins freestyle job. (No extra plugins required)

### ENVIORNMENT VARIABLES TO BE CREATED AS PARAMETERS IN JENKINS

##### OUTPUT_FILE
This is the file that will be uploaded to GCP Storage Bucket.
Example: C:\Users\tanis\Documents\pagar\file.txt
###### Specifiy the full path.

##### GCP_BUCKET_NAME
Name of the Storage Bucket.
Example: buckket-o1
###### Do not include "gs://" 

##### WPSCAN_URL
The URL to be Scanned in the Wordpress Database.
Example: https://www.aykha.in/
###### Include the Full URL.

##### WPSCAN_UN_RANGE
The Range of Usernames to be Scanned.
Example: 1-25
###### Enter the format as (Number)-(Number)

##### WP_API_TOKEN
Wordpress API token for access.
###### Get one from https://wpscan.com/api


#### Since this project was created on windows, create a build-step with "Execute Windows Batch Commands" in the Jenkins Job, with the following script.

```
echo "Enumerating Usernames, Username Range=%WPSCAN_UN_RANGE%  API-Token=%WP_API_TOKEN%"   
docker run -t --rm wpscanteam/wpscan --update --url %WPSCAN_URL% --random-user-agent %WP_API_TOKEN% --ignore-main-redirect --enumerate u%WPSCAN_UN_RANGE% > %OUTPUT_FILE%
gsutil cp %OUTPUT_FILE% gs://%GCP_BUCKET_NAME%
```

In some cases, gsutil may not be recognized as a command in the Jenkins shell, in this case explicitly provide the full path to the command binary, example
```
"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gsutil" cp %OUTPUT_FILE% gs://%GCP_BUCKET_NAME%
```

An equivalent can be created if Jenkins exists on Linux Machine. 

```
echo "Enumerating Usernames, Username Range=$WPSCAN_UN_RANGE  API-Token=$WP_API_TOKEN"   
docker run -t --rm wpscanteam/wpscan --update --url $WPSCAN_URL --random-user-agent $WP_API_TOKEN --ignore-main-redirect --enumerate u$WPSCAN_UN_RANGE > $OUTPUT_FILE
gsutil cp $OUTPUT_FILE gs://$GCP_BUCKET_NAME
```


