defmodule RedisAppWeb.RedisLiveTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint RedisAppWeb.Endpoint

  setup do
    conn = build_conn()
    # Optional: clear keys or seed test keys if your RedisService supports it.
    if function_exported?(RedisApp.RedisService, :clear_all_keys, 0),
      do: RedisApp.RedisService.clear_all_keys()
    {:ok, conn: conn}
  end

  test "mount renders key-value manager", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/redis")
    assert html =~ "Redis Key-Value Manager"
  end

  test "shows create modal when clicking 'Create New'", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/redis")
    view
    |> element("button", "Create New")
    |> render_click()

    html = render(view)
    assert html =~ ~s(placeholder="Key")
    assert html =~ ~s(placeholder="Value")
  end

  test "saves new key-value pair via form submission", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/redis")

    view
    |> element("button", "Create New")
    |> render_click()

    form =
      form(view, "form", %{
        "new_key" => "test_key",
        "new_value" => "test_value"
      })

    render_submit(form)

    html = render(view)
    assert html =~ "test_key"
    assert html =~ "test_value"
  end

  test "deletes a key", %{conn: conn} do

    RedisApp.RedisService.set_value("delete_me", "to_delete")
    {:ok, view, _html} = live(conn, "/redis")

    html = render(view)
    assert html =~ "delete_me"

    view
    |> element(~s(button[phx-value-key="delete_me"]), "Delete")
    |> render_click(%{"key" => "delete_me"})

    html = render(view)
    refute html =~ "delete_me"
  end

  test "edits a key", %{conn: conn} do
    RedisApp.RedisService.set_value("edit_me", "original_value")
    {:ok, view, _html} = live(conn, "/redis")

    html = render(view)
    assert html =~ "edit_me"
    
    view
    |> element(~s(button[phx-click="edit_key"][phx-value-key="edit_me"].bg-green-500), "Edit")
    |> render_click()

    html = render(view)
    assert html =~ ~s(value="original_value")
  end
end
