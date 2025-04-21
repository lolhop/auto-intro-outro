#!/bin/bash
INTRO_FILE="/Users/sam/Documents/Programs/Intro:outro/intro.mov"
OUTRO_FILE="/Users/sam/Documents/Programs/Intro:outro/outro.mov"
INPUT_FOLDER="/Users/sam/Documents/Programs/Intro:outro/INPUT-FOLDER"
OUTPUT_FOLDER="/Users/sam/Documents/Programs/Intro:outro/OUTPUT-FOLDER"
mkdir -p "$OUTPUT_FOLDER"

# Check dependencies
command -v ffmpeg > /dev/null || { echo "FFmpeg required"; exit 1; }
command -v bc > /dev/null || { echo "bc required"; exit 1; }
[ -f "$INTRO_FILE" ] || { echo "Intro file not found at $INTRO_FILE"; exit 1; }
[ -f "$OUTRO_FILE" ] || { echo "Outro file not found at $OUTRO_FILE"; exit 1; }

get_duration() {
  ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1"
}

for INPUT_FILE in "$INPUT_FOLDER"/*.mp4; do
  [ -e "$INPUT_FILE" ] || continue
  FILENAME=$(basename "$INPUT_FILE" .mp4)
  OUTPUT_FILE="$OUTPUT_FOLDER/${FILENAME}-processed.mp4"
  
  echo "🎬 Processing $FILENAME..."
  
  INTRO_DURATION=$(get_duration "$INTRO_FILE")
  OUTRO_DURATION=$(get_duration "$OUTRO_FILE")
  MAIN_DURATION=$(get_duration "$INPUT_FILE")
  OUTRO_START=$(echo "$MAIN_DURATION - $OUTRO_DURATION" | bc)
  
  # One-pass with videotoolbox hardware acceleration for M1
  ffmpeg -hwaccel videotoolbox -i "$INPUT_FILE" -i "$INTRO_FILE" -i "$OUTRO_FILE" \
  -filter_complex "\
  [1:v]format=rgba,setpts=PTS-STARTPTS[intro]; \
  [2:v]format=rgba,setpts=PTS-STARTPTS+($OUTRO_START/TB)[outro]; \
  [0:v][intro]overlay=0:0:enable='lt(t,$INTRO_DURATION)'[v1]; \
  [v1][outro]overlay=0:0:enable='gte(t,$OUTRO_START)'[vfinal]" \
  -map "[vfinal]" -map 0:a -c:v h264_videotoolbox -allow_sw 0 -q:v 50 \
  -threads 8 -c:a copy "$OUTPUT_FILE"
  
  echo "✅ Done: $OUTPUT_FILE"
done
echo "🎉 All videos processed."