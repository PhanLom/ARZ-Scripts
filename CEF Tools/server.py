from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        with open("cef_dom_dump.html", "wb") as f:
            f.write(post_data)
        self.send_response(200)
        self.end_headers()
        print("[cef_dom_receiver] DOM saved to cef_dom_dump.html")

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"CEF DOM Receiver is running. Use POST to upload DOM.")

if __name__ == "__main__":
    httpd = HTTPServer(('localhost', 8081), Handler)
    print("[cef_dom_receiver] Listening on port 8081...")
    httpd.serve_forever()