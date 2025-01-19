defmodule ProxEx.HttpReponse do
  defstruct [:status_line, :body, headers: %{}]
end
