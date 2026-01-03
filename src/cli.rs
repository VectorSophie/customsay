use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "customsay")]
#[command(
    about = "A customizable CLI program like cowsay - create your own animated ASCII art character from any GIF!"
)]
#[command(version)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Display your character saying the provided text
    Say {
        /// The text for your character to say
        text: String,
    },

    /// Display an animated version of your character
    Animate {
        /// Optional text for your character to say
        text: Option<String>,
    },
}
