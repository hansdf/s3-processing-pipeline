import boto3
from PIL import Image
import io

s3_client = boto3.client('s3')

bucket_name = event['Records'][0]['s3']['bucket']['name']
file_key = event['Records'][0]['s3']['object']['key']

print(f"Processing file {file_key} from bucket {bucket_name}")

try:
    response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
    image_content = response['Body'].read()

    with Image.open(io.BytesIO(image_content)) as image:
        image.thumbnail((150, 150))
        buffer = io.BytesIO()
        image.save(buffer, "JPEG")
        buffer.seek(0) # buffers are dumb

        output_bucket = "output-bucket-s3-img-processing-pipeline"
        output_key = f"thumbnail-{file_key}"

        s3_client.put_object(Bucket=output_bucket, Key=output_key, Body=buffer)

        print(f"Successfully created thumbnail: {output_key}")
        return {'status': 'success'}

except Exception as err:
    print(f"Error processing file: {err}")
    raise err