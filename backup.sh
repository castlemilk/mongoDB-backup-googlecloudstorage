#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS="NutritionDB-4ce3546cf063.json"

function mongodb_lock()
{
	MONGO_PATH=`which mongo`
	echo -n "MONGODB: Forcing file sync and locking writes"
	$MONGO_PATH admin --eval "printjson(db.fsyncLock())"
	echo " ---> Done."

}
function mongodb_unlock()
{
	MONGO_PATH=`which mongo`
	echo -n "MONGODB: unlocking writes"
	$MONGO_PATH admin --eval "printjson(db.fsyncUnlock())"
	echo " ---> Done."
}
function mongodb_dump()
{
	# $1 - HOST [required]
	# $2 - PORT [required]
	# $3 - DB_NAME [required]
	# $4 - OUT_PATH [required]
	# $5 - COLLECTION_NAME [optional]
	MONGODUMP_BIN=${MONGODUMP_BIN:-`which mongodump`}
	MONGODUMP_ARGS="--host $1:$2 --gzip --archive=$4 -d $3"
	if [ -n $5 ]; then
		MONGODUMP_ARGS="${MONGODUMP_ARGS} --collection $5"
	fi
	echo ${MONGODUMP_ARGS}
	${MONGODUMP_BIN} ${MONGODUMP_ARGS}
	echo "dump complete"
}
function mongo_backup()
{
	MONGO_HOST=${2:-localhost}
	MONGO_PORT=${3:-27017}
	MONGO_DB=${4:-NA}
	MONGO_COLLECTION=${5:-NA}
	TIMESTAMP=`date +%F`
	DUMP_PATH=${1:-`pwd`/backup}/mongodb-${MONGO_DB}-${TIMESTAMP}.gzip
	echo " dumping mongo DB: ${MONGO_DB} [Collection: ${MONGO_COLLECTION}]"
	echo " save path -> ${DUMP_PATH}"

	#mongodb_lock
	# dump specific collection only:
	# -------------
	mongodb_lock
	mongodb_dump ${MONGO_HOST} ${MONGO_PORT} ${MONGO_DB} ${DUMP_PATH} ${MONGO_COLLECTION}
	mongodb_unlock
	# -------------
	# dump entire DB name:
	# -------------
	#mongodb_lock
	#mongodb_dump ${MONGO_HOST} ${MONGO_PORT} ${MONGO_DB} ${DUMP_PATH}
	#mongodb_unlock
	# -------------
}

function build_backup_dir()
{
	if [ ! -d $1 ]; then
		echo -n "Directory $1 does not exist, creating now."
		mkdir -p $1	
		echo " ---> Done."
	fi
}
BACKUP_DIR=${BACKUP_DIR:-`pwd`/backup}

build_backup_dir ${BACKUP_DIR}
mongo_backup ${BACKUP_DIR} localhost 27017 nuttab nuttab_docs
NUTTAB_FILE_PATH=$DUMP_PATH
mongo_backup ${BACKUP_DIR} localhost 27017 usda usda_doc
USDA_FILE_PATH=$DUMP_PATH
python cloud_storage_backup.py -f $NUTTAB_FILE_PATH -b nuttab-backup
python cloud_storage_backup.py -f $USDA_FILE_PATH -b usda-backup
