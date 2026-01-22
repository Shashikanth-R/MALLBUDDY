
import os
import sys
import traceback
from google import genai
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_gemini():
    with open('gemini_test_output.txt', 'w', encoding='utf-8') as f:
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            f.write("❌ Error: GEMINI_API_KEY not found in environment\n")
            return

        f.write(f"✅ Found API Key: {api_key[:5]}...{api_key[-5:]}\n")

        try:
            client = genai.Client(api_key=api_key)
            
            f.write("\nTesting 2.5 Flash with NEW API KEY...\n")
            
            models_to_test = [
                'models/gemini-2.5-flash',
                'models/gemini-flash-latest'
            ]
            
            for model in models_to_test:
                f.write(f"\nTesting model: {model}...\n")
                try:
                    response = client.models.generate_content(
                        model=model,
                        contents="Say hello!"
                    )
                    f.write(f"✅ Success with {model}! Response: {response.text}\n")
                except Exception as e:
                    f.write(f"❌ Error with {model}: {str(e)}\n")

        except Exception as e:
            f.write(f"❌ Critical Error: {str(e)}\n")

if __name__ == "__main__":
    test_gemini()
