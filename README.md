# yisangsay-rs

Yisangsay is a CLI program like cowsay, but instead of a talking cow, it's Yi Sang from Limbus Company!

## Features

- Written in Rust!
- Talking ASCII art of Yi Sang
- Animated ASCII art of Yi Sang
- Freestyle changing animation of Yi Sang

## Installation

### Cargo

```sh
cargo install yisangsay
```

### APT

sudo add-apt-repository ppa:vectorsophie/yisangsay
sudo apt update
sudo apt install yisangsay

### Manually Build

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