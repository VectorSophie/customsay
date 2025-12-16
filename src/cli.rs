use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "yisangsay")]
#[command(
    about = "Yisangsay is a CLI program like cowsay, but instead of a talking cow, it's Yi Sang from Limbus Company!"
)]
#[command(version)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Display Yi Sang saying the provided text
    Say {
        /// The text for Yi Sang to say
        text: String,
    },

    /// Display an animated Yi Sang
    Animate {
        /// The text for Yi Sang to say
        text: Option<String>,
    },

    /// Display Yi Sang in freestyle mode. Pretty cool for ricing btw.
    Freestyle {
        /// The text for Yi Sang to say
        text: Option<String>,
    },
}
