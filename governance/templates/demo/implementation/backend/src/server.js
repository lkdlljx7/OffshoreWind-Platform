import http from "node:http";

const port = Number(process.env.PORT ?? 3101);

const server = http.createServer((request, response) => {
  if (request.url === "/api/health") {
    response.writeHead(200, { "content-type": "application/json; charset=utf-8" });
    response.end(JSON.stringify({ status: "ok", service: "demo-backend" }));
    return;
  }

  response.writeHead(404, { "content-type": "application/json; charset=utf-8" });
  response.end(JSON.stringify({ error: "not_found" }));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Demo backend listening on port ${port}`);
});
