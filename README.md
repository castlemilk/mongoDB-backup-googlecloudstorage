# MongoDB-backup-googlecloudstorage
Basic tool for MongoDB backup to Google Cloud Storage (object store)

# Environment:
Python 2.7
MongoDB v3.4
Google Cloud Storage


# cron-tab configuration
30 03 * * 0,2,5 /root/db-backup/backup.sh
