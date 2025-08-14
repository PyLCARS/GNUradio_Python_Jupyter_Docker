#!/bin/bash

# Debug script to check directories and permissions

echo "Current directory: $(pwd)"
echo "User: $(whoami) (UID: $(id -u), GID: $(id -g))"
echo ""
echo "Checking directories:"
for dir in notebooks flowgraphs scripts data; do
    if [ -d "$dir" ]; then
        echo "✓ $dir exists"
        ls -ld "$dir"
    else
        echo "✗ $dir MISSING"
        echo "  Creating $dir..."
        mkdir -p "$dir"
        if [ $? -eq 0 ]; then
            echo "  ✓ Created successfully"
        else
            echo "  ✗ Failed to create"
        fi
    fi
done

echo ""
echo "Parent directory info:"
ls -ld .
echo ""
echo "Mount information:"
mount | grep "$(pwd)" || echo "Not a mount point"
df -h .
