import cv2
import os
from gtts import gTTS
import subprocess

# --- Text and Configuration ---
transcript = """."""

output_filename = "reels/name.mp4"  # Output file name
image_folder = "images"  # Folder containing background images
fps = 24  # Frames per second

# --- Text-to-Speech ---
tts = gTTS(text=transcript, lang='en')  # 'en' for English
tts.save("audio.mp3")

# --- Get Image Files ---
image_files = [os.path.join(image_folder, img) for img in os.listdir(image_folder) if img.endswith(('.jpg', '.png', '.jpeg'))]

# --- Calculate Clip Duration ---
audio_duration = len(transcript.split()) / 2.5  # Approximate duration based on word count
clip_duration = audio_duration / len(image_files)

# --- Create Video ---
frame_size = (1920, 1080)  # Adjust resolution as needed
fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # Codec for MP4
temp_video = "temp_video.mp4"  # Temporary video file (without audio)
video_writer = cv2.VideoWriter(temp_video, fourcc, fps, frame_size)

for img_file in image_files:
    img = cv2.imread(img_file)
    img = cv2.resize(img, frame_size)  # Resize image to match frame size
    for _ in range(int(clip_duration * fps)):  # Add frames for the duration of the clip
        video_writer.write(img)

video_writer.release()

# --- Combine Video and Audio Using FFmpeg ---
ffmpeg_command = [
    "ffmpeg",
    "-i", temp_video,  # Input video file
    "-i", "audio.mp3",  # Input audio file
    "-c:v", "copy",     # Copy video codec (no re-encoding)
    "-c:a", "aac",      # Use AAC audio codec
    "-shortest",        # Ensure the output matches the shorter of the two inputs
    output_filename     # Output file
]

# Run FFmpeg command
subprocess.run(ffmpeg_command)

# --- Clean up temporary files ---
os.remove(temp_video)
os.remove("audio.mp3")

print(f"Reel created successfully: {output_filename}")
