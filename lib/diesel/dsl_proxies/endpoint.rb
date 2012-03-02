class Diesel::DSLProxies::Endpoint < Diesel::DSLProxy
  # Delegate to our pblock if we don't answer a method
  alias_method :orig_respond_to?, :respond_to?
  def respond_to?(m)
    orig_respond_to?(m) || @subject.pblock.dsl_proxy.respond_to?(m)
  end

  alias_method :orig_mm, :method_missing
  def method_missing(m, *args, &block)
    if @subject.pblock.dsl_proxy.respond_to?(m)
      @subject.pblock.dsl_proxy.send(m, *args, &block)
    else
      orig_mm(m, *args, &block)
    end
  end

  def handle(request = nil)
    if block_given?
      @handler = Proc.new
    elsif request && @handler.is_a?(Proc)
      Diesel::ResponseContext.new(request, @handler).respond
    end
  end
end