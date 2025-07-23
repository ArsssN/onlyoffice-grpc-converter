FROM python:3.10-slim AS builder
WORKDIR /build
RUN pip install --upgrade pip

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including curl, gnupg, wget, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Add OnlyOffice repository and install onlyoffice-documentbuilder
RUN echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" \
    | tee /etc/apt/sources.list.d/onlyoffice.list \
    && curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --dearmor -o /usr/share/keyrings/onlyoffice.gpg \
    && apt-get update \
    && apt-get install -y --no-install-recommends onlyoffice-documentbuilder \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set PATH if needed (confirm the actual path of documentbuilder binary)
ENV PATH="/opt/onlyoffice/documentbuilder/:$PATH"

# Copy your application code
WORKDIR /app
COPY . .

# Install Python dependencies from requirements.txt first
RUN pip install --no-cache-dir -r requirements.txt

# Make the build script executable and run it
RUN chmod +x build_proto.sh && ./build_proto.sh

# Install protobuf explicitly to ensure it's available
RUN pip install --no-cache-dir protobuf>=6.31.0

# Add generated directory to PYTHONPATH
ENV PYTHONPATH="/app:${PYTHONPATH}"

# Expose the gRPC port
EXPOSE 50051

# Run your gRPC server
CMD ["python3", "main.py"]
