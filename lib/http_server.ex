defmodule ProxEx.HttpServer do
  use GenServer

  def start_link(port) when is_integer(port) and port > 1023 do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  @impl true
  def init(port) do
    case :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true]) do
      {:ok, listen_socket} ->
        IO.puts("\n🎧  Listening for connection requests on port #{port}...\n")
        # Kick off the accept loop in a separate process to keep init non-blocking
        Process.send_after(self(), :accept, 0)
        {:ok, %{listen_socket: listen_socket, port: port}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_info(:accept, %{listen_socket: listen_socket} = state) do
    IO.puts("⌛️  Waiting to accept a client connection...\n")

    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        IO.puts("⚡️  Connection accepted!\n")
        spawn(fn -> serve(client_socket) end)
        Process.send_after(self(), :accept, 0)
        {:noreply, state}

      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  defp serve(client_socket) do
    IO.puts("#{inspect(self())}: Working on it!")

    client_socket
    |> read_request()
    |> ProxEx.Handler.forward()
    |> write_response(client_socket)
  end

  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  defp read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    IO.puts("➡️  Received request:\n")
    IO.puts(request)
    request
  end

  defp write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    IO.puts("⬅️  Sent response:\n")
    IO.puts(response)
    :gen_tcp.close(client_socket)
  end
end
