# YouTube Transcript Summarizer

This PowerShell script sets up a Python project to download YouTube video transcripts, summarize them, and save both to separate files.

---

## Features

* Creates the necessary directory structure (scripts, transcripts, summaries).
* Sets up a Python virtual environment and installs required packages (youtube-transcript-api, transformers).
* Generates a Python script (`scripts/geTranscript.py`) to fetch and summarize transcripts.
* Handles transcript downloading in multiple languages, defaulting to English.
* Uses the `google/t5-small` model for summarization (can be easily changed to other models).
* Provides a clear and colorful output during the setup process.
* Cross-platform compatibility (macOS and Windows).

---

## Prerequisites

* **PowerShell:** This script is designed to run in PowerShell.
* **Python:**  Make sure Python is installed on your system. The script will create a virtual environment.

---

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/your-repository.git  # Replace with your repo URL
   cd your-repository
   ```

2. **Run the setup script:**

   ```powershell
   .\setup.ps1  (or ./setup.ps1 on macOS/Linux)
   ```

This script will:

* Create the project directory structure.
* Set up a Python virtual environment within the project folder.
* Install the necessary Python libraries within the virtual environment.
* Create the `scripts/geTranscript.py` script.

---

## Usage

To use the transcript summarizer:

1. **Activate the virtual environment:**

   ```bash
   # On Windows:
   .\.venv\Scripts\Activate.ps1

   # On macOS/Linux:
   source .venv/bin/activate
   ```

2. **Run the Python script:**

   ```bash
   python scripts/geTranscript.py
   ```
   The script currently uses the video ID "mk5uTO-QEnE" as a default example.  You'll need to modify the script to use your own video ID.


3. **Modify the `get_transcript_and_summary` function in `scripts/geTranscript.py`:**

   ```python
   video_id = "YOUR_VIDEO_ID"  # Replace with the actual YouTube video ID
   get_transcript_and_summary(video_id, transcript_filename="transcripts/your_transcript_name.txt", summary_filename="summaries/your_summary_name.txt")
   ```
   You can also change the `languages` parameter, `min_length`, and `max_length` of the summary as needed.

---

## Example

```python
# Example usage within geTranscript.py
video_id = "nLRL_NcnK-4" # ID of a video about neural networks
get_transcript_and_summary(video_id, transcript_filename="transcripts/neural_networks.txt", summary_filename="summaries/neural_networks.txt")
```

---

## Troubleshooting

* **Virtual Environment Issues:** If you have problems with the virtual environment, try deleting the `.venv` folder and running `setup.ps1` again.
* **Python Package Errors:**  Ensure that you're running the Python script within the activated virtual environment.
* **YouTube API Errors:**  The `youtube-transcript-api` library might raise exceptions if the video doesn't have transcripts or if there are issues connecting to YouTube. Refer to the library's documentation for more details.

---

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.