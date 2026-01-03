#!/bin/bash
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "Custom Say - GIF to CLI Tool Setup"
echo "======================================"
echo ""

# Check for GIF file argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: No GIF file specified${NC}"
    echo "Usage: ./setup.sh <path-to-gif> [name] [width]"
    echo ""
    echo "Example: ./setup.sh mygif.gif customsay 64"
    echo "  - path-to-gif: Path to your GIF file"
    echo "  - name: (optional) Name for your CLI tool (default: customsay)"
    echo "  - width: (optional) ASCII art width in characters (default: 64)"
    exit 1
fi

GIF_FILE="$1"
TOOL_NAME="${2:-customsay}"
ASCII_WIDTH="${3:-64}"

# Validate GIF file exists
if [ ! -f "$GIF_FILE" ]; then
    echo -e "${RED}Error: GIF file not found: $GIF_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}Settings:${NC}"
echo "  GIF File: $GIF_FILE"
echo "  Tool Name: $TOOL_NAME"
echo "  ASCII Width: $ASCII_WIDTH"
echo ""

# Check dependencies
echo "Checking dependencies..."

if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick not found${NC}"
    echo "Install with:"
    echo "  Ubuntu/Debian: sudo apt install imagemagick"
    echo "  macOS: brew install imagemagick"
    echo "  Windows: choco install imagemagick"
    exit 1
fi

# Determine which ImageMagick command to use
if command -v magick &> /dev/null; then
    MAGICK_CMD="magick"
else
    MAGICK_CMD="convert"
fi

echo -e "${GREEN}✓${NC} ImageMagick found"

# Check for ASCII converter (prefer jp2a, fallback to ascii-image-converter)
ASCII_CONVERTER=""
if command -v jp2a &> /dev/null; then
    ASCII_CONVERTER="jp2a"
    echo -e "${GREEN}✓${NC} jp2a found"
elif command -v ascii-image-converter &> /dev/null; then
    ASCII_CONVERTER="ascii-image-converter"
    echo -e "${GREEN}✓${NC} ascii-image-converter found"
else
    echo -e "${YELLOW}Warning: No ASCII converter found${NC}"
    echo "Install one of:"
    echo "  jp2a: sudo apt install jp2a"
    echo "  ascii-image-converter: go install github.com/TheZoraiz/ascii-image-converter@latest"
    exit 1
fi

echo ""

# Step 1: Extract frames
echo "Step 1: Extracting GIF frames..."
rm -rf frames_temp
mkdir -p frames_temp

if [ "$MAGICK_CMD" = "magick" ]; then
    magick "$GIF_FILE" -coalesce frames_temp/frame_%03d.png
else
    convert "$GIF_FILE" -coalesce frames_temp/frame_%03d.png
fi

FRAME_COUNT=$(ls frames_temp/frame_*.png | wc -l)
echo -e "${GREEN}✓${NC} Extracted $FRAME_COUNT frames"

# Step 2: Convert to ASCII
echo ""
echo "Step 2: Converting frames to ASCII art..."
rm -rf frames
mkdir -p frames

for file in frames_temp/frame_*.png; do
    base=$(basename "$file" .png)

    if [ "$ASCII_CONVERTER" = "jp2a" ]; then
        jp2a --width=$ASCII_WIDTH "$file" > "frames/$base.txt"
    else
        ascii-image-converter "$file" --width $ASCII_WIDTH --save-txt --output "frames/$base.txt" 2>/dev/null || true
        # ascii-image-converter adds extra extension, fix it
        if [ -f "frames/$base.txt.txt" ]; then
            mv "frames/$base.txt.txt" "frames/$base.txt"
        fi
    fi

    echo -n "."
done

echo ""
echo -e "${GREEN}✓${NC} Converted $FRAME_COUNT frames to ASCII"

# Clean up temp files
rm -rf frames_temp

# Step 3: Generate frames.rs
echo ""
echo "Step 3: Generating src/frames.rs..."

# Count animation frames (frame_001 onwards)
ANIM_FRAME_COUNT=$((FRAME_COUNT - 1))

