import os
import argparse
import google.auth
import googleapiclient.discovery

# Parse the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--file', required=True, help='The video file to be uploaded.')
parser.add_argument('--title', required=True, help='The title of the video.')
parser.add_argument('--description', required=True, help='The description of the video.')
parser.add_argument('--keywords', required=True, help='The keywords associated with the video, separated by commas.')
parser.add_argument('--category', required=True, help='The category of the video, specified as a number.')
parser.add_argument('--privacyStatus', required=True, help='The privacy status of the video, either "public", "private", or 
"unlisted".')
args = parser.parse_args()

# Authenticate the user
creds, project = google.auth.default()

# Build the YouTube API client
youtube = googleapiclient.discovery.build('youtube', 'v3', credentials=creds)

# Create the video resource
video_resource = {
    'snippet': {
        'title': args.title,
        'description': args.description,
        'tags': args.keywords.split(','),
        'categoryId': args.category
    },
    'status': {
        'privacyStatus': args.privacyStatus
    }
}

# Create the request to insert the video into the channel
request = youtube.videos().insert(part='snippet,status', body=video_resource, media_body=args.file)

# Upload the video in chunks, with error handling and retry logic
response = None
retry = True
while retry:
    try:
        status, response = request.next_chunk()
        if response is not None:
            retry = False
            print(f'Upload successful: {response["id"]}')
    except HttpError as error:
        if error.resp.status in [500, 502, 503, 504]:
            print(f'Retrying due to {error}')
        else:
            retry = False
            print(f'Error: {error}')

