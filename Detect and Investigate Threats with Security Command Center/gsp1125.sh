clear

#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Get Compute Zone & Region
echo "${YELLOW}${BOLD}Fetching Compute Zone & Region...${RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 2: Get IAM Policy and Save to JSON
echo "${BLUE}${BOLD}Retrieving IAM Policy...${RESET}"
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --format=json > policy.json

# Step 3: Update IAM Policy
echo "${GREEN}${BOLD}Updating IAM Policy...${RESET}"
jq '{ 
  "auditConfigs": [ 
    { 
      "service": "cloudresourcemanager.googleapis.com", 
      "auditLogConfigs": [ 
        { 
          "logType": "ADMIN_READ" 
        } 
      ] 
    } 
  ] 
} + .' policy.json > updated_policy.json

# Step 4: Set Updated IAM Policy
echo "${RED}${BOLD}Applying Updated IAM Policy...${RESET}"
gcloud projects set-iam-policy $(gcloud config get-value project) updated_policy.json

# Step 5: Enable Security Center API
echo "${CYAN}${BOLD}Enabling Security Center API...${RESET}"
gcloud services enable securitycenter.googleapis.com --project=$DEVSHELL_PROJECT_ID

# Step 6: Wait for 20 seconds
echo "${YELLOW}${BOLD}Waiting for API to be enabled...${RESET}"
sleep 20

# Step 7: Add IAM Binding for BigQuery Admin
echo "${MAGENTA}${BOLD}Granting BigQuery Admin Role...${RESET}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 8: Remove IAM Binding for BigQuery Admin
echo "${BLUE}${BOLD}Revoking BigQuery Admin Role...${RESET}"
gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 9: Add IAM Binding for IAM Admin
echo "${GREEN}${BOLD}Granting IAM Admin Role...${RESET}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_EMAIL \
  --role=roles/cloudresourcemanager.projectIamAdmin 2>/dev/null

# Step 10: Create Compute Instance
echo "${BLUE}${BOLD}Creating Compute Instance...${RESET}"
gcloud compute instances create instance-1 \
--zone=$ZONE \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230912,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced

# Step 11: Create DNS Policy
echo "${CYAN}${BOLD}Creating DNS Policy...${RESET}"
gcloud dns --project=$DEVSHELL_PROJECT_ID policies create dns-test-policy --description="quickgcplab" --networks="default" --private-alternative-name-servers="" --no-enable-inbound-forwarding --enable-logging

# Step 12: Wait for 30 seconds
echo "${YELLOW}${BOLD}Waiting for DNS Policy to take effect...${RESET}"
sleep 30

# Step 13: SSH into Compute Instance and Execute Commands
echo "${MAGENTA}${BOLD}Connecting to Compute Instance...${RESET}"
gcloud compute ssh instance-1 --zone=$ZONE --tunnel-through-iap --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud projects get-iam-policy \$(gcloud config get project) && curl etd-malware-trigger.goog"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${BOLD}${YELLOW}Have you checked your progress for Task 1 & Task 2? (Y/N): ${RESET}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD}${GREEN}Great! Proceeding to the next steps...${RESET}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD}${RED}Please check your progress for Task 1 & Task 2 and then press Y to continue.${RESET}"
        else
            echo
            echo "${BOLD}${MAGENTA}Invalid input. Please enter Y or N.${RESET}"
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 14: Delete Compute Instance
echo "${BLUE}${BOLD}Deleting Compute Instance...${RESET}"
gcloud compute instances delete instance-1 --zone=$ZONE --quiet

echo

