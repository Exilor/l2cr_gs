module Enumerable(T)
  def safe_each(& : T ->)
    each { |e| yield e }
  end
end
