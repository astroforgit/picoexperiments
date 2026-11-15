#!/usr/bin/env python3
"""Keep the local workshop/game server running after the launcher exits."""
import argparse
import json
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent


def ready(url):
    try:
        with urllib.request.urlopen(url + '/api/project/kult', timeout=1) as response:
            return json.load(response).get('game') == 'kult'
    except (OSError, ValueError):
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8772)
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error('Port must be between 1 and 65535')
    url = f'http://127.0.0.1:{args.port}'
    if ready(url):
        print(f'Kult: {url}/web/\nCETAS: {url}/cetas-web/ (server already running)')
        return
    runtime = HERE / '.runtime'
    runtime.mkdir(exist_ok=True)
    log_path = runtime / f'server-{args.port}.log'
    with log_path.open('ab') as log:
        process = subprocess.Popen(
            [sys.executable, '-u', str(HERE / 'serve.py'), '--port', str(args.port)],
            cwd=HERE, stdin=subprocess.DEVNULL, stdout=log, stderr=log,
            start_new_session=True,
        )
    for _ in range(60):
        if process.poll() is not None:
            raise SystemExit(f'Server failed to start. See {log_path}')
        if ready(url):
            (runtime / f'server-{args.port}.pid').write_text(str(process.pid) + '\n')
            print(f'Kult game: {url}/web/\nCETAS game: {url}/cetas-web/\nPixel workshop: {url}/\nServer PID: {process.pid}\nLog: {log_path}')
            return
        time.sleep(.25)
    process.terminate()
    raise SystemExit(f'Server did not become ready. See {log_path}')


if __name__ == '__main__':
    main()
