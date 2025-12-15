# yisangsay-rs

Yisangsay is a CLI program like cowsay, but instead of a talking cow, it's Yi Sang from Limbus Company!

## Features

- Written in Rust!
- Talking ASCII art of Yi Sang
- Animated ASCII art of Yi Sang
- Freestyle changing animation of Yi Sang

## Installation

### Cargo (All platforms)

```sh
cargo install yisangsay
```

### Windows

#### Chocolatey (Recommended)

```powershell
choco install yisangsay
```

#### Manual Download
Download the latest Windows release from [GitHub Releases](https://github.com/VectorSophie/yisangsay-rs/releases) and extract to a directory in your PATH.

### Linux

#### APT (Ubuntu/Debian)

```sh
sudo add-apt-repository ppa:vectorsophie/yisangsay
sudo apt update
sudo apt install yisangsay
```

#### Manual Download
Download the latest Linux release from [GitHub Releases](https://github.com/VectorSophie/yisangsay-rs/releases).

### macOS

Download the latest macOS release from [GitHub Releases](https://github.com/VectorSophie/yisangsay-rs/releases).

### Build from Source

```sh
git clone https://github.com/VectorSophie/yisangsay-rs.git
cd yisangsay-rs
cargo build -r
```

## Usage

```
Usage: yisangsay <COMMAND>

Commands:
  say        Display Yi Sang saying the provided text
  animate    Display an animated Yi Sang (variant 1 or 2)
  freestyle  Display Yi Sang in freestyle mode. Pretty cool for ricing btw
  help       Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```