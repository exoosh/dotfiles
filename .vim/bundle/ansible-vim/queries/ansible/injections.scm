; inherits: jinja

; Inject YAML into content nodes (everything between Jinja2 template expressions)
((content) @injection.content
  (#set! injection.language "yaml")
  (#set! injection.combined))
