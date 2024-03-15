;; extends

[
  "*"
  "**"
] @boolean

((import_clause
  (named_imports
    (import_specifier) @variable (set! "priority" 105))))
(import_clause
  (identifier) @variable (set! "priority" 105))
