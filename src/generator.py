from openai import OpenAI
import os
from dotenv import load_dotenv
import datetime

load_dotenv()

client = OpenAI()

def generate_script(analysis, video_title):
    try:
        prompt = f"""Create a 30-second Instagram reel script using these elements. Be descriptive and creative in visuals. Use real life scenarios of a person in visuals:
        - Engaging hook in first 3 seconds
        - 3 quick facts with visual suggestions
        - 1-2 opinions with contrasting visuals
        - Closing call-to-action
        - Text overlays and emoji suggestions
        
        Facts:
        {chr(10).join(analysis['facts'][:3])}
        
        Opinions:
        {chr(10).join(analysis['opinions'][:2])}
        
        Format:
        [Visual]: Description | [Text]: "Caption" | [Voiceover]: Script"""
        
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{
                "role": "user",
                "content": prompt
            }],
            temperature=0.7
        )
        
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"outputs/scripts/{video_title}_{timestamp}.txt"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        with open(filename, "w") as f:
            f.write(response.choices[0].message.content)
            
        return filename
    except Exception as e:
        print(f"Script generation error: {e}")
        return None