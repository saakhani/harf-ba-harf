import subprocess
import time
import urllib.parse
import os
import pyautogui
import re
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/trigger-zoom-bot', methods=['POST'])
def trigger_zoom_bot():
    data = request.json
    # Accept either a zoom_link or meeting_id/passcode
    zoom_link = data.get('zoom_link', '').strip()
    meeting_id = data.get('meeting_id', '').strip()
    passcode = data.get('passcode', '').strip()
    user_full_name = data.get('user_full_name', '').strip()
    recording_duration = int(data.get('recording_duration', 3600))

    if zoom_link:
        match = re.search(r"zoom\.us/j/(\d+).*?pwd=([\w-]+)", zoom_link)
        if match:
            meeting_id = match.group(1)
            passcode = match.group(2)
        else:
            return jsonify({'error': 'Could not parse meeting ID and passcode from the link.'}), 400
    if not meeting_id or not passcode:
        return jsonify({'error': 'Meeting ID and passcode are required.'}), 400
    first_name = user_full_name.split()[0] if user_full_name else "User"
    display_name = f"{first_name}'s urdu notetaker"

    zoom_url = f"zoommtg://zoom.us/join?action=join&confno={meeting_id}&pwd={urllib.parse.quote(passcode)}&uname={urllib.parse.quote(display_name)}"
    print(f"Launching Zoom app as '{display_name}'...")
    os.startfile(zoom_url)
    time.sleep(10)
    print("Attempting to click 'Join' button automatically...")
    pyautogui.press('enter')
    time.sleep(15)
    # Detect audio device automatically using FFmpeg
    ffmpeg_path = "ffmpeg"
    # List audio devices
    try:
        result = subprocess.run([
            ffmpeg_path, '-list_devices', 'true', '-f', 'dshow', '-i', 'dummy'
        ], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        result = e
    devices_output = result.stderr
    audio_devices = []
    for line in devices_output.splitlines():
        if '"' in line and 'audio devices' not in line:
            match = re.search(r'"(.+?)"', line)
            if match:
                audio_devices.append(match.group(1))
    # Prefer 'Stereo Mix', else first device
    preferred_device = None
    for dev in audio_devices:
        if 'stereo mix' in dev.lower():
            preferred_device = dev
            break
    if not preferred_device and audio_devices:
        preferred_device = audio_devices[0]
    if not preferred_device:
        return jsonify({'error': 'No audio device found for recording.'}), 500
    output_path = "~/meeting_audio4.wav"
    ffmpeg_command = [
        ffmpeg_path,
        '-f', 'dshow',
        '-i', f"audio={preferred_device}",
        '-t', str(recording_duration),
        output_path
    ]
    print(f"Recording audio from device: {preferred_device} ...")
    try:
        subprocess.run(ffmpeg_command)
        print("Recording complete.")
    except Exception as e:
        print(f"Error during recording: {e}")
    print("Done. You can now close Zoom manually.")
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)