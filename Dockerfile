FROM python:3.10-slim AS proto-builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY proto/ proto/
COPY build_proto.sh .
RUN chmod +x build_proto.sh && ./build_proto.sh

FROM python:3.10-slim

WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONPATH=/app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg && \
    rm -rf /var/lib/apt/lists/*

# Add OnlyOffice repository and install documentbuilder
RUN echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" \
    | tee /etc/apt/sources.list.d/onlyoffice.list && \
    curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --dearmor -o /usr/share/keyrings/onlyoffice.gpg && \
    apt-get update && \
    apt-get install -y --no-install-recommends onlyoffice-documentbuilder && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set PATH for documentbuilder
ENV PATH="/opt/onlyoffice/documentbuilder/:$PATH"

# Copy application code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY --from=proto-builder /build/generated/ /app/generated/

# Expose the gRPC port
EXPOSE 50051

# Run your gRPC server
CMD ["python3", "main.py"]
