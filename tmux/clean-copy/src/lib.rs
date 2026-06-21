#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct CleanOptions {
    pub rewrap: bool,
}

pub fn clean_copy(input: &str, options: CleanOptions) -> String {
    let mut text = trim_right_padding(input);
    text = remove_common_left_gutter(&text);

    if options.rewrap {
        text = rewrap_lines(&text);
    }

    text
}

fn trim_right_padding(input: &str) -> String {
    input
        .split('\n')
        .map(|line| line.trim_end_matches([' ', '\t']))
        .collect::<Vec<_>>()
        .join("\n")
}

fn remove_common_left_gutter(input: &str) -> String {
    let common_indent = input
        .split('\n')
        .filter_map(leading_space_tab_indent)
        .min()
        .unwrap_or(0);

    if common_indent == 0 {
        return input.to_owned();
    }

    input
        .split('\n')
        .map(|line| remove_up_to_indent(line, common_indent))
        .collect::<Vec<_>>()
        .join("\n")
}

fn leading_space_tab_indent(line: &str) -> Option<usize> {
    let mut indent = 0;

    for ch in line.chars() {
        match ch {
            ' ' | '\t' => indent += ch.len_utf8(),
            ch if !ch.is_whitespace() => return Some(indent),
            _ => return None,
        }
    }

    None
}

fn remove_up_to_indent(line: &str, indent: usize) -> &str {
    let mut removed = 0;

    for (idx, ch) in line.char_indices() {
        if removed == indent {
            return &line[idx..];
        }

        match ch {
            ' ' | '\t' => removed += ch.len_utf8(),
            _ => return &line[idx..],
        }
    }

    if removed <= indent { "" } else { line }
}

fn rewrap_lines(input: &str) -> String {
    let mut output: Vec<String> = Vec::new();
    let mut in_code_fence = false;

    for line in input.split('\n') {
        if output
            .last()
            .is_some_and(|current| can_join(current, line, in_code_fence))
        {
            let current = output.last_mut().expect("checked above");
            let trimmed_next = line.trim_start();

            if starts_with_join_punctuation(line) || current.ends_with('-') {
                current.push_str(trimmed_next);
            } else {
                current.push(' ');
                current.push_str(trimmed_next);
            }
        } else {
            output.push(line.to_owned());
        }

        if is_fence(line) {
            in_code_fence = !in_code_fence;
        }
    }

    output.join("\n")
}

fn can_join(current: &str, next: &str, in_code_fence: bool) -> bool {
    if in_code_fence || is_blank(current) || is_blank(next) {
        return false;
    }

    if is_fence(current) || is_fence(next) {
        return false;
    }

    if is_heading(current) || is_hr(current) || is_table_separator(current) {
        return false;
    }

    if is_structural_start(next) {
        return false;
    }

    if is_indented_code(current) || is_indented_code(next) {
        return false;
    }

    if current.ends_with("  ") {
        return false;
    }

    true
}

fn is_blank(line: &str) -> bool {
    line.trim().is_empty()
}

fn is_fence(line: &str) -> bool {
    let trimmed = line.trim_start();
    trimmed.starts_with("```") || trimmed.starts_with("~~~")
}

fn is_heading(line: &str) -> bool {
    let Some(rest) = strip_leading_whitespace_up_to(line, 3) else {
        return false;
    };

    let hashes = rest.chars().take_while(|&ch| ch == '#').count();
    if !(1..=6).contains(&hashes) {
        return false;
    }

    rest[hashes..]
        .chars()
        .next()
        .is_some_and(char::is_whitespace)
}

fn is_hr(line: &str) -> bool {
    let Some(rest) = strip_leading_whitespace_up_to(line, 3) else {
        return false;
    };

    let markers: String = rest.chars().filter(|ch| !ch.is_whitespace()).collect();
    let mut chars = markers.chars();
    let Some(first) = chars.next() else {
        return false;
    };

    matches!(first, '-' | '*' | '_') && markers.chars().count() >= 3 && chars.all(|ch| ch == first)
}

