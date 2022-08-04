#### Declaring Parameters #####
STACK_PREFIX=backend
STAGE_NAME=$stage
#STACK_NAME=$STAGE_NAME-$STACK_PREFIX-api
STACK_NAME=$STAGE_NAME-$ev-api
S3_BUCKET=com.deploy.platform.dev
ENV_VAR=$ev
AUTH_ZIPFILENAME=dist-$STAGE_NAME-$STACK_PREFIX-customauthorizer.zip
DB_NAME=poc-dev-db-snapshot-feb0312

############ REPORTS #######
git_var=$STACK_NAME-report.zip

cd "$WORKSPACE/scheduler"
npm install --quiet
npm prune --production

zip -r $git_var ./

aws s3 cp $git_var s3://cicd-demo-indeez/$git_var

rm -rf $git_var
##################### PDF-GEN ####################################
git_var=$STACK_NAME-pdf_generator.zip
cd "$WORKSPACE/PDFGenerator"
npm install --slient
npm prune --production
zip -r $git_var ./
aws s3 cp $git_var s3://cicd-demo-indeez/$git_var
rm -rf $git_var
#################### POST_AUTH #############################
git_var=$STACK_NAME-post_auth.zip
cd "$WORKSPACE/auth"
npm install --slient
npm prune --production
zip -r $git_var ./
aws s3 cp $git_var s3://cicd-demo-indeez/$git_var
rm -rf $git_var
#################### CUST-EMAIL ###########################
git_var=$STACK_NAME-customize_email.zip
cd "$WORKSPACE/auth"
npm install --slient
npm prune --production
zip -r $git_var ./
aws s3 cp $git_var s3://cicd-demo-indeez/$git_var
rm -rf $git_var

################### BACKEND - CONFIG ######################
echo "$WORKSPACE"
cd "$WORKSPACE"
#!/bin/bash 
#which python

# STACK_PREFIX=backend
# STAGE_NAME=dev
# STACK_NAME=$STACK_PREFIX-api-$STAGE_NAME

echo 'Starting ....'
#USERPOOL_LIST1=$(aws cognito-idp list-user-pools --max-results 1)
USERPOOL_LIST1=$(aws cloudformation list-stack-resources --stack-name $STACK_NAME)
echo "$USERPOOL_LIST1"
DB_SERVER=poc-dev-db-snapshot-feb0312
########################	PLATFORM API	##############################

INPUT_FILE=$STACK_PREFIX-template.yaml
OUTPUT_FILE=$STACK_PREFIX-template-output.yaml

# create s3 bucket (one-time only)
# aws s3 mb s3://$S3_BUCKET

# Copy Swagger file to S3 to be able to transform its content for "deploying" it to API Gateway
# aws s3 cp platform-swagger.yaml s3://$S3_BUCKET/platform-swagger.yaml

npm install --slient
npm prune --production

rm -rf .git
# rm -rf ./authorizer/node_modules/
# rm./authorizer/dist_dev_platform_customerauthorizer.zip

aws cloudformation package --template-file $INPUT_FILE \
                           --output-template-file $OUTPUT_FILE \
                           --s3-bucket $S3_BUCKET

aws cloudformation deploy --template-file $OUTPUT_FILE \
                          --stack-name $STACK_NAME \
                          --parameter-overrides StageName=$STAGE_NAME S3BucketName=$S3_BUCKET StackName=$STACK_NAME EnvID=$ENV_VAR \
                          --capabilities CAPABILITY_NAMED_IAM


export API_GATEWAY_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[0].OutputValue' --output text)
echo "API Gateway URL: $API_GATEWAY_URL"

############ Python- Configuration ####################
PYCMD=$(cat <<EOF
import json
import os

# Create SKM
dev_skm_data={
    "username": "postgres",
    "password": "JJ-^XC!5#SIzTL]Jg;I0ioAY|SqLwy1l",
    "engine": "postgres",
    "host": "$DB_SERVER+.eu-central-1.rds.amazonaws.com",
    "port": 5432,
    "dbname_dev": "indeez_db_dev",
    "dbInstanceIdentifier": "indeez-db-dev",
    "proxyHost": "indeez-rds-proxy-dev-v1.proxy-cl29oengynde.eu-central-1.rds.amazonaws.com"
    }

print("Creating skm_config.json")

with open('$WORKSPACE/shared/skm_config.json', "w") as file_write:
	# write json data into file
	json.dump(dev_skm_data, file_write)

dict_obj = json.dumps($USERPOOL_LIST1, indent=4, sort_keys=True)
dict_obj1 = json.loads(dict_obj)
USER_POOL_ID = dict_obj1.get('StackResourceSummaries')[2]['PhysicalResourceId']
print('USER_POOL_ID : ', USER_POOL_ID)


# Getting Other config data
dict_obj = json.dumps($USERPOOL_LIST1, indent=4, sort_keys=True)
dict_obj1 = json.loads(dict_obj)
#print("Type of dict_obj1", type(dict_obj1))

#USER_POOL_ID = dict_obj1.get('UserPools')[0]['Id']
#print('USER_POOL_ID: ' + USER_POOL_ID)

POOL_CLIENT_ID = os.popen('aws cognito-idp list-user-pool-clients --user-pool-id ' +  USER_POOL_ID )
output = POOL_CLIENT_ID.read()
y = json.loads(output)
USER_POOL_CLIENT_ID=y["UserPoolClients"][0].get("ClientId")

config_data={
    "NODE_ENV": "$ev",
    "isPrintLogs": "true",
    "SOURCE_ARN": "arn:aws:lambda:eu-central-1:838385783381:function:$STACK_NAME-reports-job-scheduler",
    "LAMBDA_FUNCTION": "$STACK_NAME-reports-job-scheduler",
    "REGION": "eu-central-1",
    "SECRETCODE": "$STACK_NAME-custom-authorizer",
    "USERPOOL": "arn:aws:cognito-idp:eu-central-1:838385783381:userpool/"+USER_POOL_ID,
    "HASHKEY": "Ag2yyL?-Qo4?4u",
    "clientId": USER_POOL_CLIENT_ID,
    "userPoolId": USER_POOL_ID,
    "dbconnection": "$STACK_NAME-dbConnection"
	}
    
print(config_data)
# print($WORKSPACE)

with open('$WORKSPACE/shared/config.json', "w") as file_write:
	# write json data into file
	json.dump(config_data, file_write)

print("Backend Configuration data created successfully.")

EOF
)

python -c "$PYCMD"

echo pwd
echo file://$WORKSPACE/config/skm_config.json

aws secretsmanager create-secret \
    --name $STACK_NAME-dbConnection \
    --secret-string file://$WORKSPACE/shared/skm_config.json

############ CUSTOM AUTHORIZER ############

chmod +x -R ${WORKSPACE}
cd "$WORKSPACE/authorizer"
npm install --slient
npm prune --production

zip -r $AUTH_ZIPFILENAME ./

# aws lambda update-function-code --function-name $STACK_NAME-custom-authorizer --zip-file fileb://$AUTH_ZIPFILENAME
