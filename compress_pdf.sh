#!/bin/bash

INPUT="$(dirname "$0")/CV_FONTAN.pdf"
OUTPUT="$(dirname "$0")/CV_FONTAN_compressed.pdf"
TARGET=$((2 * 1024 * 1024))  # 2MB in bytes

DPI=300
STEP=25
MIN_DPI=72

echo "Target: below 2MB"
echo "Input:  $INPUT ($(( $(stat -c%s "$INPUT") / 1024 ))KB)"
echo ""

while [ $DPI -ge $MIN_DPI ]; do
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
       -dDownsampleColorImages=true -dColorImageDownsampleType=/Bicubic -dColorImageResolution=$DPI \
       -dDownsampleGrayImages=true  -dGrayImageDownsampleType=/Bicubic  -dGrayImageResolution=$DPI \
       -dDownsampleMonoImages=true  -dMonoImageResolution=$DPI \
       -dAutoFilterColorImages=false -dColorImageFilter=/DCTEncode \
       -dAutoFilterGrayImages=false  -dGrayImageFilter=/DCTEncode \
       -dNOPAUSE -dQUIET -dBATCH \
       -sOutputFile="$OUTPUT" "$INPUT"

    SIZE=$(stat -c%s "$OUTPUT")
    echo "DPI $DPI → $(( SIZE / 1024 ))KB"

    if [ $SIZE -lt $TARGET ]; then
        echo ""
        echo "Done: $OUTPUT at DPI=$DPI, size=$(( SIZE / 1024 ))KB"
        exit 0
    fi

    DPI=$(( DPI - STEP ))
done

echo ""
echo "Warning: could not reach 2MB even at minimum DPI ($MIN_DPI). Last output: $(( SIZE / 1024 ))KB"
