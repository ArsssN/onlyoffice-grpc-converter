#!/bin/bash

set -e

PROTO_DIR="proto"
OUT_DIR="generated"

# Ensure output directory exists
mkdir -p "$OUT_DIR"

# Install grpc_tools if not available
if ! python3 -c "import grpc_tools.protoc" &>/dev/null; then
    echo "grpc_tools not found. Installing..."
    python3 -m pip install grpcio grpcio-tools
fi

# Find all .proto files recursively inside $PROTO_DIR
proto_files=$(find "$PROTO_DIR" -name '*.proto')

for proto_file in $proto_files; do
    echo "Compiling $proto_file..."
    # Get the directory of the proto file relative to PROTO_DIR
    rel_dir=$(dirname "${proto_file#$PROTO_DIR/}")
    # Make sure the corresponding directory exists in OUT_DIR
    mkdir -p "$OUT_DIR/$rel_dir"
    # Compile proto file, outputting to correct subdirectory
    python3 -m grpc_tools.protoc \
        --proto_path="$PROTO_DIR" \
        --python_out="$OUT_DIR" \
        --grpc_python_out="$OUT_DIR" \
        "$proto_file"
done

# Add __init__.py recursively so all generated dirs are Python packages
find "$OUT_DIR" -type d -exec touch {}/__init__.py \;

# Move google apis output to a single root directory
echo "Moving files to final locations..."
cp "$OUT_DIR"/google/api/* "$OUT_DIR"

echo "✅ All .proto files compiled into $OUT_DIR/"
