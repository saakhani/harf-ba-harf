import subprocess
import time
import urllib.parse
import os
import pyautogui

# Ask for dynamic credentials
meeting_id = input("Enter the Zoom Meeting ID (e.g. 72604094481): ").strip()
passcode = input("Enter the Zoom Passcode: ").strip()
display_name = input("Enter the name to display in the meeting: ").strip()
recording_duration = int(input("Enter recording duration in seconds (e.g. 3600): ").strip())

# Zoom meeting link for app
zoom_url = f"zoommtg://zoom.us/join?action=join&confno={meeting_id}&pwd={urllib.parse.quote(passcode)}&uname={urllib.parse.quote(display_name)}"

# Launch Zoom app with meeting details
print(f"Launching Zoom app as '{display_name}'...")
os.startfile(zoom_url)

# Wait for the Zoom app to open
time.sleep(10)

# Simulate pressing "Enter" to click the "Join" button
print("Attempting to click 'Join' button automatically...")
pyautogui.press('enter')

# Optional: wait a bit longer for audio to connect
time.sleep(15)

# Start recording using FFmpeg
ffmpeg_path = "C:/ffmpeg/ffmpeg-7.1.1-full_build/bin/ffmpeg.exe"
output_path = "C:/Users/DELL/Desktop/recordings/meeting_audio4.wav"
audio_device = "Stereo Mix (Realtek(R) Audio)"  # You can make this dynamic too71878107811

ffmpeg_command = [
    ffmpeg_path,
    '-f', 'dshow',713
    '-i', f"audio={audio_device}",
    '-t', str(recording_duration),
    output_path
]

print("Recording audio...")
try:
    subprocess.run(ffmpeg_command)
    print("Recording complete.")
except FileNotFoundError:
    print("FFmpeg not found. Check the ffmpeg_path.")

print("Done. You can now close Zoom manually.")