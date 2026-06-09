mod cli;
mod commands;

use std::process::ExitCode;

use anyhow::Result;
use clap::{CommandFactory, Parser};
use clap_complete::CompleteEnv;
use owo_colors::{OwoColorize, Stream, Style};
use session::Manifest;
use tracing::level_filters::LevelFilter;

use cli::{Cli, Command};

#[tokio::main]
async fn main() -> ExitCode {
    // If invoked in completion mode (env-driven), print candidates and exit
    // before doing anything else. No-op for normal invocations.
    CompleteEnv::with_factory(Cli::command).complete();

    let cli = Cli::parse();
    init_tracing(cli.verbose.tracing_level_filter());

    match run(cli).await {
        Ok(()) => ExitCode::SUCCESS,
        Err(err) => {
            report(&err);
            ExitCode::FAILURE
        }
    }
}

async fn run(cli: Cli) -> Result<()> {
    tracing::debug!(command = ?cli.command, "dispatching subcommand");

    let manifest = Manifest::at(cli.manifest);
    match cli.command {
        Command::Clone(a) => commands::clone::run(a, &manifest).await,
        Command::List(a) => commands::list::run(a, &manifest),
        Command::Audit(a) => commands::audit::run(a, &manifest).await,
        Command::Remove(a) => commands::remove::run(a, &manifest).await,
        Command::Worktree(a) => commands::worktree::run(a, &manifest).await,
    }
}

fn report(err: &anyhow::Error) {
    let style = Style::new().red().bold();
    eprintln!(
        "{} {err}",
        "error:".if_supports_color(Stream::Stderr, |s| s.style(style)),
    );
    for cause in err.chain().skip(1) {
        eprintln!("  caused by: {cause}");
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
