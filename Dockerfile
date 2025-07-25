FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY mcp_server.py linter.py ./

# MCP servers communicate via stdio, so we run directly
ENTRYPOINT ["python", "mcp_server.py"]
