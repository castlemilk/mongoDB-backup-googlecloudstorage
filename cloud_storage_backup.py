import argparse
import os
from google.cloud import storage
from google.cloud.exceptions import GoogleCloudError

def upload_file(file_path, bucket):
	'''Uploads given file to the specified bucket in google cloud storage'''	
	storage_client = storage.Client()
	try:
		bucket = storage_client.get_bucket(bucket)
	except storage.exceptions.NotFound:
		print "Failed to find the bucket named %s" % (bucket)
		raise storage.exceptions.NotFound
		

	try:
		file_name = os.path.basename(file_path)
		blob = storage.Blob(file_name, bucket)
		print "Uploading file @ %s" % file_path
		print "File size: %3.1f MB" % (os.path.getsize(file_path)/1024.0/1024.0)
		with open(file_path, 'r') as fp:
			blob.upload_from_file(fp)
	except GoogleCloudError:
		print "failed to upload %s" %(file_name)
		raise GoogleCloudError


def main():
	"upload MongoDB backups to google cloud storage"

	parser = argparse.ArgumentParser(description='''Upload files (mongoDB archives for example) to google cloud object store.''')

	parser.add_argument('-f', '--file', dest='path', help='Specific file (full path) to be uploaded to object storage')
	parser.add_argument('-b', '--bucket', dest='bucket', help='Name of bucket to upload files to')

	args = vars(parser.parse_args())

	file_path = args['path']
	bucket_name = args['bucket']

	upload_file(file_path, bucket_name)

if __name__=="__main__":
	main()
