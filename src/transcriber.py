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
