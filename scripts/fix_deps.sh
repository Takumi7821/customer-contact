#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/fix_deps.sh [VENV_DIR]
# Defaults to "env" when no argument is provided.

VENV_DIR=${1:-env}
PY="$VENV_DIR/bin/python"
PIP="$VENV_DIR/bin/pip"

if [ ! -x "$PY" ]; then
  echo "Virtual environment python not found at '$PY'. Activate or create the venv first."
  exit 1
fi

echo "Installing requirements.txt into virtualenv at '$VENV_DIR'..."
"$PIP" install -r requirements.txt

# List of importable package names to verify; if import fails, try to install the corresponding pip package
declare -a CHECK_PKGS=(
  "langchain_community:langchain-community"
  "chromadb:chromadb"
  "tiktoken:tiktoken"
  "langchain_openai:langchain-openai"
  "langchain_core:langchain-core"
  "langchain_classic:langchain-classic"
)

for entry in "${CHECK_PKGS[@]}"; do
  IFS=":" read -r module pkg <<< "$entry"
  if ! "$PY" -c "import ${module}" 2>/dev/null; then
    echo "Package for module '${module}' missing — installing '${pkg}'..."
    "$PIP" install "$pkg"
  else
    echo "Module '${module}' OK"
  fi
done

echo "Dependency check complete. You can start the app with: $VENV_DIR/bin/streamlit run main.py"
