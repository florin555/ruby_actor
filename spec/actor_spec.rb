require_relative '../lib/actor'

require 'socket'

describe Actor do
  def elements(queue)
    array = []

    queue.close
    while !queue.empty?
      array << queue.pop
    end

    array
  end

  around(:each) do |example|
    threads_before = Thread.list.size
    example.run
    threads_after = Thread.list.size
    expect(threads_after).to eq(threads_before)
  end

  describe 'basics' do
    it 'can run some code' do
      queue = Thread::Queue.new

      actor = Actor.new do
        queue << 500
      end

      actor.run
      actor.join

      expect(elements(queue)).to match [500]
    end

    it 'bubbles up errors to the main thread' do
      actor = Actor.new do
        raise 'an error'
      end

      expect do
        actor.run
        sleep
      end.to raise_error 'an error'
    end

    it 'can be stopped' do
      queue = Thread::Queue.new

      i = 100
      actor = Actor.new do
        while true
          queue << i
          i += 1
          sleep 0.1
        end
      end

      actor.run
      sleep 0.15
      actor.stop

      sleep 0.1

      expect(elements(queue)).to match [100, 101]
    end

    it 'supports running code on shutdown' do
      # In the current implementation the "on_stop" code is executed in the main thread.
      # There seems to be a possibility to run the cleanup code in the thread being stopped.
      # I am not sure if that is ever needed, but in case I want to switch the implementation,
      # here is an example: https://stackoverflow.com/a/67744953/323433
      #
      # See also next test.

      queue = Thread::Queue.new

      actor = Actor.new do
        queue << 100
        sleep
      end
      actor.on_stop do
        queue << 200
      end

      actor.run
      sleep 0.1
      actor.stop

      expect(elements(queue)).to match [100, 200]
    end

    it 'stops the thread before running the shutdown script from the main thread' do
      # This test has the purpose of showing what would happen if we don't
      # stop the thread before running the shutdown code on the main thread.
      # To see how it fails go and comment out the `@thread.kill` line
      # in the Actor#stop method.
      # You will get this error: IOError: stream closed in another thread

      queue = Thread::Queue.new

      server = TCPServer.new 50001

      actor = Actor.new do
        @socket = TCPSocket.new 'localhost', 50001

        while line = @socket.gets
          queue << line.strip
        end

        queue << 'We should never get here'
      end
      actor.on_stop do
        @socket.close
      end

      actor.run

      client = server.accept

      client.puts 'line 1'
      sleep 0.1
      client.puts 'line 2'
      sleep 0.1

      actor.stop

      expect(elements(queue)).to match ["line 1", "line 2"]
    end
  end

  describe 'message passing' do
    it 'can send messages to an outbox' do
      messages = Thread::Queue.new

      actor = Actor.new do |_, outbox|
        outbox.push 100
        outbox.push 200
      end

      actor.run

      messages << actor.outbox.pop
      messages << actor.outbox.pop

      expect(elements(messages)).to match [100, 200]
    end

    it 'can receive messages trough an inbox' do
      messages = Thread::Queue.new

      actor = Actor.new do |inbox|
        while true
          messages << inbox.pop
        end
      end

      actor.run

      actor.inbox.push 300
      actor.inbox.push 400

      sleep 0.1
      actor.stop

      expect(elements(messages)).to match [300, 400]
    end

    it 'is possible to pipe the output of one actor into the input of another' do
      actor_1 = Actor.new do |inbox, outbox|
        while true
          outbox << inbox.pop.upcase
        end
      end
      actor_2 = Actor.new do |inbox, outbox|
        while true
          outbox << inbox.pop.reverse
        end
      end

      actor_1.pipe(actor_2)

      actor_1.run
      actor_2.run

      actor_1.inbox.push 'abc'
      actor_1.inbox.push 'def'

      result = []

      result << actor_2.outbox.pop
      result << actor_2.outbox.pop

      expect(result).to match(['CBA', 'FED'])

      actor_1.stop
      actor_2.stop
    end
  end
end
