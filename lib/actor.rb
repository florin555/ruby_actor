class Actor
  class Outbox
    def push(message)
      @on_message.call(message)
    end

    def on_message=(block)
      @on_message = block
    end

    def on_message(&block)
      self.on_message = block
    end
  end

  attr_reader :inbox

  def initialize(&block)
    @block = block
    @outbox = Outbox.new
    @inbox = Outbox.new
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

  def on_message(&block)
    @outbox.on_message = block
  end

  def stop
    @thread.kill
    @on_stop.call if @on_stop
  end
end
