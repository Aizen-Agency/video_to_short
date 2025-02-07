# src/downloader.py (fixed version)
from pytube import YouTube
from moviepy.video.io.VideoFileClip import VideoFileClip  # New import style
import os
import requests
import yt_dlp

def download_video(url, output_path="inputs/videos"):
    try:
        os.makedirs(output_path, exist_ok=True)
        ydl_opts = {
            'outtmpl': os.path.join(output_path, '%(title)s.%(ext)s'),
            'format': 'bestvideo[height<=360][ext=mp4]+bestaudio[ext=m4a]/best[height<=360][ext=mp4]/best[height<=360]',
            'quiet': False,
            'no_warnings': False,
            'noplaylist': True,
            'http_headers': {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            }
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            return ydl.prepare_filename(info)
            
    except Exception as e:
        print(f"❌ Download failed: {str(e)}")
        return None

def extract_audio(video_path, audio_output="inputs/audio"):
    try:
        os.makedirs(audio_output, exist_ok=True)
        print(f"🔊 Extracting audio from {os.path.basename(video_path)}")
        
        # Use context manager for better resource handling
        with VideoFileClip(video_path) as video:
            audio_path = os.path.join(
                audio_output, 
                os.path.basename(video_path).replace(".mp4", ".mp3")
            )
            video.audio.write_audiofile(audio_path)
        
        print(f"✅ Audio saved: {os.path.basename(audio_path)}")
        return audio_path
        
    except Exception as e:
        print(f"❌ Audio extraction failed: {str(e)}")
        return None