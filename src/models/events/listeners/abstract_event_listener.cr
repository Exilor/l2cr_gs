# If this class is a struct a segmentation fault happens on login with tutorial.
# L2J makes this class comparable to be used in a priority queue, but we don't
# have priority queues.
# Also, only test listeners appear to use the priority. Looks like they expected
# that it would become necessary at some point.
abstract class AbstractEventListener
  # include Comparable(AbstractEventListener)

  # unused
  # property priority : Int32 = 0

  private alias OwnerType = L2Object | AbstractScript | AbstractEffect | NevitSystem

  getter_initializer container: ListenersContainer, type: EventType,
    owner: OwnerType?

  abstract def execute_event(event : BaseEvent, return_class : (T.class)?) : T forall T

  def unregister_me
    container.remove_listener(self)
  end

  # def <=>(other : AbstractEventListener) : Int32
  #   priority <=> other.priority
  # end
end
