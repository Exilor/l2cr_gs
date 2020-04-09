struct Set(T)
  def reject!(& : T ->)
    each do |e|
      if yield e
        delete(e)
      end
    end

    self
  end
end
