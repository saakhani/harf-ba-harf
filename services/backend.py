!pip install pyngrok pyannote.audio pydub fastapi uvicorn python-multipart --quiet
!pip install google-cloud-firestore --quiet

service_account_key ={
  "type": "service_account",
  "project_id": "fyp-harfbaharf",
  "private_key_id": "3333db1868dac77db7b1cacc19b462868407ff7c",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCrTvDKPCI5mMlC\nnVvr69qRAFZzARx0MX30nXCQppZCdGWkTkvMj+OakhTXBSgpbFLxnzJ7eOqtljBl\nhZkf0YmY9wDD/sHFQD/cxlbDFaoz4W9rjIhicLRJVnWoM2WASRcBTuCjmN9KUIr3\nFA7IyXQdyIHR00j1U0IteIUdnHDy21z+NYKp1ZdLngmKRpxvasc/9QKrmzAra19d\nGD90LPNo68oojxZVtVJ4LgOKfCCMB4ffhhUrSTZmjdsutfG579j5EAQHDdBLYoPU\nXSmHVkUJzxfpULg6MlmOZ2HZnbQVWDb67zkxLVU8kuTklpQoYKbXlBverXuz4Akr\nwRov0KS1AgMBAAECggEAHfz5MOXa9es1nCgwzblhbw24lHRG115MltQyvteyqRp4\nKo2cPkiYBth4tnVMJQg18t8z9qJhrpaCjVsYRZYoOLNQmn7Py+hl5Y+A47C4tVFK\n8HBO9bCWFtqASTwKEi15TfzRXUInIHq+AOeteN+vKIGPnDwY4v06sfwNjXPz38dW\nCpCE9sQgAQGOSfJoc+V+2tAb0HCXPcxAATcHH63iQhLC8qNolUm4PngLKYAcIbAz\n44IWxAxzV235rfcaO73CXAL0QXenNuh67GkFhYljYGrJFm/hLWzWS+S0dlRXpNNB\neIaRttjC3EIf/GZ4uD/BOr6v+BZrPrC06faH9MFRgQKBgQDrfAM0Xquo19HtBbQ3\nrHmSG7Qi5furNY8wrcnz3GSQxSZf9DziOQ7Yd23W33aOyPioxWLYp3ibyK7FiFnY\nN1lH8MLnngMYd26XaOtZRBwn0W250raizDxdSrhY1na9GO9U8kr3OShkiZS7ESIC\nkMTpZWsSSxc1vAjmRKaLAe6R9QKBgQC6O52AtMwgqAt0dUsaFINWfpfobcYsu39W\nVoRMoDqAbiCXIApp6xVpOsW9LIy+/Hnu9nrhbNZoerJ2/zsl9CrxWIONPnUKlDJc\ny+666BYoHSoeDXnhuH12GE4J2SwetnTyxjjxdgGIXlrzn8mmc3twzscBl9FrwT0Q\nvw/lGAJPwQKBgQDpY73hV7sW2uBq5G5bh4vuLZr5w6sNY0YJ3xT7pwHdIikIjQ8S\nv65hCO1KO6xLlBAvZYK0bDdzXxEpIhy52RGZ5Zum58r1otlvI0Ou83xcUotH0vnE\nnFtvszDGi7ifbmk2bfWy1WmdS2aniTGGDWm8URIvzVCxpy3C22Oc/ksvSQKBgQCW\n/aSqaGukAnsfFcYpQ/5kT0k8glwNgoswZf7n3XTxEdjMjobC732xjpwpz4fhhPQb\nYa2pPUPs+6XcQv0ivX9fpAMsrjnYtOTMRe+tjGQCa/rs2MI71wepivUimPhjgkz5\nVOtwIdwGQ3H8Wk307WZkxNGmof+CHO80t6Pce4XMQQKBgGRAD3CzZGETtE2ai63D\np3Wc9Bhd8ahim5o1U9itqFlyMZiUYKjKeU6VAW33KuySF9Uh87KoUWzqABTMnvas\nTUGX9ocbsrjvLpCBlEP7MjwVdheR/UynYjW6Ffn0WoFVo4+X9RZUOR3DDyXBEwlA\nV0ROmS5N2ieB1e2uMU15zzTc\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@fyp-harfbaharf.iam.gserviceaccount.com",
  "client_id": "108201991306169920765",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40fyp-harfbaharf.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}



import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate(service_account_key)
firebase_admin.initialize_app(cred)
db = firestore.client()

import nest_asyncio
from pyngrok import ngrok
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse, HTMLResponse
from datetime import datetime
import tempfile, os, torch, torchaudio, gc, json
from pydub import AudioSegment
from typing import List
from pyannote.audio import Pipeline as DiarizationPipeline
from transformers import pipeline, AutoProcessor, AutoModelForSpeechSeq2Seq, MBart50Tokenizer, MBartForConditionalGeneration
import threading
import time
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
import traceback
# ------------------ Setup ------------------
device = "cuda" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32
print(device)
print(torch_dtype)


