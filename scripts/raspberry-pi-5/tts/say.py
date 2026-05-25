"""Synthesize text via piper and stream PCM to paplay."""

import subprocess
import sys
from pathlib import Path

from piper import PiperVoice

VOICE_PATH = Path(__file__).parent / "models" / "uk_UA-oleksa-high.onnx"


def main() -> None:
    if len(sys.argv) < 2:
        print('Usage: say.py "text"', file=sys.stderr)
        sys.exit(1)

    text = sys.argv[1]
    voice = PiperVoice.load(str(VOICE_PATH))

    player = subprocess.Popen(
        [
            "paplay",
            "--raw",
            "--format=s16le",
            "--channels=1",
            f"--rate={voice.config.sample_rate}",
        ],
        stdin=subprocess.PIPE,
    )

    for chunk in voice.synthesize(text):
        player.stdin.write(chunk.audio_int16_bytes)
    player.stdin.close()
    player.wait()


if __name__ == "__main__":
    main()