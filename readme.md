one command line deploy upload log file to ec2 auto

1.modify var by using your ec2 host and pem file in script/upload_start.sh

2.copy your ec2 pem file to script folder

3.how to use it:
./upload_deploy_for_account_service_local.sh ci
./upload_deploy_for_account_service_local.sh uat
./upload_deploy_for_account_service_local.sh prod

./upload_deploy_for_sales_funnel_local.sh ci
./upload_deploy_for_sales_funnel_local.sh uat
./upload_deploy_for_sales_funnel_local.sh prod

4.if you can't stop the running script, try it:
ssh -o StrictHostKeychecking=no ubuntu@$domain 'sudo ~/upload_log4ec2/upload_stop.sh'