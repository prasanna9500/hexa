#!/bin/bash 
#### Declaring Parameters ######
STACK_PREFIX=$stage   #$stage
STAGE_NAME=$ev
API_STACK_NAME=$STACK_PREFIX-$STAGE_NAME-api

# CREATE DATA bukets for the NEW environment
APP_BUCKETNAME=$(aws s3api put-object --bucket com.data.$STAGE_NAME --key $API_STACK_NAME)
echo $APP_BUCKETNAME
APP_DATA_CLAIMS=$(aws s3api put-object --bucket com.data.$STAGE_NAME  --key $API_STACK_NAME/claims)
echo $APP_DATA_CLAIMS
APP_DATA_PARTNERS=$(aws s3api put-object --bucket com.data.$STAGE_NAME  --key $API_STACK_NAME/partner)
echo $APP_DATA_PARTNERS
APP_DATA_USERS=$(aws s3api put-object --bucket com.data.$STAGE_NAME  --key $API_STACK_NAME/users)
echo $APP_DATA_USERS
# APP_TPLBUCKETNAME=$(aws s3api put-object --bucket com.data.$STAGE_NAME --key $API_STACK_NAME/tpl)
# echo $APP_TPLBUCKETNAME
APP_DATA_TPLCLAIMS=$(aws s3api put-object --bucket com.data.$STAGE_NAME  --key $API_STACK_NAME/tpl/claims)
echo $APP_DATA_TPLCLAIMS

########  BUILD APP: ADMIN ########
APP_TYPE=admin
echo 'Starting Admin app settings'
# calling APP setting script
./appDeploy.sh $APP_TYPE $STACK_PREFIX $STAGE_NAME

npm install --quiet
# Config files set using .env file
npm run config -- --environment=$STAGE_NAME
ng build --configuration $STAGE_NAME-$APP_TYPE'app' --output-path dist/$APP_TYPE/

echo '$APP_TYPE - Finished Building App'

########  BUILD APP: CUSTOMER ########

APP_TYPE=customer
echo 'Starting Customer app settings'
# calling APP setting script
./appDeploy.sh $APP_TYPE $STACK_PREFIX $STAGE_NAME

# Config files set using .env file
npm run config -- --environment=$STAGE_NAME
ng build --configuration $STAGE_NAME-$APP_TYPE'app' --output-path dist/$APP_TYPE/

echo '$APP_TYPE - Finished Building App'

########  BUILD APP: TPA ########
APP_TYPE=tpa
echo 'Starting TPA app settings'
# calling APP setting script
./appDeploy.sh $APP_TYPE $STACK_PREFIX $STAGE_NAME

# Config files set using .env file
npm run config -- --environment=$STAGE_NAME
ng build --configuration $STAGE_NAME-$APP_TYPE'app' --output-path dist/$APP_TYPE/

echo '$APP_TYPE - Finished Building App'

########  BUILD APP: TPL ########
APP_TYPE=tpl
echo 'Starting TPL app settings'
# calling APP setting script
./appDeploy.sh $APP_TYPE $STACK_PREFIX $STAGE_NAME

# Config files set using .env file
npm run config -- --environment=$STAGE_NAME
ng build --configuration $STAGE_NAME-$APP_TYPE'app' --output-path dist/$APP_TYPE/

echo '$APP_TYPE - Finished Building App'

########  BUILD APP: PARTNER ########
APP_TYPE=partner
echo 'Starting Partner app settings'
# calling APP setting script
./appDeploy.sh $APP_TYPE $STACK_PREFIX $STAGE_NAME

# Config files set using .env file
npm run config -- --environment=$STAGE_NAME
ng build --configuration $STAGE_NAME-$APP_TYPE'app' --output-path dist/$APP_TYPE/

echo '$APP_TYPE - Finished Building App'

###################################################
exit 0
