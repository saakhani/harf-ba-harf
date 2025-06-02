# ------------------ Installations ------------------
# THIS IS TO BE RUN ON GOOGLE COLLAB, REMOVE IF RUNNING LOCALLY, INSTALL PACKAGES IN THE LOCAL ENVIRONMENT
!pip install pyngrok pyannote.audio pydub fastapi uvicorn python-multipart google-cloud-firestore --quiet

# ------------------ Imports ------------------
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
import firebase_admin
from firebase_admin import credentials, initialize_app
from google.cloud import firestore

# ------------------ Setup ------------------
device = "cuda" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32
print(device)
print(torch_dtype)

# ------------------ Environment Secrets ------------------
NGROK_AUTHTOKEN = "2wVJam0DHTNJ4tCdn6KruZSSVJh_4c7p2JxGgF1gmyhX2mMLP" # Saad's token

hf_token = "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" # Saad's token

service_account_key = {
  "type": "service_account",
  "project_id": "fyp-harfbaharf",
  "private_key_id": "f75a3e85812c562a5e85e4de5f3354630d805120",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCl2W8xpPEulwxG\n5qp4TbeXw55/m2KHYWLYnm/H4W6L+3lxb2kgtMrv1r5N00ktqGEJKTh9VKzTboZf\n/od31Rxp37IdFijd4PF5bgn3KDqQxSsh2rRgdvc0vfyfWlhVeitwhlX/gpJLtz6M\nmfMmNkkqJOIXHSSseczllQ4K+AhPFzHK4hNgzaYMvvye9T0Rss58bO2Ga+7zq7Sk\nuyuciQ2LpLuI8tFGYT6crz3LKj3wfzfUX2747Fa+LYh2mElGZwW5tnyGJsIU8tpi\n3CysfB6KCanxYqoyfhSHy/YvsQt3QT6r/Z9uzMMYfSGFY1Bet8ePJQJWhv/B+wJA\n6hUMdNGrAgMBAAECggEASzpQfKVDnQ14zSROCNm/wEBEQb+atqvO6VEchP7VZPuB\nf5m4htRbBOVUVvrSw7oPodcnv3nMFu+YViyfCBULmV6VbSojCVnCToFCVfDSd95n\njSimDueHhE31K9cQIF2VHKpikc6JS3zoC2C9cQTItSwbvb5DZ1SsQysUPpd5NV4k\noS5LFwbvhzxUCTcEwnbpn0YgUjAOGqnhevAoX/2OUgbVMFnHmS+PSSeSLeDdtzba\nB6PhaSWNEayL5rSPcC6GNyTMTEezh7BJs3jZ+8sN5X3IsOup+6KngqroDgHvdcpF\n0kIeQMwxzBPnxqs5cYdWcQFj1NloYhJq8O5N2DO6QQKBgQDpTgcFW4/TedbOyZ8v\nLTsiOF6O/0xZPf0HWjeM+ZIfvT2CDox030QI5UDYtIVJWEKktuLMyNqkW8TjI1EI\n4tHDdyGwd0gvD814GwyTx5lvd+qCegTzraxy8iS0m0k5/h2q6K+a4VKTqczpnBaU\nKIWy3V0hechOP5BusZZJ+FWSiwKBgQC1+5GjP/bmgirDKgXsMNJWDXFhprMBh9Vy\nD7U80tihWu14b8peen9nrOrmY6ZYbe5aPUGVKqlLmhHKtxNJi6Lp31k3se6Vx/Yj\nAy31191Ap83tUpdPEFt8bB2TH+gTrqvt+XkN/eYwJ0YqpPURL3r6qIiDz5EisFpT\ndcHPRtlBYQKBgDMcAdO9pDtqxJEWgEXgfcTYXnarHPmr58N1kxfSEJ3dYh0cvM5Z\nntjoCBWxLkXMDQVyfyrnkWZSKEauFPGCZvuQHJRA/VI5/wQhwNaa8lUGCxy8SFtt\nn4qq2zmpjxgiQDORt+6RD/sDRr2ikRux6OAvOFi+ChCCQkzNoKPhwDVTAoGBAJ9m\n3Pmu5JiiOcy7eXaaiRLhMYhEmRVlIryHL8w4L5Keb9WHri41hHWOjC8D6Ega+qXG\ndDSxqprTOHRlChromenbPm2/iGlgPqQKe+6Uh3PDyGfxaSHTBR+mH/2n/AOJg4Wu\neK+dz0wsipR96z+DZGg8yV8TqGBHMsdaJUpnF5PhAoGAKgxaOz6bC7bGEdIn1GE9\n2wTgk068i2hbwZNmPJsM8gl9f8GCA/amrU6ObhS4/BXz2x5cJSLAoBobRsB2KVmb\ncszwxf6lWbOOnz7LYCKsJCRpd3xDvA1l2kPSJoM/sUBmemYf1YbcP2KLczAsc89c\nvLFnQF5tkItk3kwmlqZMKdM=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@fyp-harfbaharf.iam.gserviceaccount.com",
  "client_id": "118362267373980250995",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40fyp-harfbaharf.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

# ------------------ Initializations ------------------

if not firebase_admin._apps:
    cred = credentials.Certificate(service_account_key)
    initialize_app(cred)

db = firestore.Client()
cached_transcript = []
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

    # Only allow .wav, .mp3, .m4a
    if ext not in [".wav", ".mp3", ".m4a"] or audio.frame_rate != 16000 or audio.channels != 1:
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            audio.set_frame_rate(16000).set_channels(1).export(tmp.name, format="wav")
            return tmp.name
    return audio_path

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
            if prev_speaker is None:
                start_time, current_audio = segment.start, full_audio[start_ms:end_ms]
                prev_speaker = speaker
            elif speaker == prev_speaker:
                current_audio += full_audio[start_ms:end_ms]
            else:
                with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                    current_audio.export(tmp.name, format="wav")
                    audio_data, _ = torchaudio.load(tmp.name)
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
                audio_data, _ = torchaudio.load(tmp.name)
                batched_audio.append(audio_data[0].numpy())
                batched_speakers.append(prev_speaker)
                batched_times.append(int(start_time))
                temp_files.append(tmp.name)

        results = pipe(batched_audio, generate_kwargs=generate_kwargs)

        for speaker, ts, res in zip(batched_speakers, batched_times, results):
            cached_transcript.append({
                "speaker": speaker,
                "timestamp_seconds": ts,
                "text": res["text"].strip()
            })

        for f in temp_files:
            os.remove(f)
        gc.collect()
        torch.cuda.empty_cache()

        duration_seconds = int(len(full_audio) / 1000)# Duration in seconds

        # Write result to Firebase
        try:
          doc_ref = db.collection('users').document(user_id).collection('meetings').document(meeting_id)
          doc_ref.update({
              "status": "completed",
              "duration_seconds": duration_seconds,
              "transcript": cached_transcript,
              "updatedAt": firestore.SERVER_TIMESTAMP
          })
        except Exception as firebase_error:
          print(f"⚠️ Firebase update error: {firebase_error}")


         # Return response with additional metadata
        return {
            "message": "Success",
            "duration_seconds": duration_seconds,
            "meeting_id": meeting_id
        }

      except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})


@app.post("/summarize")
def summarize():
    try:
        if not cached_transcript:
            return JSONResponse(status_code=400, content={"error": "No transcript available"})

        full_text = "\n".join([t["text"] for t in cached_transcript])
        inputs = summarizer_tokenizer(full_text, return_tensors="pt", max_length=1024, truncation=True)
        inputs = {k: v.to(device) for k, v in inputs.items()}
        summary_ids = summarizer_model.generate(inputs["input_ids"], max_length=500, min_length=100, num_beams=4)
        summary = summarizer_tokenizer.decode(summary_ids[0], skip_special_tokens=True)

        return {"summary": summary}

    except Exception as e:
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