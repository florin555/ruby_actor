class Actor
  class MessageBus
    def push(message)
      @on_message.call(message)
    end

    def on_message(&block)
      @on_message = block
    end
  end

  attr_reader :inbox
  attr_reader :outbox

  def initialize(&block)
    @block = block
    @outbox = MessageBus.new
    @inbox = MessageBus.new
  end

  def run
    @thread = Thread.new do
      @block.call(@outbox)
    end
    @thread.abort_on_exception = true
    @thread.report_on_exception = false

    nil
  end

  def join
    @thread.join
  end

  def on_stop(&block)
    @on_stop = block
  end

  def stop
    @thread.kill
    @on_stop.call if @on_stop
  end
end
