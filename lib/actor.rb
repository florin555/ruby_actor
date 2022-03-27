class Actor
  class MessageBus
    def initialize
      @messages = Thread::Queue.new
    end

    def push(message)
      @messages << message
    end

    def pop
      @messages.pop
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
      @block.call(@outbox, @inbox)
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
