#!/bin/bash

# Download the top 12 videos from Reddit's /r/cats subreddit
youtube-dl $(curl -s -H "User-agent: 'your bot 0.1'" https://www.reddit.com/r/cats/hot.json?limit=12 | jq '.' | grep url_overridden_by_dest | grep -Eoh "https://v.redd.it/\w{13}")

# Create a directory to store the processed videos
mkdir cats

# Process each video with ffmpeg
for f in *.mp4;
do
  ffmpeg -i $f -lavfi '[0:v]scale=ih*16/9:-1,blur=s=min(h,w)/20:5:5' -vb 800K cats/$f ;
done

# Concatenate the processed videos into a single file
ffmpeg -f concat -safe 0 -i <(for f in cats/*.mp4; do echo "file $f"; done) final.mp4

# Remove the original and processed videos
rm *.mp4
rm -rf cats
