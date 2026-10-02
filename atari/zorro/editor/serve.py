#!/usr/bin/env python3
"""Serve the Zorro editor and let it save and run the edited game.

usage: python3 serve.py [port]        (default port 8765)
Then open http://localhost:8765 in a browser.

  GET  /              the editor
  GET  /game.xex      zorro_edited.xex if it exists, else the original
  GET  /original.xex  the original file
  POST /api/save      body = XEX bytes -> zorro_edited.xex
  POST /api/run       same, then starts it in Altirra (run-xex.sh)
"""
import http.server
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ORIGINAL = os.path.join(HERE, '..', 'Zorro (1985)(Datasoft)(US).xex')
EDITED = os.path.join(HERE, 'zorro_edited.xex')
RUN_XEX = os.path.join(HERE, '..', '..', '..', 'atari-vbxe-toolkit', 'scripts', 'run-xex.sh')
MAX_SIZE = 64 * 1024


class Handler(http.server.BaseHTTPRequestHandler):
    def send(self, code, body, ctype='text/plain; charset=utf-8', headers=()):
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        for k, v in headers:
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split('?')[0]
        if path in ('/', '/index.html'):
            body = open(os.path.join(HERE, 'index.html'), 'rb').read()
            self.send(200, body, 'text/html; charset=utf-8')
        elif path == '/game.xex':
            edited = os.path.exists(EDITED)
            body = open(EDITED if edited else ORIGINAL, 'rb').read()
            self.send(200, body, 'application/octet-stream',
                      [('X-Zorro-Source', 'edited' if edited else 'original')])
        elif path == '/original.xex':
            self.send(200, open(ORIGINAL, 'rb').read(), 'application/octet-stream')
        elif path == '/api/info':
            self.send(200, b'{"server": true}', 'application/json')
        else:
            self.send(404, b'not found')

    def do_POST(self):
        path = self.path.split('?')[0]
        if path not in ('/api/save', '/api/run'):
            self.send(404, b'not found')
            return
        n = int(self.headers.get('Content-Length', 0))
        if not 0 < n <= MAX_SIZE:
            self.send(400, b'bad size')
            return
        data = self.rfile.read(n)
        if data[:2] != b'\xff\xff':
            self.send(400, b'not an XEX file')
            return
        open(EDITED, 'wb').write(data)
        if path == '/api/run':
            subprocess.Popen(['sh', RUN_XEX, EDITED], stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL, start_new_session=True)
            self.send(200, b'saved zorro_edited.xex and started Altirra')
        else:
            self.send(200, b'saved zorro_edited.xex')

    def log_message(self, fmt, *args):
        sys.stderr.write('%s\n' % (fmt % args))


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    server = http.server.ThreadingHTTPServer(('127.0.0.1', port), Handler)
    print('Zorro editor: http://localhost:%d' % port)
    server.serve_forever()


if __name__ == '__main__':
    main()
