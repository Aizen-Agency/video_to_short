from downloader import download_video, extract_audio
from transcriber import transcribe_audio
from analyzer import analyze_transcript
from generator import generate_script
import os
from tqdm import tqdm

def process_video(url):
    try:
        print(f"\n{'=' * 40}")
        print(f"Processing URL: {url}")
        
        # Download video
        video_path = download_video(url)
        if not video_path: return
        
        # Extract audio
        audio_path = extract_audio(video_path)
        if not audio_path: return
        
        # Transcribe audio
        transcript = transcribe_audio(audio_path)
        if not transcript: return
        
        # Analyze transcript
        analysis = analyze_transcript(transcript)
        
        # Generate script
        video_title = os.path.basename(video_path).rsplit('.', 1)[0]
        script_path = generate_script(analysis, video_title)
        
        print(f"\n🎉 Script generated: {script_path}")
        print(f"{'=' * 40}\n")
        
    except Exception as e:
        print(f"❌ Processing failed: {str(e)}")

if __name__ == "__main__":
    with open("test_urls.txt") as f:
        urls = [url.strip() for url in f.readlines() if url.strip()]
    
    for url in tqdm(urls, desc="Processing videos"):
        process_video(url)
