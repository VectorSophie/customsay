mod cli;
mod frames;
mod display;

use crate::cli::{Cli, Commands};
use crate::frames::{STATIC_FRAME, ANIMATE1_FRAMES};
use crate::display::{display_say_command, display_animation_once, check_terminal_size, setup_terminal, cleanup_terminal, spawn_exit_listener};
use clap::Parser;
use tokio::sync::broadcast;

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Say { text } => {
            display_say_command(&STATIC_FRAME, &text);
        }
        Commands::Animate { text } => {
            let frames = &*ANIMATE1_FRAMES;

            if !check_terminal_size().unwrap_or(false) {
                println!("your terminal is too small for yi sang");
                return;
            }
            
            if let Err(e) = setup_terminal() {
                eprintln!("Error setting up terminal: {e}");
                std::process::exit(1);
            }
            
            // Create broadcast channel for exit signals
            let (exit_tx, _) = broadcast::channel::<()>(1);
            
            // Spawn the exit listener
            spawn_exit_listener(exit_tx.clone());
            
            loop {
                let exit_rx = exit_tx.subscribe();
                match display_animation_once(frames, text.as_deref(), exit_rx).await {
                    Ok(should_exit) => {
                        if should_exit {
                            break;
                        }
                    }
                    Err(e) => {
                        eprintln!("Error during animation: {e}");
                        break;
                    }
                }
            }
            
            if let Err(e) = cleanup_terminal() {
                eprintln!("Error cleaning up terminal: {e}");
                std::process::exit(1);
            }
        }
        Commands::Freestyle { text } => {
            if !check_terminal_size().unwrap_or(false) {
                println!("your terminal is too small for yi sang");
                return;
            }
            
            if let Err(e) = setup_terminal() {
                eprintln!("Error setting up terminal: {e}");
                std::process::exit(1);
            }
            
            // Create broadcast channel for exit signals
            let (exit_tx, _) = broadcast::channel::<()>(1);
            
            // Spawn the exit listener
            spawn_exit_listener(exit_tx.clone());
            
            loop {
                let frames = &*ANIMATE1_FRAMES;
                
                let exit_rx = exit_tx.subscribe();
                match display_animation_once(frames, text.as_deref(), exit_rx).await {
                    Ok(should_exit) => {
                        if should_exit {
                            break;
                        }
                    }
                    Err(e) => {
                        eprintln!("Error during freestyle animation: {e}");
                        break;
                    }
                }
            }
            
            if let Err(e) = cleanup_terminal() {
                eprintln!("Error cleaning up terminal: {e}");
                std::process::exit(1);
            }
        }
    }
}