# Function to display a random congratulatory message
function random_congrats() {
    MESSAGES=(
        "${GREEN}Congratulations For Completing The Lab! Keep up the great work!${RESET}"
        "${CYAN}Well done! Your hard work and effort have paid off!${RESET}"
        "${YELLOW}Amazing job! You’ve successfully completed the lab!${RESET}"
        "${BLUE}Outstanding! Your dedication has brought you success!${RESET}"
        "${MAGENTA}Great work! You’re one step closer to mastering this!${RESET}"
        "${RED}Fantastic effort! You’ve earned this achievement!${RESET}"
        "${CYAN}Congratulations! Your persistence has paid off brilliantly!${RESET}"
        "${GREEN}Bravo! You’ve completed the lab with flying colors!${RESET}"
        "${YELLOW}Excellent job! Your commitment is inspiring!${RESET}"
        "${BLUE}You did it! Keep striving for more successes like this!${RESET}"
        "${MAGENTA}Kudos! Your hard work has turned into a great accomplishment!${RESET}"
        "${RED}You’ve smashed it! Completing this lab shows your dedication!${RESET}"
        "${CYAN}Impressive work! You’re making great strides!${RESET}"
        "${GREEN}Well done! This is a big step towards mastering the topic!${RESET}"
        "${YELLOW}You nailed it! Every step you took led you to success!${RESET}"
        "${BLUE}Exceptional work! Keep this momentum going!${RESET}"
        "${MAGENTA}Fantastic! You’ve achieved something great today!${RESET}"
        "${RED}Incredible job! Your determination is truly inspiring!${RESET}"
        "${CYAN}Well deserved! Your effort has truly paid off!${RESET}"
        "${GREEN}You’ve got this! Every step was a success!${RESET}"
        "${YELLOW}Nice work! Your focus and effort are shining through!${RESET}"
        "${BLUE}Superb performance! You’re truly making progress!${RESET}"
        "${MAGENTA}Top-notch! Your skill and dedication are paying off!${RESET}"
        "${RED}Mission accomplished! This success is a reflection of your hard work!${RESET}"
        "${CYAN}You crushed it! Keep pushing towards your goals!${RESET}"
        "${GREEN}You did a great job! Stay motivated and keep learning!${RESET}"
        "${YELLOW}Well executed! You’ve made excellent progress today!${RESET}"
        "${BLUE}Remarkable! You’re on your way to becoming an expert!${RESET}"
        "${MAGENTA}Keep it up! Your persistence is showing impressive results!${RESET}"
        "${RED}This is just the beginning! Your hard work will take you far!${RESET}"
        "${CYAN}Terrific work! Your efforts are paying off in a big way!${RESET}"
        "${GREEN}You’ve made it! This achievement is a testament to your effort!${RESET}"
        "${YELLOW}Excellent execution! You’re well on your way to mastering the subject!${RESET}"
        "${BLUE}Wonderful job! Your hard work has definitely paid off!${RESET}"
        "${MAGENTA}You’re amazing! Keep up the awesome work!${RESET}"
        "${RED}What an achievement! Your perseverance is truly admirable!${RESET}"
        "${CYAN}Incredible effort! This is a huge milestone for you!${RESET}"
        "${GREEN}Awesome! You’ve done something incredible today!${RESET}"
        "${YELLOW}Great job! Keep up the excellent work and aim higher!${RESET}"
        "${BLUE}You’ve succeeded! Your dedication is your superpower!${RESET}"
        "${MAGENTA}Congratulations! Your hard work has brought great results!${RESET}"
        "${RED}Fantastic work! You’ve taken a huge leap forward today!${RESET}"
        "${CYAN}You’re on fire! Keep up the great work!${RESET}"
        "${GREEN}Well deserved! Your efforts have led to success!${RESET}"
        "${YELLOW}Incredible! You’ve achieved something special!${RESET}"
        "${BLUE}Outstanding performance! You’re truly excelling!${RESET}"
        "${MAGENTA}Terrific achievement! Keep building on this success!${RESET}"
        "${RED}Bravo! You’ve completed the lab with excellence!${RESET}"
        "${CYAN}Superb job! You’ve shown remarkable focus and effort!${RESET}"
        "${GREEN}Amazing work! You’re making impressive progress!${RESET}"
        "${YELLOW}You nailed it again! Your consistency is paying off!${RESET}"
        "${BLUE}Incredible dedication! Keep pushing forward!${RESET}"
        "${MAGENTA}Excellent work! Your success today is well earned!${RESET}"
        "${RED}You’ve made it! This is a well-deserved victory!${RESET}"
        "${CYAN}Wonderful job! Your passion and hard work are shining through!${RESET}"
        "${GREEN}You’ve done it! Keep up the hard work and success will follow!${RESET}"
        "${YELLOW}Great execution! You’re truly mastering this!${RESET}"
        "${BLUE}Impressive! This is just the beginning of your journey!${RESET}"
        "${MAGENTA}You’ve achieved something great today! Keep it up!${RESET}"
        "${RED}You’ve made remarkable progress! This is just the start!${RESET}"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files