import boto3
from PIL import Image
import io

s3_client = boto3.client('s3')