cat > src/frames.rs << EOF
use lazy_static::lazy_static;
use std::sync::Arc;

const ANIMATE_FRAMES_STR: [&str; $ANIM_FRAME_COUNT] = [
EOF

# Add include_str! for each frame (starting from frame_001)
for i in $(seq 1 $ANIM_FRAME_COUNT); do
    printf "    include_str!(\"../frames/frame_%03d.txt\"),\n" $i >> src/frames.rs
done

cat >> src/frames.rs << 'EOF'
];

#[derive(Debug, Clone)]
pub struct Frame {
    pub lines: Arc<[&'static str]>,
}

#[derive(Debug, Clone)]
pub struct AnimatedFrames {
    pub frames: Arc<[Frame]>,
    pub interval_ms: Arc<[u64]>,
}

impl AnimatedFrames {
    pub fn iter(&self) -> AnimatedFramesIterator {
        AnimatedFramesIterator {
            frames: self.frames.clone(),
            interval_ms: self.interval_ms.clone(),
            current_frame: 0,
        }
    }
}

pub struct AnimatedFramesIterator {
    frames: Arc<[Frame]>,
    interval_ms: Arc<[u64]>,
    current_frame: usize,
}

impl Iterator for AnimatedFramesIterator {
    type Item = (Frame, u64);

    fn next(&mut self) -> Option<Self::Item> {
        if self.frames.is_empty() || self.interval_ms.is_empty() {
            return None;
        }
        let max_index = self.frames.len().max(self.interval_ms.len()) - 1;
        if self.current_frame > max_index {
            return None;
        }
        let frame = self.frames[self.current_frame].clone();
        let interval = self.interval_ms[self.current_frame];
        self.current_frame += 1;
        Some((frame, interval))
    }
}

lazy_static! {
    pub static ref ANIMATE_FRAMES: AnimatedFrames = {
        let frames = ANIMATE_FRAMES_STR
            .iter()
            .map(|frame| Frame {
                lines: frame
                    .lines()
                    .map(|line| &line[0..line.len() - 1])
                    .collect(),
            })
            .collect::<Box<[Frame]>>();
        AnimatedFrames {
            frames: Arc::from(frames),
EOF

echo "            interval_ms: Arc::new([100; $ANIM_FRAME_COUNT])," >> src/frames.rs

cat >> src/frames.rs << 'EOF'
        }
    };
}
EOF

echo -e "${GREEN}✓${NC} Generated src/frames.rs with $ANIM_FRAME_COUNT animation frames"

# Step 4: Update Cargo.toml
echo ""
echo "Step 4: Updating Cargo.toml..."

# Update package name in Cargo.toml
sed -i.bak "s/^name = .*/name = \"$TOOL_NAME\"/" Cargo.toml
echo -e "${GREEN}✓${NC} Updated package name to: $TOOL_NAME"

# Step 5: Update CLI name
echo ""
echo "Step 5: Updating CLI configuration..."

sed -E -i.bak "s/#\[command\(name = \".*\"\)\]/#[command(name = \"$TOOL_NAME\")]/" src/cli.rs
echo -e "${GREEN}✓${NC} Updated CLI name to: $TOOL_NAME"

# Clean up backup files
rm -f Cargo.toml.bak src/cli.rs.bak

echo ""
echo -e "${GREEN}======================================"
echo "Setup Complete!"
echo "======================================${NC}"
echo ""
echo "Your custom CLI tool is ready!"
echo ""
echo "Next steps:"
echo "  1. Test your animation:"
echo "     cargo run -- animate"
echo ""
echo "  2. Build release version:"
echo "     cargo build --release"
echo ""
echo "  3. Install locally:"
echo "     cargo install --path ."
echo ""
echo "  4. Use your tool:"
echo "     $TOOL_NAME animate \"Hello World\""
echo ""
echo "To customize further:"
echo "  - Edit src/cli.rs to change descriptions"
echo "  - Edit Cargo.toml to update metadata"
echo "  - Adjust frame timing in src/frames.rs"
echo ""
