defmodule RedisAppWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use RedisAppWeb, :controller` and
  `use RedisAppWeb, :live_view`.
  """
  use RedisAppWeb, :html

  embed_templates "layouts/*"
end
