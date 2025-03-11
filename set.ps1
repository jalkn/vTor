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
    python -m pip install youtube-transcript-api

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

def get_youtube_transcript(video_id, languages=['en'], filename="transcripts/timeWisely.txt"):
    
    try:
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)

        for transcript in transcript_list:  # Try preferred languages first
            if transcript.language_code in languages:
                 transcript = transcript.fetch()
                 break
        else:                               # Fallback: Get first available transcript 
            transcript = transcript_list.find_transcript(languages).fetch()



        formatter = TextFormatter()
        formatted_transcript = formatter.format_transcript(transcript)

        with open(filename, "w", encoding="utf-8") as f:  # Use utf-8 encoding
            f.write(formatted_transcript)

        print(f"Transcript saved to {filename}")

    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage:
video_id = "mk5uTO-QEnE&t=547s"  # Replace with the actual video ID
get_youtube_transcript(video_id, "Learn How To Spend Your Time Wisely.txt") 
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