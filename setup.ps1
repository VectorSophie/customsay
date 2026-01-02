# Custom Say - GIF to CLI Tool Setup (PowerShell)
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$GifFile,

    [Parameter(Position=1)]
    [string]$ToolName = "customsay",

    [Parameter(Position=2)]
    [int]$AsciiWidth = 64
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Custom Say - GIF to CLI Tool Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Validate GIF file exists
if (-not (Test-Path $GifFile)) {
    Write-ColorOutput Red "Error: GIF file not found: $GifFile"
    exit 1
}

Write-Host "Settings:" -ForegroundColor Green
Write-Host "  GIF File: $GifFile"
Write-Host "  Tool Name: $ToolName"
Write-Host "  ASCII Width: $AsciiWidth"
Write-Host ""

# Check dependencies
Write-Host "Checking dependencies..."

# Check for ImageMagick
$magickCmd = $null
if (Get-Command magick -ErrorAction SilentlyContinue) {
    $magickCmd = "magick"
    Write-Host "✓ ImageMagick found" -ForegroundColor Green
} elseif (Get-Command convert -ErrorAction SilentlyContinue) {
    $magickCmd = "convert"
    Write-Host "✓ ImageMagick found" -ForegroundColor Green
} else {
    Write-ColorOutput Red "Error: ImageMagick not found"
    Write-Host "Install with: choco install imagemagick"
    exit 1
}

# Check for ASCII converter
$asciiConverter = $null
if (Get-Command jp2a -ErrorAction SilentlyContinue) {
    $asciiConverter = "jp2a"
    Write-Host "✓ jp2a found" -ForegroundColor Green
} elseif (Get-Command ascii-image-converter -ErrorAction SilentlyContinue) {
    $asciiConverter = "ascii-image-converter"
    Write-Host "✓ ascii-image-converter found" -ForegroundColor Green
} else {
    Write-ColorOutput Yellow "Warning: No ASCII converter found"
    Write-Host "Install ascii-image-converter with:"
    Write-Host "  go install github.com/TheZoraiz/ascii-image-converter@latest"
    Write-Host ""
    Write-Host "Or use WSL to install jp2a"
    exit 1
}

Write-Host ""

# Step 1: Extract frames
Write-Host "Step 1: Extracting GIF frames..."
if (Test-Path "frames_temp") {
    Remove-Item -Recurse -Force "frames_temp"
}
New-Item -ItemType Directory -Path "frames_temp" | Out-Null

if ($magickCmd -eq "magick") {
    & magick $GifFile -coalesce "frames_temp/frame_%03d.png"
} else {
    & convert $GifFile -coalesce "frames_temp/frame_%03d.png"
}

$frameCount = (Get-ChildItem "frames_temp/frame_*.png").Count
Write-Host "✓ Extracted $frameCount frames" -ForegroundColor Green

# Step 2: Convert to ASCII
Write-Host ""
Write-Host "Step 2: Converting frames to ASCII art..."
if (Test-Path "frames") {
    Remove-Item -Recurse -Force "frames"
}
New-Item -ItemType Directory -Path "frames" | Out-Null

Get-ChildItem "frames_temp/frame_*.png" | ForEach-Object {
    $base = $_.BaseName

    if ($asciiConverter -eq "jp2a") {
        & jp2a --width=$AsciiWidth $_.FullName | Out-File -Encoding ASCII "frames/$base.txt"
    } else {
        & ascii-image-converter $_.FullName --width $AsciiWidth --save-txt --output "frames/$base.txt" 2>$null
        # ascii-image-converter adds extra extension, fix it
        if (Test-Path "frames/$base.txt.txt") {
            Move-Item -Force "frames/$base.txt.txt" "frames/$base.txt"
        }
    }

    Write-Host "." -NoNewline
}

Write-Host ""
Write-Host "✓ Converted $frameCount frames to ASCII" -ForegroundColor Green

# Clean up temp files
Remove-Item -Recurse -Force "frames_temp"

# Step 3: Generate frames.rs
Write-Host ""
Write-Host "Step 3: Generating src/frames.rs..."

$animFrameCount = $frameCount - 1

$framesRsContent = @"
use lazy_static::lazy_static;
use std::sync::Arc;

const ANIMATE_FRAMES_STR: [&str; $animFrameCount] = [

"@

# Add include_str! for each frame (starting from frame_001)
for ($i = 1; $i -le $animFrameCount; $i++) {
    $frameNum = $i.ToString("000")
    $framesRsContent += "    include_str!(`"../frames/frame_$frameNum.txt`"),`n"
}

$framesRsContent += @"
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
            interval_ms: Arc::new([100; $animFrameCount]),
        }
    };
}

"@

Set-Content -Path "src/frames.rs" -Value $framesRsContent
Write-Host "✓ Generated src/frames.rs with $animFrameCount animation frames" -ForegroundColor Green

# Step 4: Update Cargo.toml
Write-Host ""
Write-Host "Step 4: Updating Cargo.toml..."

$cargoContent = Get-Content "Cargo.toml" -Raw
$cargoContent = $cargoContent -replace 'name = ".*"', "name = `"$ToolName`""
Set-Content -Path "Cargo.toml" -Value $cargoContent

Write-Host "✓ Updated package name to: $ToolName" -ForegroundColor Green

# Step 5: Update CLI name
Write-Host ""
Write-Host "Step 5: Updating CLI configuration..."

$cliContent = Get-Content "src/cli.rs" -Raw
$cliContent = $cliContent -replace '#\[command\(name = ".*"\)\]', "#[command(name = `"$ToolName`")]"
Set-Content -Path "src/cli.rs" -Value $cliContent

Write-Host "✓ Updated CLI name to: $ToolName" -ForegroundColor Green

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your custom CLI tool is ready!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Test your animation:"
Write-Host "     cargo run -- animate"
Write-Host ""
Write-Host "  2. Build release version:"
Write-Host "     cargo build --release"
Write-Host ""
Write-Host "  3. Install locally:"
Write-Host "     cargo install --path ."
Write-Host ""
Write-Host "  4. Use your tool:"
Write-Host "     $ToolName animate `"Hello World`""
Write-Host ""
Write-Host "To customize further:"
Write-Host "  - Edit src/cli.rs to change descriptions"
Write-Host "  - Edit Cargo.toml to update metadata"
Write-Host "  - Adjust frame timing in src/frames.rs"
Write-Host ""
