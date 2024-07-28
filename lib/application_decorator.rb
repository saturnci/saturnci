class ApplicationDecorator
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def method_missing(method, *args, &block)
    @object.send(method, *args, &block)
  end
end
