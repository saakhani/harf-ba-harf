import subprocess
import time
import urllib.parse
import pyautogui
import re
import psutil
import os
from flask import Flask, request, jsonify
import pygetwindow as gw  # Make sure you have this installed

# Global in-memory state for the current active meeting
active_meeting = {}

app = Flask(__name__)

def launch_zoom(meeting_id_zoom, passcode, display_name):
    zoom_url = f"zoommtg://zoom.us/join?action=join&confno={meeting_id_zoom}"
    if passcode:
        zoom_url += f"&pwd={urllib.parse.quote(passcode)}"
    zoom_url += f"&uname={urllib.parse.quote(display_name)}&mute=1"
    os.startfile(zoom_url)
    time.sleep(10)
    pyautogui.press('enter')
    time.sleep(15)
    pyautogui.hotkey('alt', 'a')  # mute

def record_audio(meeting_id_zoom, duration, preferred_device):
    output_path = os.path.expanduser(f"~/{meeting_id_zoom}_audio.wav")
    ffmpeg_command = [
        "ffmpeg", "-f", "dshow", "-rtbufsize", "512M",
        "-i", f"audio={preferred_device}",
        "-ar", "44100", "-ac", "2",
        "-af", "aresample=async=1",
        "-t", str(int(duration)), output_path
    ]
    proc = subprocess.Popen(ffmpeg_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    # Store the PID in the global dict
    active_meeting['meeting_id'] = meeting_id_zoom
    active_meeting['pid'] = proc.pid
    print(f"[record_audio] Set active_meeting: {{'meeting_id': {meeting_id_zoom}, 'pid': {proc.pid}}}")
    num_frames = None
    for line in proc.stdout:
        print(f"[ffmpeg] {line.strip()}")
        if "size=" in line and "time=" in line and "bitrate=" in line:
            # Try to extract frame count from ffmpeg output if available
            match = re.search(r"frame=\s*(\d+)", line)
            if match:
                num_frames = int(match.group(1))
    proc.wait()
    print(f"[record_audio] Recording finished.")
    # --- Fix WAV if ffmpeg was terminated and file is truncated ---
    if os.path.exists(output_path):
        try:
            import wave
            with wave.open(output_path, 'rb') as wf:
                wf.readframes(wf.getnframes())  # Try reading all frames
        except Exception as e:
            print(f"[record_audio] WAV file appears corrupt: {e}. Attempting to fix...")
            # Try to pad file to nearest frame size (4 bytes for 16-bit stereo)
            try:
                with open(output_path, 'rb+') as f:
                    data = f.read()
                    # WAV header is 44 bytes, frame size is 4 bytes for 16-bit stereo
                    frame_size = 4
                    remainder = (len(data) - 44) % frame_size if len(data) > 44 else 0
                    if remainder != 0:
                        pad = frame_size - remainder
                        print(f"[record_audio] Padding {pad} bytes to align frames.")
                        f.seek(0, 2)
                        f.write(b'\0' * pad)
            except Exception as fix_e:
                print(f"[record_audio] Failed to fix WAV file: {fix_e}")
    if num_frames is not None:
        print(f"[record_audio] Number of frames recorded: {num_frames}")
    else:
        print(f"[record_audio] Number of frames not found in ffmpeg output.")
    return output_path

def focus_zoom():
    try:
        zoom_windows = [w for w in gw.getWindowsWithTitle('Zoom') if w.isVisible]
        if zoom_windows:
            zoom_windows[0].activate()
            time.sleep(1)
    except Exception as e:
        print(f"Could not focus Zoom window: {e}")

def leave_zoom():
    try:
        focus_zoom()
        pyautogui.hotkey('alt', 'q')
        time.sleep(1)
        pyautogui.press('enter')
    except Exception as e:
        print(f"Error trying Alt+Q to leave Zoom: {e}")
        pyautogui.hotkey('alt', 'f4')

@app.route('/trigger-zoom-bot', methods=['POST'])
def trigger_zoom_bot():
    data = request.json
    zoom_link = data.get('zoom_link', '')
    meeting_id_zoom = data.get('meeting_id', '')
    passcode = data.get('passcode', '')
    user_name = data.get('user_full_name', 'User')
    duration = int(data.get('recording_duration', 3600))

    if zoom_link:
        match = re.search(r"zoom\.us/j/(\d+).*?pwd=([\w-]+)", zoom_link)
        if match:
            meeting_id_zoom, passcode = match.groups()
        else:
            match = re.search(r"zoom\.us/j/(\d+)", zoom_link)
            if match:
                meeting_id_zoom = match.group(1)
            else:
                return jsonify({'error': 'Invalid Zoom link'}), 400

    if not meeting_id_zoom:
        return jsonify({'error': 'Meeting ID required'}), 400

    display_name = f"{user_name.split()[0]}'s Urdu Notetaker"
    preferred_device = 'Microphone Array (Realtek(R) Audio)'

    try:
        launch_zoom(meeting_id_zoom, passcode, display_name)
        
        output_path = record_audio(meeting_id_zoom, duration, preferred_device)
        leave_zoom()
        # Upload audio to backend (ngrok) after recording
        ngrok_url = data.get('ngrok_url')
        meeting_doc_id = data.get('meeting_doc_id')
        user_id = data.get('user_id')
        if ngrok_url and meeting_doc_id and user_id:
            import requests
            files = {'audio': open(output_path, 'rb')}
            payload = {'meeting_id': meeting_doc_id, 'user_id': user_id}
            print(f"Uploading audio to backend: {ngrok_url}/diarize_transcribe ...")
            try:
                response = requests.post(f"{ngrok_url}/diarize_transcribe", files=files, data=payload)
                print(f"Backend response: {response.status_code} {response.text}")
            except Exception as e:
                print(f"Error uploading audio to backend: {e}")
        else:
            print("Missing ngrok_url, meeting_doc_id, or user_id; skipping upload.")
    except Exception as e:
        leave_zoom()
        # Clean up global state on error
        active_meeting.clear()
        return jsonify({'error': str(e)}), 500

    # Clean up global state after success
    active_meeting.clear()
    return jsonify({'status': 'success'})

@app.route('/stop-zoom-bot', methods=['POST'])
def stop_zoom_bot():
    # Use the global active_meeting dict
    if not active_meeting or 'pid' not in active_meeting:
        return jsonify({'error': 'No active meeting or PID found'}), 404
    pid = active_meeting['pid']
    print(f"[stop_zoom_bot] Attempting to terminate PID {pid}")
    try:
        proc = psutil.Process(pid)
        proc.terminate()
        try:
            proc.wait(timeout=5)
            print("[stop_zoom_bot] FFmpeg terminated.")
        except psutil.TimeoutExpired:
            proc.kill()
            print("[stop_zoom_bot] FFmpeg force-killed.")
    except Exception as e:
        return jsonify({'error': f"Could not stop recording: {e}"}), 500
    # Clean up global state after stopping
    active_meeting.clear()
    leave_zoom()
    return jsonify({'status': 'stopped'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
