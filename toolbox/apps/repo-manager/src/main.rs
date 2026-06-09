mod cli;
mod commands;

use anyhow::Result;
use clap::Parser;
use session::Manifest;
use tracing::level_filters::LevelFilter;

use cli::{Cli, Command};

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    init_tracing(cli.verbose.tracing_level_filter());

    tracing::debug!(command = ?cli.command, "dispatching subcommand");

    let manifest = Manifest::at(cli.manifest);
    match cli.command {
        Command::Clone(a) => commands::clone::run(a, &manifest).await,
        Command::List(a) => commands::list::run(a, &manifest),
        Command::Audit(a) => commands::audit::run(a, &manifest).await,
        Command::Remove(a) => commands::remove::run(a, &manifest).await,
    }
}

fn init_tracing(level: LevelFilter) {
    let filter = tracing_subscriber::EnvFilter::builder()
        .with_default_directive(level.into())
        .from_env_lossy();
    tracing_subscriber::fmt()
        .with_env_filter(filter)
        .with_writer(std::io::stderr)
        .init();
}
