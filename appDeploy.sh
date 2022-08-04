#!/bin/bash 

########  BUILD APP: ??? ########

APP_BRANCH_NAME="develop"

APP_ROLE_ID_admin='1884617c-f8e5-11eb-b71d-06ea78308b58'
APP_ROLE_ID_customer='2712e88a-f8e5-11eb-b71e-06ea78308b58'
APP_ROLE_ID_tpa='2712eb96-f8e5-11eb-b71f-06ea78308b58'
APP_ROLE_ID_tpl=''
APP_ROLE_ID_partner='2712ed30-f8e5-11eb-b720-06ea78308b58' 


APP_TYPE=$1
APP_ROLE_ID='defaultRoleId',
APP_NAME=$APP_TYPE'app'
APP_ROLE=$APP_TYPE

if [ $APP_TYPE == "admin" ] 
then
    echo 'Admin app settings'
    APP_ROLE_ID=$APP_ROLE_ID_admin
elif [ $APP_TYPE == "customer" ] 
then
    echo 'customer app settings'
    APP_ROLE_ID=$APP_ROLE_ID_customer
elif [ $APP_TYPE == "tpa" ] 
then
    echo 'tpa app settings'
    APP_ROLE_ID=$APP_ROLE_ID_tpa
elif [ $APP_TYPE == "tpl" ] 
then
    echo 'tpl app settings'
    APP_ROLE_ID=$APP_ROLE_ID_tpl
elif [ $APP_TYPE == "partner" ] 
then
    echo 'partner app settings'
    APP_ROLE_ID=$APP_ROLE_ID_partner            
fi


######## CONFIG DATA ######## 

STACK_PREFIX=$2
STAGE_NAME=$3
STACK_NAME=$STACK_PREFIX-app-$STAGE_NAME
API_STAGE_NAME=$STACK_PREFIX
API_STACK_NAME=$STACK_PREFIX-$STAGE_NAME-api
AWS_REGION=eu-central-01

STACK_RESOURCE_LIST=$(aws cloudformation list-stack-resources --stack-name $API_STACK_NAME)
echo $API_STACK_NAME

PYCMD=$(cat <<EOF
import json
import os

dict_obj = json.dumps($STACK_RESOURCE_LIST, indent=4, sort_keys=True)
dict_obj1 = json.loads(dict_obj)
REST_ID = dict_obj1.get('StackResourceSummaries')[20]['PhysicalResourceId']
print('REST_ID : ', REST_ID)

COGNITO_IDENTITY_POOL_ID = dict_obj1.get('StackResourceSummaries')[0]['PhysicalResourceId']
print('COGNITO_IDENTITY_POOL_ID : ', COGNITO_IDENTITY_POOL_ID)

APP_DOMAIN_ID = dict_obj1.get('StackResourceSummaries')[4]['PhysicalResourceId']
APP_DOMAIN_URL = 'https://'+APP_DOMAIN_ID+'.auth.eu-central-1.amazoncognito.com'
print('APP_DOMAIN_URL : ', APP_DOMAIN_URL)

# List of variables from AWS, STRIPE & others
# -------------------------------------------

# dict_obj = json.dumps($USERPOOL_LIST1, indent=4, sort_keys=True)
# dict_obj1 = json.loads(dict_obj)
# USER_POOL_ID = dict_obj1.get('UserPools')[0]['Id']

USER_POOL_ID = dict_obj1.get('StackResourceSummaries')[2]['PhysicalResourceId']
print('USER_POOL_ID : ', USER_POOL_ID)

USER_POOL_NAME = 'dev-user-pool' #$API_STACK_NAME+"-user-pool"
print('USER_POOL_ID, USER_POOL_NAME: ' + USER_POOL_ID +', '+ USER_POOL_NAME)

#
# USER_POOL_CLIENT_ID = os.popen('aws cognito-idp list-user-pool-clients --user-pool-id ' +  USER_POOL_ID )
# output = USER_POOL_CLIENT_ID.read()
# y = json.loads(output)
# WEB_CLIENT_ID=y["UserPoolClients"][0].get("ClientId")

WEB_CLIENT_ID = dict_obj1.get('StackResourceSummaries')[3]['PhysicalResourceId']
print('WEB_CLIENT_ID : ', WEB_CLIENT_ID)

API_URL="https://"+REST_ID+".execute-api.eu-central-1.amazonaws.com/$API_STAGE_NAME"
print('API_URL : ', API_URL)

# Misc env variables
REDIRECT_URL="https://$STACK_NAME.indeez.me/login"
STRIPE_KEY="pk_test_51HlYOIBmzTNEMOdvpertKlc5wg7RrmybIeIaLXJC2v98OPV5MBBLG6nOe94XsH9nacdy24Fu5DE6ui4UHfGyluxo00mB4qhIz8"

os.remove('./src/.env')

with open('./src/.env', 'a') as the_file:
    the_file.write('NG_APP_BRANCH_NAME=$APP_BRANCH_NAME\n')
    the_file.write('NG_APP_production=false\n')
    the_file.write('NG_APP_aws_project_region=$AWS_REGION\n')
    the_file.write('NG_APP_aws_cognito_region=$AWS_REGION\n')
    the_file.write('NG_APP_aws_cognito_url=cognito-idp.eu-central-1.amazonaws.com/\n')
    the_file.write('NG_APP_user_pool_name='+USER_POOL_NAME+'\n')
    the_file.write('NG_APP_aws_cognito_identity_pool_id='+COGNITO_IDENTITY_POOL_ID+'\n')
    the_file.write('NG_APP_aws_user_pools_id='+USER_POOL_ID+'\n')
    the_file.write('NG_APP_aws_user_pools_web_client_id='+WEB_CLIENT_ID+'\n')
    the_file.write('NG_APP_domain='+APP_DOMAIN_URL+'\n')
    the_file.write('NG_APP_apiUrl='+API_URL+'\n')
    the_file.write('NG_APP_bucketName=com.data.$STAGE_NAME/$API_STACK_NAME\n')
    the_file.write('NG_APP_theftInsurancebucketName=com.data.$STAGE_NAME/$API_STACK_NAME/tpl\n')
    the_file.write('NG_APP_region=$AWS_REGION\n')
    the_file.write('NG_APP_cognito_redirectSignIn='+REDIRECT_URL+'\n')
    the_file.write('NG_APP_cognito_redirectSignOut='+REDIRECT_URL+'\n')
    the_file.write('NG_APP_stripePublishKey='+STRIPE_KEY+'\n')
    the_file.write('NG_APP_appName=$APP_NAME\n')
    the_file.write('NG_APP_role=$APP_ROLE\n')
    the_file.write('NG_APP_roleId=$APP_ROLE_ID\n')
    the_file.write('NG_APP_logLevel=NgxLoggerLevel.LOG\n')
    the_file.write('NG_APP_disabledLogging=false\n')
    the_file.write('NG_APP_aws_fed_identity_id=undefined\n')
    the_file.write('NG_APP_hashKeyId=undefined\n')

print('$APP_TYPE' + ": FrontEnd App Configuration data created successfully.")

EOF
)
python -c "$PYCMD"
