"""A tiny provisioning API for Lab 3.3. Start it:  python tools/mock_api.py
GET /health -> 200.
POST /subscribers  with JSON {"imsi": ..., "key": ...}  ->  201
Missing imsi -> 400."""
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer


class Api(BaseHTTPRequestHandler):
    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))) or b"{}")
        if self.path == "/subscribers" and body.get("imsi"):
            code, out = 201, {"status": "provisioned", "imsi": body["imsi"]}
        else:
            code, out = 400, {"error": "imsi required"}
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(out).encode())

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status": "up"}')

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8099
    HTTPServer(("127.0.0.1", port), Api).serve_forever()
