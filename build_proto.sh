#!/bin/bash

set -e

PROTO_DIR="proto"
OUT_DIR="generated"
TEMP_DIR="temp_protos"

# Ensure output directory exists and is clean
rm -rf "$OUT_DIR" "$TEMP_DIR"
mkdir -p "$OUT_DIR" "$TEMP_DIR"

# Install grpc_tools if not available
if ! python3 -c "import grpc_tools.protoc" &>/dev/null; then
    echo "grpc_tools not found. Installing..."
    python3 -m pip install grpcio grpcio-tools
fi

echo "Copying proto files to temporary directory..."
cp "$PROTO_DIR/google/api/annotations.proto" "$TEMP_DIR/annotations.proto"
cp "$PROTO_DIR/google/api/http.proto" "$TEMP_DIR/http.proto"
cp "$PROTO_DIR/onlyoffice.proto" "$TEMP_DIR/onlyoffice.proto"

echo "Updating import paths..."
sed -i 's|import "google/api/http.proto"|import "http.proto"|g' "$TEMP_DIR/annotations.proto"
sed -i 's|import "google/api/annotations.proto"|import "annotations.proto"|g' "$TEMP_DIR/onlyoffice.proto"

echo "Compiling proto files..."
cd "$TEMP_DIR"
ls -la  # Debug: show contents of temp directory

# Compile each proto file individually
for proto in *.proto; do
    echo "Compiling $proto..."
    python3 -m grpc_tools.protoc \
        --proto_path=. \
        --python_out=. \
        --grpc_python_out=. \
        "$proto"
done

echo "Generated files:"
ls -la  # Debug: show generated files

# Create output directory if it doesn't exist
mkdir -p "../$OUT_DIR"

# Move generated files to output directory
echo "Moving generated files to $OUT_DIR..."
mv *.py "../$OUT_DIR/"

# Add __init__.py file
echo "Adding __init__.py file..."
cat > "../$OUT_DIR/__init__.py" << EOL
from . import http_pb2, http_pb2_grpc
from . import annotations_pb2, annotations_pb2_grpc
from . import onlyoffice_pb2, onlyoffice_pb2_grpc

__all__ = [
    'http_pb2', 'http_pb2_grpc',
    'annotations_pb2', 'annotations_pb2_grpc',
    'onlyoffice_pb2', 'onlyoffice_pb2_grpc'
]
EOL

# Clean up
cd ..
rm -rf "$TEMP_DIR"

echo "✅ All .proto files compiled successfully into $OUT_DIR/"
