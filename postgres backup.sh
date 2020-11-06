#!/bin/bash
#
# Backup a Postgresql database into a daily file.
##############################
## POSTGRESQL BACKUP CONFIG ##
##############################
#

# This dir will be the backup directory 

BACKUP_DIR=/pg_backup

# Number of days to keep daily backups
DAYS_TO_KEEP=14

# Database_hostname will be defined as follows
# running as. 
DB_HOST="mydbident.crmpgqwg4n3x.ap-south-1.rds.amazonaws.com"

# Make sure we're running as the required backup user and other configurations are as follows
DB_USER="myusername"
DB_PASSWORD="admin123"
DB_PORT="5432"
DB_NAME="mydbname"
DB_TABLE1="accounts"

#DB_TABLE2=""
SFTP_USER="sftpuser"
SFTP_IP="127.0.0.1"
DESTINATION_DIR= "."
OUTPUT_FILE="mybackup.sql"
SFTP_PASS="admin123"

OUTPUT_FILE=${BACKUP_DIR}/${FILE}

echo "$OUTPUT_FILE" is successfully created.

# Taking a database backup and getting the mysql database dump file
echo "taking backup and gzip the backup"
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t $DB_TABLE1 | gzip > $OUTPUT_FILE.gz

# show the user result
echo "${OUTPUT_FILE}.gz was created"

echo "THE BACKUP HAS BEEN SUCCESSFULLY CREATED"

#SSH password less authentiaction to sftp
ssh-keygen
ssh-copy-id <SFTP_USER:SFTP_PASS@SFTP_HOST>
#or the below can be used to copy ssh keys to remote server
cat ~/.ssh/id_rsa.pub | ssh root@{{server}} 'cat - >> ~/.ssh/authorized_keys'



# Upload backup file to SFTP server.
BACKUP_FILE=$OUTPUT_FILE
SFTP_USER=ec2-user
SFTP_HOST=<IP address or hostname>
SFTP_PATH=/home/$SFTP_USER/

SFTP_OUT=$(
sftp $SFTP_USER@$SFTP_HOST <<EOF
cd $SFTP_PATH
put $OUTPUT_FILE
ls -l $OUTPUT_FILE
quit

# DAILY BACKUPS

# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'

perform_backups "-daily"

EOF
)
exit(0)