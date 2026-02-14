;; extends

(literal_type
  [
    (undefined)
    (null)
    (true)
    (false)
  ] @type.builtin)

;; Highlight 'as' in cast expressions
(as_expression
  "as" @keyword.import.typescript (#set! priority 130))

