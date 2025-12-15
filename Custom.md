# A customization guide for yisangsay

**this guide is written with linxu priority. I dont know how shite works on mac**

## 1. Converting GIF to ASCII Art Frames

To replace the current ASCII frames with frames extracted from a custom gif, you must:

### Step 1: Extract GIF Frames

Use ImageMagick to extract individual frames from the GIF:

```bash
# Install ImageMagick (if not already installed)
# Windows (with chocolatey): choco install imagemagick
# Linux: sudo apt install imagemagick

# Extract frames
mkdir -p frames
cd frames
magick custom.gif -coalesce frame_%03d.png
cd ..
```

This will create numbered PNG files (frame_000.png, frame_001.png, etc.)

**Note:** frame_000 will be used as the static frame, and frame_001 onwards will be used for animations.

### Step 2: Convert Frames to ASCII

Use one of these tools to convert each frame to ASCII art:

#### Option A: jp2a (Recommended for Linux)
```bash
# Install jp2a
# Linux: sudo apt install jp2a

# Convert each frame (adjust width to 64 characters)
mkdir -p frames_ascii
for file in frames/frame_*.png; do
    base=$(basename "$file" .png)
    jp2a --width=64 "$file" > "frames_ascii/$base.txt"
done

# Move ASCII frames to the frames directory
mv frames_ascii/*.txt frames/
rm -rf frames_ascii
```

#### Option B: ascii-image-converter (Cross-platform)
```bash
# Install
go install github.com/TheZoraiz/ascii-image-converter@latest

# Convert frames
mkdir -p frames_ascii
for file in frames/frame_*.png; do
    base=$(basename "$file" .png)
    ascii-image-converter "$file" --width 64 --save-txt --output "frames_ascii/$base.txt"
done

# Move ASCII frames
mv frames_ascii/*.txt frames/
rm -rf frames_ascii
```

**Tips for better ASCII art:**
- **Width recommendations:**
  - Small/compact: 40-50 characters
  - Medium (default): 64 characters
  - Large/detailed: 80-100 characters
- Try different ASCII converters - each produces different results
- For colored output, jp2a supports `--color` flag
- Manually edit frames for better quality if needed
- Test different frame rates (see Step 3)

For publishing, the git repo will only include the frames folder with .txt files, not the source PNG/GIF files.

### Step 3: Update the Project

After generating your ASCII frames, you need to update `src/frames.rs`:

#### 3.1: Count Your Frames
```bash
# Count animation frames (excluding frame_000.txt which is static)
ls frames/frame_*.txt | grep -v frame_000 | wc -l
```

Let's say you have **N** animation frames (e.g., 29 frames from frame_001 to frame_029).

#### 3.2: Update src/frames.rs

Open `src/frames.rs` and update:

**A) Update the array size:**
```rust
// Change [&str; 29] to [&str; N] where N is your frame count
const ANIMATE1_FRAMES_STR: [&str; N] = [
    include_str!("../frames/frame_001.txt"),
    include_str!("../frames/frame_002.txt"),
    // ... add all your frames up to frame_N
];
```

**B) Add/remove frame entries:**
- If you have fewer frames, remove the extra `include_str!` lines
- If you have more frames, add more `include_str!` lines following the pattern

**C) Update the interval array:**
```rust
// Change [100; 29] to [100; N] where N matches your frame count
interval_ms: Arc::new([100; N]),
```

The number `100` is the milliseconds per frame. Adjust for different speeds:
- Fast animation: 50-75ms
- Normal: 100ms
- Slow: 150-200ms

**Example for 15 frames:**
```rust
const ANIMATE1_FRAMES_STR: [&str; 15] = [
    include_str!("../frames/frame_001.txt"),
    include_str!("../frames/frame_002.txt"),
    // ... through frame_015.txt
];

// In the lazy_static block:
interval_ms: Arc::new([100; 15]),  // 15 frames at 100ms each
```

**Example for variable frame timing:**
```rust
// Different timing for each frame
interval_ms: Arc::new([150, 75, 75, 200, 100, 100, 150, ...]),  // Must match frame count
```

#### 3.3: Test Your Animation
```bash
# Build the project
cargo build --release

# Test animation variant 1
cargo run -- animate -v 1

# Test animation variant 2
cargo run -- animate -v 2

# Test static frame
cargo run -- "Hello World"
```

### Troubleshooting

**"mismatched types" error:**
- Check that array sizes match: `[&str; N]` and `[100; N]` must have the same N
- Verify you have the correct number of `include_str!` entries

**Animation too fast/slow:**
- Adjust the interval_ms values (lower = faster, higher = slower)

**Frames look distorted:**
- Try different widths when converting (32, 48, 64, 80)
- Some GIFs work better at different resolutions

**Missing frames:**
- Ensure frame numbering is correct (frame_000, frame_001, etc.)
- Check that files are in the `frames/` directory
