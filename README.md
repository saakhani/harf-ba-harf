# Harf ba Harf — Urdu Transcription and Diarization

**Harf ba Harf** (حرف بہ حرف) is a full-stack system for **Urdu speech transcription and speaker diarization**, developed as a BSCS Final Year Project at the Institute of Business Administration (IBA), Karachi.

The project addresses the lack of reliable, integrated tools for conversational Urdu by combining automatic speech recognition (ASR), speaker diarization, and summarization into a single, end-to-end platform designed for real-world use cases such as meetings, lectures, and interviews.

🎥 **Demo:** https://youtu.be/b-bstnTaYms

---

## 📌 Problem Context

Urdu is the **11th most spoken language globally**, yet remains underrepresented in conversational ASR and diarization systems. While mature solutions exist for English and other high-resource languages, Urdu speakers—particularly professionals, students, and the hearing-impaired—lack dependable tools for capturing and structuring spoken content.

**Harf ba Harf** aims to bridge this gap by delivering a complete, user-facing system for:

* Accurate Urdu transcription
* Speaker-aware conversation segmentation ("who spoke when")
* Summarized meeting outputs

---

## ✨ Key Features

* 🎙️ **Urdu Automatic Speech Recognition** using Whisper (large-v3-turbo)
* 🗣️ **Speaker Diarization** using pyannote.audio
* 📱 **Flutter Mobile Application** (Android/iOS)
* ⚙️ **FastAPI Backend** with modular ML pipelines
* 📅 **Google Calendar Integration** for meeting scheduling
* 🤖 **Zoom Meeting Bot** for automated recording
* 🧠 **Urdu Summarization Engine** using mBART
* 🔐 **Firebase Integration** for authentication and data storage

---

## 🏗️ System Architecture

The system follows a client–server architecture:

```
Flutter Mobile App
   │
   │  REST API Requests / Audio Uploads
   ▼
FastAPI Backend (Python)
   │
   ├── Speaker Diarization (pyannote)
   ├── Audio Chunking & Preprocessing
   ├── Urdu Transcription (Whisper)
   ├── Summarization (mBART Urdu)
   └── Post-processing & Formatting
   │
   ▼
Firebase (Auth + Firestore)
```

Additional components:

* **ngrok** for dynamic backend exposure during development
* **Zoom Bot (FFmpeg-based)** to automatically join and record meetings

---

## 🛠️ Tech Stack

### Frontend

* Flutter (Dart)

### Backend

* FastAPI (Python)
* PyTorch
* Hugging Face Transformers

### Models

* **ASR:** openai/whisper-large-v3-turbo
* **Diarization:** pyannote/speaker-diarization-3.1
* **Summarization:** Mudasir692/bart-urdu-summarizer (mBART)

### Infrastructure & Services

* Firebase Authentication
* Firebase Firestore
* Firebase Remote Config
* ngrok
* FFmpeg

---

## 🔄 Audio Input Methods

Users can provide audio through multiple channels:

* **Automated Zoom Bot**: Joins meetings, records audio, and uploads automatically
* **In-app Recording**: Manual audio capture from the mobile app
* **Manual Upload**: Uploading pre-recorded audio files

All processed transcripts, summaries, and metadata are stored securely in Firebase.

---

## 📊 Evaluation & Results

The system was evaluated using **public Urdu datasets** for both transcription and diarization.

### Transcription Performance

* Evaluated using **Word Error Rate (WER)** and **Character Error Rate (CER)**
* Over **52%** of samples achieved **WER ≤ 0.2**
* Over **80%** of samples achieved **CER ≤ 0.1**

### Diarization Performance

* Evaluated using **Diarization Error Rate (DER)**
* **61%** of test samples achieved **DER = 0.0**
* Majority of samples remained below **DER ≤ 0.2**

These results demonstrate strong performance on real-world, multi-speaker Urdu conversations, with remaining challenges primarily in overlapping speech and accent variation.

---

## ⚠️ Limitations

* Backend currently relies on **ngrok** and local / Colab-based GPU instances
* Off-the-shelf models are used without extensive Urdu-specific fine-tuning
* Performance may degrade for heavy dialectal variation or fast-paced speech

---

## 🔮 Future Work

* Domain-specific fine-tuning for Urdu dialects
* Real-time transcription
* Named speaker identification
* Cloud deployment with persistent GPU infrastructure
* Improved handling of overlapping speech

---

## 🎓 Academic Context

* **Degree:** BS Computer Science
* **Institution:** Institute of Business Administration (IBA), Karachi
* **Semester:** Spring 2025
* **Advisors:**

  * Dr. Zain Uddin (Lecturer)
  * Mr. Adil Saleem (PhD Scholar)
* **Industry Mentorship:** Softech Worldwide

---

## 👥 Contributors

* **Saad Lakhani** — Backend Development, App Development, Evaluation
* Talal Khan — AI Models, Diarization Pipeline
* Nimra Humayun — UI/UX Design
* Maham Ahmed — UI/UX Design

---

## 📄 License

This repository is intended for **academic and research purposes**. Licensing terms can be added as needed.

---

> *Harf ba Harf — bringing Urdu speech to text, one word at a time.*
