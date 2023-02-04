#!/bin/bash

# Download 12 videos from the "the_top_10_best_cat_tiktoks_on_the_internet_1" subreddit
youtube-dl $(curl -s -A "your bot 0.1" https://https://www.reddit.com/r/cats/hot.json?limit=12 | jq 
'.' | grep url_overridden_by_dest | grep -Eoh "https:\/\/v\.redd\.it\/\w{13}")

# Blur the videos and store them in the "blur" directory
mkdir blur
for video in *.mp4; do
  ffmpeg -i $video -vf "scale=ih*16/9:-1,boxblur=luma_radius=min(h\,w)/20:luma_power=1:chroma_radius=min(cw\,ch)/20:chroma_power=1" -vb 
800K blur/$video
done

# Concatenate the blurred videos into a single file "final.mp4"
rm *.mp4
echo "file blur/*.mp4" > file_list.txt
ffmpeg -f concat -safe 0 -i file_list.txt -c copy final.mp4
rm -rf blur

# Upload the final video to YouTube
python2 upload.py --file="final.mp4" --title="Funny Cat TikTok Compilation" --description="Best Cat TikTok compilation" 
--keywords="tiktok,cats" --category="22" --privacyStatus="public"

# Clean up
rm file_list.txt

