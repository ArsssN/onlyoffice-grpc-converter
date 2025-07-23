#!/bin/bash

set -e

PROTO_DIR="proto"
OUT_DIR="generated"

# Ensure output directory exists and is a Python package
mkdir -p $OUT_DIR
touch $OUT_DIR/__init__.py

# Install grpc_tools if not available
if ! python3 -c "import grpc_tools.protoc" &>/dev/null; then
    echo "grpc_tools not found. Installing..."
    python3 -m pip install grpcio grpcio-tools
fi

# Compile all .proto files in proto/ into generated/
for proto_file in "$PROTO_DIR"/*.proto; do
    echo "Compiling $proto_file..."
    python3 -m grpc_tools.protoc \
        --proto_path="$PROTO_DIR" \
        --python_out="$OUT_DIR" \
        --grpc_python_out="$OUT_DIR" \
        "$proto_file"
done

echo "✅ All .proto files compiled into $OUT_DIR/"
