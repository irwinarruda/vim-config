use std::env;
use std::io::{self, Read, Write};
use std::process::{Command, Stdio};

use clean_copy::{CleanOptions, clean_copy};

fn main() {
    let options = match parse_args(env::args().skip(1)) {
        Ok(options) => options,
        Err(ParseOutcome::Help) => {
            print_help();
            return;
        }
        Err(ParseOutcome::Error(message)) => {
            eprintln!("clean-copy: {message}");
            eprintln!("Try `clean-copy --help` for usage.");
            std::process::exit(2);
        }
    };

    if let Err(error) = run(options) {
        eprintln!("clean-copy: {error}");
        std::process::exit(1);
    }
}

fn run(options: CleanOptions) -> io::Result<()> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let cleaned = clean_copy(&input, options);
    copy_with_pbcopy(&cleaned)
}

fn copy_with_pbcopy(text: &str) -> io::Result<()> {
    let mut child = Command::new("pbcopy").stdin(Stdio::piped()).spawn()?;

    child
        .stdin
        .as_mut()
        .expect("pbcopy stdin is piped")
        .write_all(text.as_bytes())?;

    let status = child.wait()?;
    if status.success() {
        Ok(())
    } else {
        Err(io::Error::other(format!("pbcopy exited with {status}")))
    }
}

#[derive(Debug, PartialEq, Eq)]
enum ParseOutcome {
    Help,
    Error(String),
}

fn parse_args(args: impl IntoIterator<Item = String>) -> Result<CleanOptions, ParseOutcome> {
    let mut options = CleanOptions::default();

    for arg in args {
        match arg.as_str() {
            "--rewrap" => options.rewrap = true,
            "-h" | "--help" => return Err(ParseOutcome::Help),
            _ => return Err(ParseOutcome::Error(format!("unknown argument `{arg}`"))),
        }
    }

    Ok(options)
}

fn print_help() {
    println!(
        "clean-copy\n\nUSAGE:\n    clean-copy [--rewrap]\n\nOPTIONS:\n    --rewrap    Join terminal-wrapped prose while preserving Markdown-ish structure\n    -h, --help  Print this help"
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_no_args() {
        assert_eq!(parse_args(Vec::new()), Ok(CleanOptions { rewrap: false }));
    }

    #[test]
    fn parses_rewrap() {
        assert_eq!(
            parse_args(vec!["--rewrap".to_owned()]),
            Ok(CleanOptions { rewrap: true })
        );
    }

    #[test]
    fn rejects_unknown_args() {
        assert!(matches!(
            parse_args(vec!["--wat".to_owned()]),
            Err(ParseOutcome::Error(_))
        ));
    }

    #[test]
    fn handles_help() {
        assert_eq!(
            parse_args(vec!["--help".to_owned()]),
            Err(ParseOutcome::Help)
        );
    }
}
