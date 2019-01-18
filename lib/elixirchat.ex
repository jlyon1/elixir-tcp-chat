defmodule Elixirchat do
  require Logger

  def init() do 
    Elixirchat.SocketQueue.start_link()
  end


  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    write_line("Welcome", client)
    save(client)

    pid = spawn fn -> serve(client) end
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> Elixirchat.SocketQueue.send_all()

    serve(socket)  
  end

  defp save(socket) do
    IO.puts("save")
    Elixirchat.SocketQueue.add(socket)
  end

  def list() do
    Elixirchat.SocketQueue.list()  
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
      {:error, err} -> "error"
      
    end
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