NGROK_AUTHTOKEN = "2wVJam0DHTNJ4tCdn6KruZSSVJh_4c7p2JxGgF1gmyhX2mMLP"
hf_token = "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"
cached_transcript = []

# ------------------ Load Models ------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


diar_pipeline = DiarizationPipeline.from_pretrained("pyannote/speaker-diarization-3.1", use_auth_token=hf_token).to(torch.device(device))

processor = AutoProcessor.from_pretrained("openai/whisper-large-v3-turbo")
model = AutoModelForSpeechSeq2Seq.from_pretrained("openai/whisper-large-v3-turbo", torch_dtype=torch_dtype).to(device)

pipe = pipeline("automatic-speech-recognition",
    model=model,
    tokenizer=processor.tokenizer,
    feature_extractor=processor.feature_extractor,
    chunk_length_s=30,
    torch_dtype=torch_dtype,
    device=0 if device == "cuda" else -1
)

summarizer_tokenizer = MBart50Tokenizer.from_pretrained("Mudasir692/bart-urdu-summarizer")
summarizer_model = MBartForConditionalGeneration.from_pretrained("Mudasir692/bart-urdu-summarizer").to(device)

generate_kwargs = {
    "return_timestamps": True,
    "language": 'ur',
}

# ------------------ Utilities ------------------
def ensure_format(audio_path, original_filename):
    ext = os.path.splitext(original_filename)[1].lower()
    audio = AudioSegment.from_file(audio_path)

    # Fix: pad raw data to whole number of frames
    frame_size = audio.frame_width
    raw_data = audio.raw_data
    remainder = len(raw_data) % frame_size
    if remainder != 0:
        print(f"Padding audio: {remainder} bytes to align frames")
        raw_data += b'\0' * (frame_size - remainder)
        audio = AudioSegment(
            data=raw_data,
            sample_width=audio.sample_width,
            frame_rate=audio.frame_rate,
            channels=audio.channels
        )

    # Only allow .wav, .mp3, .m4a
    if ext not in [".wav", ".mp3", ".m4a"] or audio.frame_rate != 16000 or audio.channels != 1:
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            audio.set_frame_rate(16000).set_channels(1).export(tmp.name, format="wav")
            return tmp.name
    return audio_path

# ---------------------- Repetition Cleaning Function ----------------------
def clean_repetitions(text, max_repeats=1):
    words = text.split()

    def remove_ngram_repeats(words, n):
        if len(words) < n:
            return words
        cleaned = []
        i = 0
        while i <= len(words) - n:
            ngram = tuple(words[i:i+n])
            repeat_count = 1
            while i + repeat_count * n <= len(words) - n and tuple(words[i + repeat_count * n:i + (repeat_count + 1) * n]) == ngram:
                repeat_count += 1
            repeats_to_add = min(repeat_count, max_repeats)
            for _ in range(repeats_to_add):
                cleaned.extend(ngram)
            i += repeat_count * n
        if i < len(words):
            cleaned.extend(words[i:])
        return cleaned

    for n in [3, 2, 1]:
        words = remove_ngram_repeats(words, n)

    return " ".join(words)

