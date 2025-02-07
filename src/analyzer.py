from openai import OpenAI
import os
from dotenv import load_dotenv
import re

load_dotenv()

client = OpenAI()

def classify_segment(segment):
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{
                "role": "user",
                "content": f"Classify this statement as 'fact', 'opinion', or 'neither'. Reply with only one word.\n\n{segment}"
            }],
            temperature=0.0
        )
        return response.choices[0].message.content.strip().lower()
    except Exception as e:
        print(f"Classification error: {e}")
        return 'neither'

def analyze_transcript(transcript):
    segments = re.split(r'(?<=[.!?]) +', transcript)
    analysis = {'facts': [], 'opinions': []}
    
    for segment in segments:
        if len(segment.strip()) < 5:
            continue
        result = classify_segment(segment)
        if result == 'fact':
            analysis['facts'].append(segment)
        elif result == 'opinion':
            analysis['opinions'].append(segment)
    
    return analysis