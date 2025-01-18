defmodule ProxEx.ServerSup do

  use Supervisor

  def start_link() do
    IO.puts "Starting the http supervisor"
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    port = Application.get_env(:prox_ex, :port)
    children = [
        {ProxEx.HttpServer, port},
        ProxEx.Handler
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
