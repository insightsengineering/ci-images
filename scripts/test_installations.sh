#!/usr/bin/env bash

set -eo pipefail

echo "🔎 Checking installations..."

function check_installation() {
    if command -v "$1" &> /dev/null
    then
        echo "✅ $1 is installed."
    else
        echo "❌ $1 is not installed."
        exit 1
    fi
}

declare -A bins=(
    [Python]="python"
    [Java]="java"
    [R]="R"
    [LaTeX]="pdflatex"
)

# for bin in "${!bins[@]}"; do
#     check_installation "${bins[$bin]}"
# done

R --version
java -version
python3 --version
pdflatex --version
