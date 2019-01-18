defmodule Elixirchat.SocketQueue do
    use GenServer


    def init(queue) do
        {:ok, queue}
    end

    def start_link() do
        GenServer.start_link(__MODULE__, :queue.new(), name: SocketQueue)
    end

    def add(item) do  
        GenServer.cast(SocketQueue, {:add, item})
    end

    def list() do 
        GenServer.call(SocketQueue, :list)
      end

    def length() do  
        GenServer.call(SocketQueue, :length)
    end

    def fetch() do  
        GenServer.call(SocketQueue, :fetch)
    end

    def handle_cast({:add, item}, queue) do
        {:noreply, :queue.in(item, queue)}
    end

    def handle_cast(:overwrite, queue) do
        IO.puts("overwite")
        {:noreply, :queue.from_list(queue)}
    end

    def handle_call(:list, _from, queue) do
        {:reply, :queue.to_list(queue), queue}
    end

    def handle_call(:fetch, _from, queue) do
        with {{:value, item}, new_queue} <- :queue.out(queue) do
            {:reply, item, new_queue}
        else
            {:empty, _} ->
            {:reply, :empty, queue}
        end
    end

    def handle_call(:length, _from, queue) do
        {:reply, :queue.len(queue), queue}
    end

    def send_all(message) do
        nq = []
        nq = for socket <- Elixirchat.SocketQueue.list() do 
            if (message != "" && message != "error") do
                IO.puts(message)
                case :gen_tcp.send(socket, message) do 
                    :ok -> 
                        nq ++ socket
                    {:error, :closed} -> 
                        IO.puts("failed to send")
                        nq
                    {:error, :enotconn} -> 
                        IO.puts("failed to send")
                        nq
                end
            end
        end
        GenServer.cast(:overwrite, nq)

    end

  end