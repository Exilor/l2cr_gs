class Channel(T)
  def size
    if queue = @queue
      return queue.size
    end

    @senders.empty? ? 0 : 1
  end
end
