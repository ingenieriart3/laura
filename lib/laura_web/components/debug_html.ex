# lib/laura_web/controllers/debug_html.ex
defmodule LauraWeb.DebugHTML do
  use LauraWeb, :html

  embed_templates "debug_html/*"
end
