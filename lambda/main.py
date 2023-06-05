import os
import logging
import boto3


BACKUP_S3_BUCKET = os.environ['BACKUP_S3_BUCKET']
BACKUP_KMS_KEY = os.environ['BACKUP_KMS_KEY']
BACKUP_EXPORT_ROLE = os.environ['BACKUP_EXPORT_ROLE']
BACKUP_FOLDER = os.environ['BACKUP_FOLDER']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

boto3_session = boto3.Session()

def lambda_handler(event, context):
    snapshot_arn = event['detail']['SourceArn']
    
    rds_client = boto3_session.client('rds')

    snapshot = rds_client.describe_db_snapshots(
        DBSnapshotIdentifier=snapshot_arn,
    )['DBSnapshots'][0]
    
    instance_id = snapshot['DBInstanceIdentifier']
    snapshot_time = snapshot['SnapshotCreateTime']

    s3_prefix = "{0}/{1}".format(BACKUP_FOLDER, instance_id)
    export_id = "{0}-{1}".format(''.join(filter(str.isalnum, instance_id)), snapshot_time.strftime("%y%m%d%H%M"))

    export = rds_client.start_export_task(
        ExportTaskIdentifier=export_id,
        SourceArn=snapshot_arn,
        S3BucketName=BACKUP_S3_BUCKET,
        IamRoleArn=BACKUP_EXPORT_ROLE,
        KmsKeyId=BACKUP_KMS_KEY,
        S3Prefix=s3_prefix,
    )

    logger.info("ExportTaskIdentifier={0}, SourceArn={1}".format(export_id, snapshot_arn))
