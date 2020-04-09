require "xml"

struct XML::Node
  def each_element
    children.each do |child|
      yield child if child.element?
    end

    nil
  end

  def find_element(name : String)
    each_element do |e|
      yield e if e.name.compare(name, true) == 0
    end
  end
end

struct XML::Attributes
  def each_pair(& : String, String ->)
    each do |node|
      yield node.name, node.content
    end

    nil
  end

  def to_a
    ret = [] of {String, String}
    each_pair { |k, v| ret << {k, v} }
    ret
  end
end
