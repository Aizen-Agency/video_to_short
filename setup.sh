#!/bin/bash

# Clean previous installation (optional)
rm -rf inputs/ outputs/ src/ .env requirements.txt test_urls.txt README.md

# Create directory structure
mkdir -p src inputs/{videos,audio} outputs/{transcripts,scripts}

# Create core files
touch .gitignore test_urls.txt README.md requirements.txt

# Add comprehensive .gitignore
cat > .gitignore <<EOF
# Environment
.env
venv/

# Input/Output directories
inputs/
outputs/

# Python
__pycache__/
*.py[cod]
.python-version

# Media files
*.mp4
*.mp3
*.wav
*.webm

# OS
.DS_Store
Thumbs.db

# Logs
*.log
EOF

# Create .env template
cat > .env <<EOF
OPENAI_API_KEY=your_api_key_here
YT_TEST_URL=https://www.youtube.com/watch?v=8SbUC-UaAxE  # Public test video
EOF

# Update requirements with specific versions
cat > requirements.txt <<EOF
openai>=1.12.0
pytube>=15.0.0
moviepy>=1.0.3
python-dotenv>=1.0.0
tqdm>=4.66.1
requests>=2.31.0
yt-dlp>=2023.11.16
EOF

# Create test URLs file with working example
cat > test_urls.txt <<EOF
https://www.youtube.com/watch?v=8SbUC-UaAxE  # Test video: "Happy People Dancing"
EOF

# Create updated Python files with error handling

# downloader.py (with pytube fixes)
cat > src/downloader.py <<EOF
from pytube import YouTube
from moviepy.editor import VideoFileClip
import os
import requests
from pytube import request

# Set custom headers to avoid 403 errors
request.default_headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

def download_video(url, output_path="inputs/videos"):
    try:
        os.makedirs(output_path, exist_ok=True)
        yt = YouTube(
            url, 
            use_oauth=True,
            allow_oauth_cache=True
        )
        yt.bypass_age_gate()
        
        print(f"⌛ Downloading: {yt.title}")
        video = yt.streams.filter(
            progressive=True,
            file_extension='mp4'
        ).order_by('resolution').desc().first()
        
        video_path = video.download(output_path=output_path)
        print(f"✅ Downloaded: {os.path.basename(video_path)}")
        return video_path
        
    except Exception as e:
        print(f"❌ Download failed: {str(e)}")
        return None

def extract_audio(video_path, audio_output="inputs/audio"):
    try:
        os.makedirs(audio_output, exist_ok=True)
        print(f"🔊 Extracting audio from {os.path.basename(video_path)}")
        
        video = VideoFileClip(video_path)
        audio_path = os.path.join(
            audio_output, 
            os.path.basename(video_path).replace(".mp4", ".mp3")
        )
        
        video.audio.write_audiofile(audio_path, logger=None)
        print(f"✅ Audio saved: {os.path.basename(audio_path)}")
        return audio_path
        
    except Exception as e:
        print(f"❌ Audio extraction failed: {str(e)}")
        return None
EOF

# transcriber.py (with error handling)
cat > src/transcriber.py <<EOF
from openai import OpenAI
import os
from dotenv import load_dotenv
from tqdm import tqdm

load_dotenv()
client = OpenAI()

def transcribe_audio(audio_path):
    try:
        print(f"🔍 Transcribing {os.path.basename(audio_path)}")
        
        with open(audio_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="text"
            )
            
        print("✅ Transcription successful")
        return transcript.strip()
        
    except Exception as e:
        print(f"❌ Transcription failed: {str(e)}")
        return None
EOF

# main.py (with progress tracking)
cat > src/main.py <<EOF
from downloader import download_video, extract_audio
from transcriber import transcribe_audio
from analyzer import analyze_transcript
from generator import generate_script
import os
from tqdm import tqdm

def process_video(url):
    try:
        print(f"\\n{'=' * 40}")
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
        
        print(f"\\n🎉 Script generated: {script_path}")
        print(f"{'=' * 40}\\n")
        
    except Exception as e:
        print(f"❌ Processing failed: {str(e)}")

if __name__ == "__main__":
    with open("test_urls.txt") as f:
        urls = [url.strip() for url in f.readlines() if url.strip()]
    
    for url in tqdm(urls, desc="Processing videos"):
        process_video(url)
EOF

# Update README with test instructions
cat > README.md <<EOF
# Video to Reel Script Converter

## 🚀 Quick Start
1. Add OpenAI API key to \`.env\`
   \`\`\`bash
   echo "OPENAI_API_KEY=your_key_here" > .env
   \`\`\`
   
2. Install dependencies
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`
   
3. Run with test video
   \`\`\`bash
   python src/main.py
   \`\`\`

📁 Outputs will be in \`outputs/scripts/\`

## 🔧 Requirements
- FFmpeg (for audio processing)
  \`\`\`bash
  # Ubuntu
  sudo apt install ffmpeg
  
  # MacOS
  brew install ffmpeg
  \`\`\`
EOF

# Install requirements in virtual environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Test installation
echo -e "\\n🔄 Testing installation..."
if python3 -c "import pytube, openai, moviepy"; then
    echo "✅ All dependencies installed successfully"
else
    echo "❌ Installation test failed"
    exit 1
fi

# Final instructions
echo -e "\\n🚀 Setup complete! To start:"
echo "1. Add your OpenAI API key to .env"
echo "2. Run: python src/main.py"
echo "3. Check outputs/scripts/ for generated content"