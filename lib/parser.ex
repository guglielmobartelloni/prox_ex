defmodule ProxEx.Parser do
  alias ProxEx.HttpReponse

  def parse(http_response) do
    [top, body] = http_response |> String.split("\r\n\r\n")
    [status_line | headers] = top |> String.split("\r\n", trim: true)

    headers_map =
      headers
      |> Enum.map(fn e ->
        [name, value] = String.split(e, ": ", trim: true)
        {name, value}
      end)
      |> Enum.into(%{})

    %HttpReponse{status_line: status_line, body: body, headers: headers_map}
  end

  def add_header(%HttpReponse{headers: headers_map} = response, {key, value}) do
    headers_map =
      headers_map
      |> Map.put(key, value)

    %{
      response
      | headers: headers_map
    }
  end

  def add_cookie(%HttpReponse{headers: _headers_map} = response, {_key, _value}) do
    # TODO
    response
  end

  def format_response(%HttpReponse{} = response) do
    response =
      response
      |> add_header({"Content-Length", "#{String.length(response.body)}"})

    formatted_headers =
      response.headers
      |> Enum.map(fn {key, value} -> key <> ": " <> value end)
      |> Enum.join("\r\n")

    """
    #{response.status_line}
    #{formatted_headers}\r\n
    #{response.body}
    """
  end
end
