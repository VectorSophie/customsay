# A customization guide for yisangsay

Turn any GIF into a custom CLI tool like yisangsay!

## Automated Setup (Recommended)

The easiest way to create a custom version is to use the provided setup scripts.

### Prerequisites

Install these tools first:

**Windows:**
```powershell
choco install imagemagick
go install github.com/TheZoraiz/ascii-image-converter@latest
```

**macOS:**
```bash
brew install imagemagick
go install github.com/TheZoraiz/ascii-image-converter@latest
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt install imagemagick jp2a
```

### Quick Start

1. **Get your GIF ready** - Place it in the project root (e.g., `mygif.gif`)

2. **Run the setup script:**

   **Linux/macOS:**
   ```bash
   chmod +x setup.sh
   ./setup.sh mygif.gif customsay 64
   ```

   **Windows:**
   ```powershell
   .\setup.ps1 mygif.gif customsay 64
   ```

   **Parameters:**
   - `mygif.gif` - Path to your GIF file
   - `customsay` - Name for your CLI tool (optional, default: customsay)
   - `64` - ASCII art width in characters (optional, default: 64)

3. **Build and install:**
   ```bash
   cargo build --release
   cargo install --path .
   ```

4. **Enjoy!**
   ```bash
   customsay animate "Hello World!"
   customsay say "I made this!"
   ```

### What the Script Does

The setup script automatically:
- Extracts all frames from your GIF
- Converts each frame to ASCII art
- Generates `src/frames.rs` with correct frame count
- Updates `Cargo.toml` with your tool name
- Updates `src/cli.rs` with your CLI name

### Examples

```bash
# Create a tool called "dogosay" from dog.gif with 80-character width
./setup.sh dog.gif dogosay 80

# Create "catcli" from cat.gif with default 64-character width
./setup.sh cat.gif catcli

# On Windows with PowerShell
.\setup.ps1 meme.gif memesay 50
```

### Tips for Best Results

- **ASCII Width:** Try different values (40-100) to see what looks best
  - Small/compact: 40-50 characters (faster, less detail, fits smaller terminals)
  - Medium (default): 64 characters
  - Large/detailed: 80-100 characters (slower, more detail, needs bigger terminal)

- **Best GIFs:** Simple, high-contrast GIFs with clear subjects work best
  - Avoid very detailed or noisy GIFs
  - Test different widths to find the best look

- **Adjust Speed:** After setup, edit `src/frames.rs` and change the interval values:
  ```rust
  interval_ms: Arc::new([100; 29]),  // Change 100 to 50 (faster) or 200 (slower)
  ```

### Troubleshooting

**"ImageMagick not found"**
- Install ImageMagick (see Prerequisites above)
- Verify installation: `magick --version` or `convert --version`

**"No ASCII converter found"**
- Install jp2a (Linux): `sudo apt install jp2a`
- Or install ascii-image-converter (all platforms): `go install github.com/TheZoraiz/ascii-image-converter@latest`

**Animation looks weird**
- Try different ASCII widths: `./setup.sh mygif.gif toolname 50`
- Simpler GIFs usually work better
- Manually edit generated frames in the `frames/` directory if needed

**"mismatched types" error after running script**
- This shouldn't happen with the automated script
- If it does, see the Manual Setup section below

---

## Manual Setup (Advanced)

The rest of this guide covers the manual process for advanced users who want more control or need to troubleshoot issues.

**this guide is written with linux priority. I dont know how shite works on mac**