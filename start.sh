#!/bin/bash

CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

CRON_ENVIRONMENT="
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"env variable is required"}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"env variable is required"}
MONGO_HOST=${MONGO_PORT_27017_TCP_ADDR:?"env variable is required"}
MONGO_PORT=${MONGO_PORT_27017_TCP_PORT:?"env variable is required"}
MONGO_USERNAME=$MONGO_USERNAME
MONGO_PASSWORD=$MONGO_PASSWORD
S3_BUCKET=${S3_BUCKET:?"env variable is required"}
BACKUP_FILENAME_PREFIX=${BACKUP_FILENAME_PREFIX:-mongo_backup}
BACKUP_FILENAME_DATE_FORMAT=${BACKUP_FILENAME_DATE_FORMAT:-%Y%m%d}
"
CRON_COMMAND="/script/backup.sh 1>/var/log/backup_script.log 2>&1"

echo
echo "Configuration"
echo
echo "CRON_SCHEDULE"
echo
echo "$CRON_SCHEDULE"
echo
echo "CRON_ENVIRONMENT"
echo "$CRON_ENVIRONMENT"

# crontab -l > mycron
echo "$CRON_ENVIRONMENT$CRON_SCHEDULE $CRON_COMMAND" >> mycron
crontab mycron
rm mycron

mkfifo /var/log/backup_script.log
cron
tail -f /var/log/backup_script.log
