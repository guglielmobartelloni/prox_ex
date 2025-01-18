defmodule ProxEx.Handler do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def forward(request) do
    IO.puts "This is the request:\n#{inspect request}"

    host = ~c"localhost"
    {:ok, sock} = :gen_tcp.connect(host, 5000, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(sock, request)
    {:ok, response} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)

    IO.puts "Internal response: #{inspect response}"

    response
  end
end
