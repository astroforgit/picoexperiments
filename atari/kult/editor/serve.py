#!/usr/bin/env python3
"""Local asset editor. Original games are read-only; exports are downloads."""
import argparse,json,mimetypes,sys
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
from assets import public,export
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'diabolic'))
import workshop
class Handler(BaseHTTPRequestHandler):
    def send(self,status,body,kind):
        self.send_response(status);self.send_header('Content-Type',kind);self.send_header('Content-Length',str(len(body)));self.send_header('Cache-Control','no-store');self.send_header('X-Content-Type-Options','nosniff');self.end_headers();self.wfile.write(body)
    def do_GET(self):
        path=self.path.split('?')[0]
        if path=='/api/diabolic':
            self.send(200,json.dumps(workshop.public()).encode(),'application/json')
        elif path in ('/flight/','/flight.html','/flight.js','/flight.css','/flight-core.js'):
            name='flight.html' if path=='/flight/' else path[1:]
            self.send(200,(HERE/name).read_bytes(),mimetypes.guess_type(name)[0] or 'text/plain')
        elif path=='/flight/concept.png':
            self.send(200,(HERE.parent/'diabolic/art/generated-sprite-sheet.png').read_bytes(),'image/png')
        elif path.startswith('/api/project/'):

            try:self.send(200,json.dumps(public(path.rsplit('/',1)[-1])).encode(),'application/json')
            except ValueError as e:self.send(400,str(e).encode(),'text/plain')
        elif path in ('/web/', '/web/index.html', '/web/engine.js', '/web/game.js', '/web/space.js', '/web/renderer.js', '/web/style.css', '/web/assets.json', '/web/README.md'):
            name='index.html' if path=='/web/' else path.rsplit('/',1)[-1]
            file=HERE.parent/'web'/name
            if file.is_file(): self.send(200,file.read_bytes(),mimetypes.guess_type(name)[0] or 'text/plain')
            else: self.send(404,b'Not found','text/plain')
        elif path in ('/cetas-web/', '/cetas-web/index.html', '/cetas-web/engine.js', '/cetas-web/game.js', '/cetas-web/style.css', '/cetas-web/assets.json', '/cetas-web/README.md'):
            name='index.html' if path=='/cetas-web/' else path.rsplit('/',1)[-1]
            file=HERE.parent/'cetas-web'/name
            if file.is_file(): self.send(200,file.read_bytes(),mimetypes.guess_type(name)[0] or 'text/plain')
            else: self.send(404,b'Not found','text/plain')
        elif path in ('/','/index.html','/app.js','/core.js','/style.css'):
            name='index.html' if path=='/' else path[1:];self.send(200,(HERE/name).read_bytes(),mimetypes.guess_type(name)[0] or 'text/plain')
        else:self.send(404,b'Not found','text/plain')
    def do_POST(self):
        if not (self.path.startswith('/api/export/') or self.path in ('/api/diabolic/export','/api/diabolic/apply')):
            self.send(404,b'Not found','text/plain');return
        origin=self.headers.get('Origin')
        if origin and origin not in ('http://'+self.headers.get('Host',''),'https://'+self.headers.get('Host','')):
            self.send(403,b'Origin not allowed','text/plain');return
        try:
            size=int(self.headers.get('Content-Length','0'))
            if not 0<size<=2_000_000:raise ValueError('Invalid request size')
            edits=json.loads(self.rfile.read(size))
            if self.path in ('/api/diabolic/export','/api/diabolic/apply'):
                data=workshop.export(edits,apply=self.path.endswith('/apply'))
                if self.path.endswith('/apply'):
                    self.send(200,json.dumps({'ok':True,'bytes':len(data)}).encode(),'application/json');return
            else:data=export(self.path.rsplit('/',1)[-1],edits)
            self.send(200,data,'application/octet-stream')
        except (ValueError,KeyError,TypeError) as e:self.send(400,str(e).encode(),'text/plain')
    def log_message(self,fmt,*args):print(fmt%args,flush=True)
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--port',type=int,default=8772);args=ap.parse_args()
    server=ThreadingHTTPServer(('127.0.0.1',args.port),Handler)
    print(f'Kult + CETAS editor: http://127.0.0.1:{args.port}',flush=True);server.serve_forever()
if __name__=='__main__':main()
