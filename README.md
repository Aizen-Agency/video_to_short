# Video to Reel Script Converter

## 🚀 Quick Start
1. Add OpenAI API key to `.env`
   ```bash
   echo "OPENAI_API_KEY=your_key_here" > .env
   ```
   
2. Install dependencies
   ```bash
   pip install -r requirements.txt
   ```
   
3. Run with test video
   ```bash
   python src/main.py
   ```

📁 Outputs will be in `outputs/scripts/`

## 🔧 Requirements
- FFmpeg (for audio processing)
  ```bash
  # Ubuntu
  sudo apt install ffmpeg
  
  # MacOS
  brew install ffmpeg
  ```
