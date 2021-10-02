import json

def handler(event, context):
    responseMessage = 'Hello, World!';

    if ('queryStringParameters' in event and 'Name' in event['queryStringParameters']):
        responseMessage = 'Hello, ' + event['queryStringParameters']['Name'] + '!'

    return {
        'statusCode': 200,
        'body': json.dumps(responseMessage)
    }
