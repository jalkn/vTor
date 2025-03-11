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
    python -m pip install youtube-transcript-api transformers

    # Create subdirectories
    Write-Host "Creating directory structure..." -ForegroundColor $GREEN
    $directories = @(
        "scripts",
        "transcripts",
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
        "scripts/geTranscript.py"
    )
    foreach ($file in $files) {
        if (-not (Test-Path $file)) {
            New-Item -Path $file -ItemType File -Force
        }
    }
}
function geTranscript {
    Write-Host "🏗️ Creating Excel Analyzer Script" -ForegroundColor $YELLOW
    # Create the Python script dynamically
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
video_id = "mk5uTO-QEnE"
get_transcript_and_summary(video_id, transcript_filename="transcripts/timeWisely.txt", summary_filename="summaries/timeWisely.txt") 
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