import json
import boto3
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    response = s3.get_object(
        Bucket=os.environ['S3_BUCKET'],
        Key="cand_c3_l3_test_object_encrypted.txt",
    )
    print(response['Body'].read())
    return
