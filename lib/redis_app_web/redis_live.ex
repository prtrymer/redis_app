defmodule RedisAppWeb.RedisLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-6">Redis Key-Value Manager</h1>
      <div class="mb-4">
      <button phx-click="show_create_modal" class="bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded">Create New</button>
      </div>
      <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
        <tr>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Key</th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Value</th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
        </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
        <%= for key <- @keys do %>
          <tr>
          <td class="px-6 py-4 whitespace-nowrap"><%= key %></td>
          <td class="px-6 py-4 whitespace-nowrap"><%= RedisApp.RedisService.get_value(key) || "N/A" %></td>
          <td class="px-6 py-4 whitespace-nowrap">
            <button phx-click="edit_key" phx-value-key={key} class="bg-green-500 hover:bg-green-600 text-white py-1 px-3 rounded mr-2">Edit</button>
            <button phx-click="delete_key" phx-value-key={key} class="bg-red-500 hover:bg-red-600 text-white py-1 px-3 rounded">Delete</button>
          </td>
          </tr>
        <% end %>
        </tbody>
      </table>
      </div>
    </div>

      <%= if @show_create_modal do %>
        <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
          <div class="bg-white p-6 rounded shadow-lg">
        <form phx-submit="save_new">
          <div class="mb-4">
            <input type="text" name="new_key" placeholder="Key" phx-change="update_new_key" value={@new_key} class="w-full p-2 border border-gray-300 rounded"/>
          </div>
          <div class="mb-4">
            <input type="text" name="new_value" placeholder="Value" phx-change="update_new_value" value={@new_value} class="w-full p-2 border border-gray-300 rounded"/>
          </div>
          <div class="flex justify-end">
            <button type="submit" disabled={@new_key == "" or @new_value == ""} class="px-4 py-2 mr-2 bg-green-500 hover:bg-green-600 text-white rounded">
          Save
            </button>
            <button type="button" phx-click="close_modal" class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded">
          Cancel
            </button>
          </div>
        </form>
          </div>
        </div>
      <% end %>
    """
  end

  def mount(_params, _session, socket) do
    keys = RedisApp.RedisService.get_all_keys()
    {:ok, assign(socket,
      keys: keys,
      show_create_modal: false,
      new_key: "",
      new_value: ""
    )}
  end

  def handle_event("show_create_modal", _, socket) do
    {:noreply, assign(socket, show_create_modal: true, new_key: "", new_value: "")}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_create_modal: false, new_key: "", new_value: "")}
  end

  def handle_event("update_new_key", %{"new_key" => new_key}, socket) do
    {:noreply, assign(socket, new_key: new_key)}
  end

  def handle_event("update_new_value", %{"new_value" => new_value}, socket) do
    {:noreply, assign(socket, new_value: new_value)}
  end

  def handle_event("save_new", _params, socket) do
    if socket.assigns.new_key != "" and socket.assigns.new_value != "" do
      RedisApp.RedisService.set_value(socket.assigns.new_key, socket.assigns.new_value)
      keys = RedisApp.RedisService.get_all_keys()
      {:noreply, assign(socket,
        show_create_modal: false,
        keys: keys,
        new_key: "",
        new_value: ""
      )}
    else
      {:noreply, socket}
    end
  end


  def handle_event("delete_key", %{"key" => key}, socket) do
    RedisApp.RedisService.delete_key(key)
    keys = RedisApp.RedisService.get_all_keys()
    {:noreply, assign(socket, keys: keys)}
  end

  def handle_event("edit_key", %{"key" => key}, socket) do
    value = RedisApp.RedisService.get_value(key) || ""
    {:noreply, assign(socket,
      show_create_modal: true,
      new_key: key,
      new_value: value
    )}
  end
end
