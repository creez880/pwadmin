#!/bin/bash

# Ensure the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# Install Java if not installed
if ! command -v java &> /dev/null || ! command -v javac &> /dev/null; then
  echo "Installing Java..."
  apt update
  apt install -y openjdk-17-jdk
fi

# Verify Java installation
if ! command -v java &> /dev/null || ! command -v javac &> /dev/null; then
  echo "Java installation failed. Please check your system."
  exit 1
fi

# Define the base directory (starting point)
WEB_INF_DIR="./WEB-INF"

# Verify the WEB-INF directory exists
if [ ! -d "$WEB_INF_DIR" ]; then
  echo "Error: WEB-INF directory not found in the current path."
  exit 1
fi

# Find all Java source files in the entire WEB-INF directory tree
JAVA_FILES=$(find "$WEB_INF_DIR" -type f -name "*.java")
if [ -z "$JAVA_FILES" ]; then
  echo "Error: No Java files found in $WEB_INF_DIR."
  exit 1
fi

# Construct the dynamic classpath by including all directories under WEB-INF
CLASSPATH=$(find "$WEB_INF_DIR" -type d | tr '\n' :)

# Define the output directory for compiled classes
OUTPUT_DIR="$WEB_INF_DIR/classes"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Compile all Java files dynamically
echo "Compiling all Java files found under $WEB_INF_DIR..."
javac -d "$OUTPUT_DIR" -cp "$CLASSPATH" $JAVA_FILES

# Check the compilation result
if [ $? -eq 0 ]; then
  echo "Compilation successful. All classes are in $OUTPUT_DIR."
else
  echo "Compilation failed. Check the output above for errors."
  exit 1
fi

echo "Compilation completed successfully."
