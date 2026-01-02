## Creating Your Own Custom Version

Want to create your own version with a different character? You can easily convert any GIF into a custom CLI tool!

### Quick Start

1. **Clone this repository:**
   ```sh
   git clone https://github.com/VectorSophie/yisangsay-independent.git customsay
   cd customsay
   ```

2. **Place your GIF in the project root** (e.g., `mygif.gif`)

3. **Run the setup script:**

   **Linux/macOS:**
   ```sh
   chmod +x setup.sh
   ./setup.sh mygif.gif customsay 64
   ```

   **Windows (PowerShell):**
   ```powershell
   .\setup.ps1 mygif.gif customsay 64
   ```

   Parameters:
   - `mygif.gif` - Path to your GIF file
   - `customsay` - Name for your CLI tool (optional, default: customsay)
   - `64` - ASCII art width in characters (optional, default: 64)

4. **Test and build:**
   ```sh
   cargo run -- animate "Hello World"
   cargo build --release
   cargo install --path .
   ```

5. **Use your custom tool:**
   ```sh
   customsay animate "Your message here"
   ```

### Prerequisites

**Required for building and running:**
- **Rust & Cargo** - For compiling the tool
  - Windows: `choco install rustup.install` or download from https://rustup.rs/
  - macOS: `brew install rustup` or `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
  - Linux: `sudo apt install rustup` or `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
  - After installing rustup, run: `rustup default stable`

**Required for the setup script:**
- **ImageMagick** - For extracting GIF frames
  - Windows: `choco install imagemagick`
  - macOS: `brew install imagemagick`
  - Linux: `sudo apt install imagemagick`

- **ASCII Converter** - One of the following:
  - `jp2a` (recommended for Linux): `sudo apt install jp2a`
  - `ascii-image-converter` (cross-platform): `go install github.com/TheZoraiz/ascii-image-converter@latest`

### What the Setup Script Does

1. Extracts all frames from your GIF
2. Converts each frame to ASCII art
3. Auto-generates `src/frames.rs` with the correct frame count
4. Updates `Cargo.toml` with your tool name
5. Updates CLI configuration

### Tips for Best Results

- **ASCII Width:**
  - Small/compact: 40-50 characters
  - Medium (default): 64 characters
  - Large/detailed: 80-100 characters

- **GIF Quality:**
  - Simple, high-contrast GIFs work best
  - Avoid very detailed or noisy GIFs
  - Test different widths to find the best look

- **Frame Timing:**
  - Edit `src/frames.rs` after generation to adjust timing
  - Default: 100ms per frame
  - Fast: 50-75ms, Slow: 150-200ms

For manual setup and advanced customization, see [Custom.md](Custom.md)

## Usage

```
Usage: customsay <COMMAND>

Commands:
  say        Display Yi Sang saying the provided text
  animate    Display an animated Yi Sang
  freestyle  Display Yi Sang in freestyle mode. Pretty cool for ricing btw
  help       Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```