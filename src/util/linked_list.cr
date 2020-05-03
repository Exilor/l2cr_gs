class Concurrent::LinkedList(E)
  include IList(E)

  private class Node(E)
    def initialize(item : E?)
      @item_updater = Atomic(E?).new(item)
      @succ_updater = Atomic(self?).new(nil)
    end

    def initialize(item : E?, succ : self?)
      @item_updater = Atomic(E?).new(item)
      @succ_updater = Atomic(self?).new(succ)
    end

    def item : E?
      @item_updater.lazy_get
    end

    def cas_item(cmp : E?, val : E?) : Bool
      @item_updater.compare_and_set(cmp, val)[1]
    end

    def item=(val : E?)
      @item_updater.set(val)
    end

    def succ : self?
      @succ_updater.lazy_get
    end

    def cas_succ(cmp : self?, val : self?) : Bool
      @succ_updater.compare_and_set(cmp, val)[1]
    end

    def succ=(val : self)
      @succ_updater.set(val)
    end
  end

  def initialize
    head = Node(E).new(nil)
    @head_updater = Atomic(Node(E)?).new(head)
    @tail_updater = Atomic(Node(E)?).new(head)
  end

  private def cas_tail(cmp : Node(E)?, val : Node(E)?) : Bool
    @tail_updater.compare_and_set(cmp, val)[1]
  end

  private def cas_head(cmp : Node(E)?, val : Node(E)?) : Bool
    @head_updater.compare_and_set(cmp, val)[1]
  end

  private def get_head : Node(E)
    @head_updater.lazy_get.not_nil!
  end

  private def get_tail : Node(E)
    @tail_updater.lazy_get.not_nil!
  end

  def add(e : E) : Bool
    n = Node(E).new(e, nil)
    loop do
      tail = get_tail
      t = tail
      s = t.succ
      if t == tail
        if s.nil?
          if t.cas_succ(s, n)
            cas_tail(t, n)
            return true
          end
        else
          cas_tail(t, s)
        end
      end
    end
  end

  def poll : E?
    loop do
      head = get_head
      tail = get_tail

      h = head
      t = tail
      first = h.succ

      if h == head
        if h == t
          if first.nil?
            return
          else
            cas_tail(t, first)
          end
        elsif cas_head(h, first)
          if first && (item = first.item)
            first.item = nil
            return item
          end
        end
      end
    end
  end

  def peek : E?
    loop do
      head = get_head
      tail = get_tail

      h = head
      t = tail
      first = h.succ

      if h == head
        if h == t
          if first.nil?
            return
          else
            cas_tail(t, first)
          end
        else
          if first && (item = first.item)
            return item
          else
            cas_head(h, first)
          end
        end
      end
    end
  end

  def first_node : Node(E)?
    loop do
      head = get_head
      tail = get_tail

      h = head
      t = tail
      first = h.succ

      if h == head
        if h == t
          if first.nil?
            return
          else
            cas_tail(t, first)
          end
        else
          if first && first.item
            return first
          else
            cas_head(h, first)
          end
        end
      end
    end
  end

  def empty? : Bool
    first_node.nil?
  end

  def size : Int32
    count = 0

    p = first_node
    while p
      if p.item
        if count == Int32::MAX
          break
        end
        count += 1
      end
      p = p.succ
    end
    count
  end

  def includes?(o) : Bool
    return false if o.nil?

    p = first_node
    while p
      item = p.item
      unless item.nil?
        if item == o
          return true
        end
      end

      p = p.succ
    end

    false
  end

  def delete(o)
    return if o.nil?

    p = first_node
    while p
      item = p.item
      unless item.nil?
        if item == o
          p.cas_item(item, nil)
          return o
        end
      end

      p = p.succ
    end

    nil
  end

  def <<(e : E)
    add(e)
    self
  end

  def shift
    poll
  end

  def delete_first(o)
    delete(o)
  end

  def each
    p = first_node
    while p
      item = p.item
      unless item.nil?
        yield item
      end

      p = p.succ
    end
  end

  def concat(arg)
    arg.each { |e| add(e) }
  end

  def last? : E?
    if tail = @tail_updater.lazy_get
      tail.item
    end
  end
end
