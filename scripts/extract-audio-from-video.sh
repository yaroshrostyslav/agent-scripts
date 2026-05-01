#!/bin/bash

# Description: Simple script to extract audio (mp3) from video on macOS
# Requires: brew install ffmpeg
# Usage: ./extract_audio.sh <video-file> [output-dir]

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed!"
    echo "Install via Homebrew: brew install ffmpeg"
    exit 1
fi

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage:   bash extract_audio.sh <video-file> [output-dir]"
    echo "Example: bash extract_audio.sh video.mp4"
    echo "         bash extract_audio.sh video.mp4 ./output"
    exit 1
fi

VIDEO_FILE="$1"
OUTPUT_DIR="${2:-}"  # Optional output directory

# Check if file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "File not found: $VIDEO_FILE"
    exit 1
fi

# Build output filename
BASENAME=$(basename "${VIDEO_FILE%.*}")
if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}.mp3"
else
    OUTPUT_FILE="${VIDEO_FILE%.*}.mp3"
fi

echo "Processing video:     $VIDEO_FILE"
echo "Extracting audio to:  $OUTPUT_FILE"

# Extract audio using ffmpeg
if ffmpeg -i "$VIDEO_FILE" -vn -acodec libmp3lame -q:a 2 "$OUTPUT_FILE" -y -loglevel quiet; then
    echo "Done! Audio saved to: $OUTPUT_FILE"
    SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "File size: $SIZE"
else
    echo "Error extracting audio"
    exit 1
fi