# ------------------ Routes ------------------
@app.get("/", response_class=HTMLResponse)
def main():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Harf Ba Harf - Urdu Audio App</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                background-color: #f9f9f9;
                padding: 50px;
            }
            input, button, textarea {
                margin: 10px;
                padding: 10px;
                font-size: 1em;
            }
            textarea {
                width: 80%;
                height: 150px;
            }
            .output {
                margin-top: 30px;
                white-space: pre-wrap;
                text-align: left;
                background-color: #fff;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
        </style>
    </head>
    <body>
        <h1>🎧 Harf Ba Harf</h1>
        <form id="upload-form">
            <input type="file" id="audio" accept="audio/*" required><br>
            <button type="submit">📥 Diarize & Transcribe</button>
        </form>
        <button onclick="summarize()">📝 Summarize</button>

        <div class="output">
            <h3>🗣 Transcript:</h3>
            <div id="transcript"></div>

            <h3>🧾 Summary:</h3>
            <div id="summary"></div>
        </div>

        <script>
            const backend = window.location.origin;

            document.getElementById("upload-form").onsubmit = async function (e) {
                e.preventDefault();
                const fileInput = document.getElementById("audio");
                const formData = new FormData();
                formData.append("audio", fileInput.files[0]);

                document.getElementById("transcript").innerText = "Processing...";
                const res = await fetch(${backend}/diarize_transcribe, {
                    method: "POST",
                    body: formData
                });

                const data = await res.json();
                if (data.transcript) {
                    document.getElementById("transcript").innerText = data.transcript.map(
                        t => ${t.speaker}: ${t.text}
                    ).join("\\n\\n");
                } else {
                    document.getElementById("transcript").innerText = data.error || "Failed to process.";
                }
            }

            async function summarize() {
                document.getElementById("summary").innerText = "Generating summary...";
                const res = await fetch(${backend}/summarize, {
                    method: "POST"
                });
                const data = await res.json();
                document.getElementById("summary").innerText = data.summary || data.error || "No summary.";
            }
        </script>
    </body>
    </html>
    """

@app.post("/diarize_transcribe")
async def diarize_transcribe(
    user_id: str = Form(...),
    meeting_id: str = Form(...),
    audio: UploadFile = File(...)):
      print("function accessed")
      try:
        global cached_transcript
        cached_transcript.clear()

        # Save the uploaded file temporarily
        raw = await audio.read()
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            tmp.write(raw)
            temp_audio_path = tmp.name

        # Validate & convert audio if necessary
        wav_path = ensure_format(temp_audio_path, audio.filename)

        diarization = diar_pipeline(wav_path)
        full_audio = AudioSegment.from_file(wav_path)

        segments = list(diarization.itertracks(yield_label=True))
        batched_audio, batched_speakers, batched_times, temp_files = [], [], [], []

        prev_speaker = None
        start_time = None
        current_audio = None

        for segment, _, speaker in segments:
            start_ms, end_ms = int(segment.start * 1000), int(segment.end * 1000)
            print(f"Segment: {segment}, Speaker: {speaker}, Start(ms): {start_ms}, End(ms): {end_ms}")
            if prev_speaker is None:
                start_time, current_audio = segment.start, full_audio[start_ms:end_ms]
                prev_speaker = speaker
            elif speaker == prev_speaker:
                current_audio += full_audio[start_ms:end_ms]
            else:
                with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                    current_audio.export(tmp.name, format="wav")
                    print(f"Exported temp file for speaker {prev_speaker}: {tmp.name}")
                    try:
                        audio_data, _ = torchaudio.load(tmp.name)
                        print(f"Loaded audio data shape: {audio_data.shape}")
                    except Exception as audio_err:
                        print(f"Error loading audio with torchaudio: {audio_err}")
                        raise
                    batched_audio.append(audio_data[0].numpy())
                    batched_speakers.append(prev_speaker)
                    batched_times.append(int(start_time))
                    temp_files.append(tmp.name)
                prev_speaker = speaker
                start_time = segment.start
                current_audio = full_audio[start_ms:end_ms]

        if current_audio:
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                current_audio.export(tmp.name, format="wav")
                print(f"Exported final temp file for speaker {prev_speaker}: {tmp.name}")
                try:
                    audio_data, _ = torchaudio.load(tmp.name)
                    print(f"Loaded audio data shape: {audio_data.shape}")
                except Exception as audio_err:
                    print(f"Error loading audio with torchaudio: {audio_err}")
                    raise
                batched_audio.append(audio_data[0].numpy())
                batched_speakers.append(prev_speaker)
                batched_times.append(int(start_time))
                temp_files.append(tmp.name)

        print(f"Total batched_audio segments: {len(batched_audio)}")
        results = pipe(batched_audio, generate_kwargs=generate_kwargs)

        for speaker, ts, res in zip(batched_speakers, batched_times, results):
            cached_transcript.append({
                "speaker": speaker,
                "timestamp_seconds": ts,
                "text": clean_repetitions(res["text"].strip())
            })

        duration_seconds = int(len(full_audio) / 1000)# Duration in seconds

        full_text = "\n".join([t["text"] for t in cached_transcript])
        inputs = summarizer_tokenizer(full_text, return_tensors="pt", max_length=1024, truncation=True)
        inputs = {k: v.to(device) for k, v in inputs.items()}
        summary_ids = summarizer_model.generate(inputs["input_ids"], max_length=500, min_length=100, num_beams=4)
        summary = summarizer_tokenizer.decode(summary_ids[0], skip_special_tokens=True)



# ✅ Write result to Firebase
        try:
          doc_ref = db.collection('users').document(user_id).collection('meetings').document(meeting_id)
          doc_ref.update({
              "status": "completed",
              "duration_seconds": duration_seconds,
              "transcript": cached_transcript,
              "updatedAt": firestore.SERVER_TIMESTAMP,
              "summary": summary
          })
        except Exception as firebase_error:
          print(f"⚠️ Firebase update error: {firebase_error}")


        for f in temp_files:
            os.remove(f)
        gc.collect()
        torch.cuda.empty_cache()

         # Return response with additional metadata
        return {
            "message": "Success",
            "duration_seconds": duration_seconds,
            "meeting_id": meeting_id
        }

      except Exception as e:
        print("Exception occurred in /diarize_transcribe:")
        traceback.print_exc()
        return JSONResponse(status_code=500, content={"error": str(e)})



# ------------------ Run FastAPI with ngrok ------------------


ngrok.set_auth_token("2wVJam0DHTNJ4tCdn6KruZSSVJh_4c7p2JxGgF1gmyhX2mMLP")  # replace this
public_url = ngrok.connect(8000)
print(f"🚀 App running at: {public_url}")

def run_api():
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

# Start FastAPI in a thread (Colab-safe)
nest_asyncio.apply()
threading.Thread(target=run_api).start()

# import time
# # Keep cell alive to show logs
while True:
    time.sleep(1)