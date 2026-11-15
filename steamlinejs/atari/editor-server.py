#!/usr/bin/env python3
"""Serve bimbaj-editor.html with save, build and run endpoints.

    python3 editor-server.py [port]     then open http://localhost:8770/

Listens on localhost only. POST /api/save writes bimbaj.json, /api/build runs
build.sh and /api/run builds and starts the emulator (run-emulator).
"""

import json
import subprocess
import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CAMPAIGN = ROOT / "bimbaj.json"


def check_campaign(data):
    if not isinstance(data, dict) or not isinstance(data.get("items"), list):
        raise ValueError("Expected an object with an items list")
    for index, item in enumerate(data["items"]):
        kind = item.get("type") if isinstance(item, dict) else None
        if kind == "level":
            rows = item.get("rows")
            if not isinstance(rows, list) or not all(isinstance(row, str) for row in rows):
                raise ValueError(f"Item {index + 1}: rows must be a list of strings")
        elif kind == "text":
            if not isinstance(item.get("text"), str):
                raise ValueError(f"Item {index + 1}: text must be a string")
        else:
            raise ValueError(f"Item {index + 1}: unknown type {kind!r}")


def run(command, timeout):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=timeout)
    return {"ok": result.returncode == 0, "log": (result.stdout + result.stderr).strip()}


class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            self.path = "/bimbaj-editor.html"
        if self.path == "/api/ping":
            return self.reply({"ok": True, "server": "bimbaj"})
        return super().do_GET()

    def do_POST(self):
        try:
            if self.path == "/api/save":
                length = int(self.headers.get("Content-Length", 0))
                data = json.loads(self.rfile.read(length).decode("utf-8"))
                check_campaign(data)
                text = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
                CAMPAIGN.write_text(text, encoding="utf-8")
                return self.reply({"ok": True, "log": f"Saved {CAMPAIGN.name}"})
            if self.path == "/api/build":
                return self.reply(run(["sh", "build.sh"], 300))
            if self.path == "/api/run":
                built = run(["sh", "build.sh"], 300)
                if not built["ok"]:
                    return self.reply(built)
                subprocess.Popen(["sh", "run-emulator.sh"], cwd=ROOT,
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                 start_new_session=True)
                return self.reply({"ok": True, "log": built["log"] + "\nStarting the emulator..."})
            self.send_error(404)
        except (ValueError, json.JSONDecodeError, subprocess.TimeoutExpired) as error:
            self.reply({"ok": False, "log": str(error)}, 400)

    def reply(self, payload, status=200):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        if "/api/" in str(args[0] if args else ""):
            super().log_message(format, *args)


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8770
    server = ThreadingHTTPServer(("127.0.0.1", port), partial(Handler, directory=str(ROOT)))
    print(f"Bimbaj editor: http://localhost:{port}/", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
