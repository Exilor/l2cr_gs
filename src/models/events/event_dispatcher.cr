require "./containers"

module EventDispatcher
  extend self
  include Loggable

  def notify(event : BaseEvent) : AbstractEventReturn?
    notify(event, nil, Nil)
  end

  def notify(event : BaseEvent, callback_class : T.class) : T? forall T
    notify(event, nil, callback_class)
  end

  def notify(event : BaseEvent, container : ListenersContainer) : AbstractEventReturn?
    notify(event, container, Nil)
  end

  def notify(event : BaseEvent, container : ListenersContainer?, callback_class : T.class) : T? forall T
    if Containers::GLOBAL.has_listener?(event.type) || (container && container.has_listener?(event.type))
      notify_impl(event, container, callback_class)
    end
  rescue e
    error { "Error notifying event #{event} with callback #{callback_class} and container #{container}." }
    error e
    nil
  end

  def async(event : BaseEvent)
    async(event, Slice(ListenersContainer).empty)
  end

  def async(event : BaseEvent, *containers : ListenersContainer)
    async(event, containers)
  end

  def async(event : BaseEvent, containers : Enumerable(ListenersContainer))
    has_listeners = Containers::GLOBAL.has_listener?(event.type) ||
    containers.any? &.has_listener?(event.type)

    if has_listeners
      task = -> { to_multiple_containers(event, containers, Nil) }
      ThreadPoolManager.execute_event(task)
    end
  end

  def delayed(event : BaseEvent, container : ListenersContainer, delay : Int64)
    if Containers::GLOBAL.has_listener?(event.type) || container.has_listener?(event.type)
      task = -> { notify(event, container) }
      ThreadPoolManager.schedule_event(task, delay)
    end
  end

  private def notify_impl(event : BaseEvent, container : ListenersContainer?, callback_class : T.class) : T? forall T
    callback = nil

    if container
      callback = to_listeners(container.get_listeners(event.type), event, callback_class, callback)
    end

    unless callback && callback.abort
      callback = to_listeners(Containers::GLOBAL.get_listeners(event.type), event, callback_class, callback)
    end

    callback
  end

  private def to_listeners(listeners : Enumerable(AbstractEventListener), event : BaseEvent, return_class : T.class, callback : T?) : T? forall T
    listeners.each do |listener|
      rb = listener.execute_event(event, return_class)

      if !rb
        next
      elsif !callback || rb.override
        callback = rb
      elsif rb.abort
        break
      end
    end

    callback.as(T?)
  end

  private def to_multiple_containers(event : BaseEvent, containers : Enumerable(ListenersContainer), callback_class : T.class) : T? forall T
    callback = nil

    containers.each do |container|
      unless callback && callback.abort
        callback = to_listeners(container.get_listeners(event.type), event, callback_class, callback)
      end
    end

    unless callback && callback.abort
      callback = to_listeners(Containers::GLOBAL.get_listeners(event.type), event, callback_class, callback)
    end

    callback
  end
end
