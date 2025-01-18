defmodule ProxEx do
  use Application

  def start(_type, _args) do
    IO.puts "Starting the application"
    ProxEx.ServerSup.start_link()
  end
end