fn is_list_item(line: &str) -> bool {
    let Some(rest) = strip_leading_whitespace_up_to(line, 3) else {
        return false;
    };

    if let Some(marker) = rest.chars().next()
        && matches!(marker, '-' | '*' | '+')
    {
        return rest[marker.len_utf8()..]
            .chars()
            .next()
            .is_some_and(char::is_whitespace);
    }

    let digit_count = rest.chars().take_while(|ch| ch.is_ascii_digit()).count();
    if digit_count == 0 {
        return false;
    }

    let after_digits = &rest[digit_count..];
    let Some(marker) = after_digits.chars().next() else {
        return false;
    };

    matches!(marker, '.' | ')')
        && after_digits[marker.len_utf8()..]
            .chars()
            .next()
            .is_some_and(char::is_whitespace)
}

fn is_table_separator(line: &str) -> bool {
    let mut rest = line.trim_start();

    if let Some(stripped) = rest.strip_prefix('|') {
        rest = stripped.trim_start();
    }

    if let Some(stripped) = rest.strip_prefix(':') {
        rest = stripped;
    }

    let hyphen_count = rest.chars().take_while(|&ch| ch == '-').count();
    if hyphen_count < 3 {
        return false;
    }

    hyphen_count >= 3
}

fn is_indented_code(line: &str) -> bool {
    line.starts_with('\t') || line.starts_with("    ")
}

fn is_structural_start(line: &str) -> bool {
    is_fence(line)
        || is_heading(line)
        || is_hr(line)
        || is_list_item(line)
        || is_table_separator(line)
}

fn starts_with_join_punctuation(line: &str) -> bool {
    line.chars()
        .next()
        .is_some_and(|ch| matches!(ch, ',' | '.' | ';' | ':' | '!' | '?' | ')'))
}

fn strip_leading_whitespace_up_to(line: &str, max: usize) -> Option<&str> {
    let mut count = 0;

    for (idx, ch) in line.char_indices() {
        if !ch.is_whitespace() {
            return Some(&line[idx..]);
        }

        count += 1;
        if count > max {
            return None;
        }
    }

    Some("")
}

#[cfg(test)]
mod tests {
    use super::*;

    fn clean(input: &str) -> String {
        clean_copy(input, CleanOptions { rewrap: false })
    }

    fn clean_rewrap(input: &str) -> String {
        clean_copy(input, CleanOptions { rewrap: true })
    }

    #[test]
    fn trims_right_padding() {
        assert_eq!(clean("alpha   \nbeta\t\t\n"), "alpha\nbeta\n");
    }

    #[test]
    fn removes_common_left_gutter() {
        assert_eq!(
            clean("    fn main() {\n        ok();\n    }\n"),
            "fn main() {\n    ok();\n}\n"
        );
    }

    #[test]
    fn ignores_blank_lines_when_removing_gutter() {
        assert_eq!(clean("  alpha\n\n    beta"), "alpha\n\n  beta");
    }

    #[test]
    fn rewraps_terminal_wrapped_paragraphs() {
        assert_eq!(
            clean_rewrap("  This is a line\n  wrapped by the terminal\n  into three chunks."),
            "This is a line wrapped by the terminal into three chunks."
        );
    }

    #[test]
    fn joins_punctuation_without_extra_space() {
        assert_eq!(clean_rewrap("Hello\n, world"), "Hello, world");
    }

    #[test]
    fn joins_hyphenated_words_without_extra_space() {
        assert_eq!(clean_rewrap("multi-\nline"), "multi-line");
    }

    #[test]
    fn keeps_markdown_structure() {
        let input = "# Title\nparagraph line\nnext line\n- item\nbody";
        let expected = "# Title\nparagraph line next line\n- item body";
        assert_eq!(clean_rewrap(input), expected);
    }

    #[test]
    fn keeps_fenced_code_blocks() {
        let input = "before\n```rust\nlet a = 1;\nlet b = 2;\n```\nafter";
        assert_eq!(clean_rewrap(input), input);
    }

    #[test]
    fn keeps_indented_code_blocks() {
        let input = "text\n    let a = 1;\nmore";
        assert_eq!(clean_rewrap(input), input);
    }
}
