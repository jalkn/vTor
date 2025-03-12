# Define colors for output
$GREEN = "Green"
$YELLOW = "Yellow"

function createStructure {
    Write-Host "🏗️ Creating Directory Structure" -ForegroundColor $YELLOW

    # Define the root directory (current directory)
    $rootDir = "."

    # Create Python virtual environment
    if (-not (Test-Path ".venv")) {
        Write-Host "Creating Python virtual environment..." -ForegroundColor $GREEN

        # Check if the system is a Mac
        if ($env:OS -eq "Unix" -or $env:OSTYPE -eq "darwin") {
            # Use python3 on macOS to ensure Python 3 is used
            python3 -m venv .venv
        } else {
            # Use python on Windows
            python -m venv .venv
        }
    }

    # Activate the virtual environment
    Write-Host "Activating virtual environment..." -ForegroundColor $GREEN
    # Check if the system is a Mac
    if ($env:OS -eq "Unix" -or $env:OSTYPE -eq "darwin") {
        # Activate virtual environment on macOS
        .venv/bin/activate
    } else {
        # Activate virtual environment on Windows
        .\.venv\Scripts\Activate.ps1
    }

    # Upgrade pip and install required packages
    Write-Host "Installing required Python packages..." -ForegroundColor $GREEN
    python -m pip install --upgrade pip
    python -m pip install youtube-transcript-api transformers opencv-python gtts

    # Create subdirectories
    Write-Host "Creating directory structure..." -ForegroundColor $GREEN
    $directories = @(
        "scripts",
        "transcripts",
        "images",
        "reels",
        "audios",
        "summaries"
    )
    # Loop through the directory names and create them
    foreach ($dir in $directories) {
        $fullPath = Join-Path -Path $rootDir -ChildPath $dir

        # Check if the directory already exists
        if (-not (Test-Path -Path $fullPath -PathType Container)) {
            try {
                New-Item -ItemType Directory -Path $fullPath -Force
                Write-Host "Created directory: $fullPath" -ForegroundColor $GREEN
            }
            catch {
                Write-Host "Error creating directory $($fullPath): $($_.Exception.Message)" -ForegroundColor "Red"
            }
        }
        else {
            Write-Host "Directory already exists: $fullPath" -ForegroundColor $YELLOW
        }
    }

    Write-Host "Directory structure creation complete." -ForegroundColor $GREEN

    # Create empty Python files
    $files = @(
        "scripts/geTranscript.py",
        "scripts/reel.py"

    )
    foreach ($file in $files) {
        if (-not (Test-Path $file)) {
            New-Item -Path $file -ItemType File -Force
        }
    }
}
function geTranscript {
    Write-Host "🏗️ Creating Excel Analyzer Script" -ForegroundColor $YELLOW
    # geTranscript.py script
    Set-Content -Path "scripts/geTranscript.py" -Value @"
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api.formatters import TextFormatter
from transformers import pipeline

def get_transcript_and_summary(video_id, languages=['en'], transcript_filename="transcripts/transcript.txt", summary_filename="summaries/summary.txt", min_length=75, max_length=100):
    try:
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)

        for transcript in transcript_list:
            if transcript.language_code in languages:
                transcript = transcript.fetch()
                break
        else:
            transcript = transcript_list.find_transcript(languages).fetch()

        # Format and save the transcript
        formatter = TextFormatter()
        formatted_transcript = formatter.format_transcript(transcript)
        with open(transcript_filename, "w", encoding="utf-8") as f:
            f.write(formatted_transcript)
        print(f"Transcript saved to {transcript_filename}")


        # Summarize the transcript
        full_text = formatter.format_transcript(transcript).replace('\n', ' ')
        summarizer = pipeline("summarization", model="google-t5/t5-small", revision="df1b051") # You can try other models like "facebook/bart-large-cnn" as well
        summary_text = summarizer(full_text, min_length=min_length, max_length=max_length)[0]['summary_text']


        # Save the summary
        with open(summary_filename, "w", encoding="utf-8") as f:
            f.write(summary_text)
        print(f"Summary saved to {summary_filename}")
        print("\nSummary:")
        print(summary_text)


    except Exception as e:
        print(f"An error occurred: {e}")


# Example usage:
video_id = "videoID"
get_transcript_and_summary(video_id, transcript_filename="transcripts/name.txt", summary_filename="summaries/name.md") 
"@

    # reel
    Set-Content -Path "scripts/reel.py" -Value @"
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
"@
}

function setProject {
    Write-Host "🏗️ Setting project" -ForegroundColor $YELLOW

    # Call functions to create structure and generate tables
    createStructure
    geTranscript

    # Check if the system is a Mac
    if ($env:OS -eq "Unix" -or $env:OSTYPE -eq "darwin") {
        # Activate virtual environment on macOS
        .venv/bin/activate
    } else {
        # Activate virtual environment on Windows
        .\.venv\Scripts\Activate.ps1
    }

    Write-Host "🏗️ Set process completed successfully." -ForegroundColor $YELLOW
}
# Call the main function
setProject