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
video_id = "d8IZ0L5596s&t"
get_transcript_and_summary(video_id, transcript_filename="transcripts/Secrets of Reality.txt", summary_filename="summaries/Secrets of Reality.txt") 
