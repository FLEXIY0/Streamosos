#!/usr/bin/env bash
#
# Setup script for Streamosos (Linux / macOS).
# Creates a virtual environment, installs the package and checks for ffmpeg.
#
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { printf "${GREEN}==>${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}warning:${NC} %s\n" "$1"; }
error() { printf "${RED}error:${NC} %s\n" "$1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VENV_DIR=".venv"

# --- 1. Locate a suitable Python interpreter ---------------------------------
PYTHON=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON="$candidate"
        break
    fi
done

if [ -z "$PYTHON" ]; then
    error "Python 3.8+ is required but was not found in PATH."
    exit 1
fi

PY_VERSION="$("$PYTHON" -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
info "Using $PYTHON (version $PY_VERSION)"

# --- 2. Create / reuse the virtual environment -------------------------------
if [ ! -d "$VENV_DIR" ]; then
    info "Creating virtual environment in $VENV_DIR"
    "$PYTHON" -m venv "$VENV_DIR"
else
    info "Reusing existing virtual environment in $VENV_DIR"
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# --- 3. Install dependencies -------------------------------------------------
info "Upgrading pip"
python -m pip install --upgrade pip >/dev/null

info "Installing streamosos and its dependencies"
python -m pip install -e .

# --- 4. Check for ffmpeg / ffprobe -------------------------------------------
MISSING_FFMPEG=0
for tool in ffmpeg ffprobe; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        warn "$tool was not found in PATH."
        MISSING_FFMPEG=1
    fi
done

if [ "$MISSING_FFMPEG" -eq 1 ]; then
    warn "ffmpeg/ffprobe are required at runtime. Install them, e.g.:"
    case "$(uname -s)" in
        Darwin) echo "        brew install ffmpeg" ;;
        Linux)  echo "        sudo apt-get install -y ffmpeg   # Debian/Ubuntu" ;;
        *)      echo "        See https://ffmpeg.org/download.html" ;;
    esac
else
    info "ffmpeg and ffprobe are available."
fi

# --- 5. Done -----------------------------------------------------------------
echo
info "Setup complete!"
echo "  Activate the environment with:"
echo "      source $VENV_DIR/bin/activate"
echo "  Then run:"
echo "      streamosos \"https://my.mts-link.ru/.../record-new/123456789\""
