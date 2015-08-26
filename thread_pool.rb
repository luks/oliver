# require 'thread'
# module Oliver
#   class ThreadPool
#     class Worker
#       def initialize
#         @mutex = Mutex.new
#         @thread = Thread.new do
#           while true
#             sleep 0.001
#             block = get_block
#             if block
#               block.call
#               reset_block
#             end
#           end
#         end
#       end

#       def get_block
#         @mutex.synchronize {@block}
#       end

#       def set_block(block)
#         @mutex.synchronize do
#           raise RuntimeError, "Thread already busy." if @block
#           @block = block
#         end
#       end

#       def reset_block
#         @mutex.synchronize {@block = nil}
#       end

#       def busy?
#         @mutex.synchronize {!@block.nil?}
#       end
#     end

#     attr_accessor :max_size
#     attr_reader :workers
#     def initialize(max_size = 10)
#       @max_size = max_size
#       @workers = []
#       @mutex = Mutex.new
#     end

#     def size
#       @mutex.synchronize {@workers.size}
#     end

#     def busy?
#       @mutex.synchronize {@workers.any? {|w| w.busy?}}
#     end

#     def join
#       sleep 0.01 while busy?
#     end

#     def process(&block)
#       wait_for_worker.set_block(block)
#     end

#     def wait_for_worker
#       while true
#         worker = find_available_worker
#         return worker if worker
#         sleep 0.01
#       end
#     end

#     def find_available_worker
#       @mutex.synchronize {free_worker || create_worker}
#     end

#     def free_worker
#       @workers.each {|w| return w unless w.busy?}; nil
#     end

#     def create_worker
#       return nil if @workers.size >= @max_size
#       worker = Worker.new
#       @workers << worker
#       worker
#     end
#   end
# end

module Oliver
  # A simple thread pool management object.
  #
  class ThreadPool

    # Maintain a minimum of +min+ and maximum of +max+ threads
    # in the pool.
    #
    # The block passed is the work that will be performed in each
    # thread.
    #
    def initialize(min, max, *extra, &blk)
      @cond = ConditionVariable.new
      @mutex = Mutex.new

      @todo = []

      @spawned = 0
      @waiting = 0

      @min = min
      @max = max
      @block = blk
      @extra = extra

      @shutdown = false

      @trim_requested = 0

      @workers = []

      @auto_trim = nil

      @mutex.synchronize do
        min.times { spawn_thread }
      end
    end

    attr_reader :spawned, :trim_requested

    # How many objects have yet to be processed by the pool?
    #
    def backlog
      @mutex.synchronize { @todo.size }
    end

    # :nodoc:
    #
    # Must be called with @mutex held!
    #
    def spawn_thread
      @spawned += 1

      th = Thread.new do
        todo  = @todo
        block = @block
        mutex = @mutex
        cond  = @cond

        extra = @extra.map { |i| i.new }

        while true
          work = nil
          continue = true

          mutex.synchronize do
            while todo.empty?
              if @shutdown
                continue = false
                break
              end

              @waiting += 1
              cond.wait mutex
              @waiting -= 1
            end

            work = todo.pop if continue
          end

          break unless continue

          block.call(work, *extra)
        end

        mutex.synchronize do
          @spawned -= 1
          @workers.delete th
        end
      end

      @workers << th

      th
    end

    private :spawn_thread

    # Add +work+ to the todo list for a Thread to pickup and process.
    def <<(work)
      @mutex.synchronize do
        if @shutdown
          raise "Unable to add work while shutting down"
        end

        @todo << work

        if @waiting == 0 and @spawned < @max
          spawn_thread
        end

        @cond.signal
      end
    end

    # If too many threads are in the pool, tell one to finish go ahead
    # and exit. If +force+ is true, then a trim request is requested
    # even if all threads are being utilized.
    #
    def trim(force=false)
      @mutex.synchronize do
        if (force or @waiting > 0) and @spawned - @trim_requested > @min
          @trim_requested += 1
          @cond.signal
        end
      end
    end

    class AutoTrim
      def initialize(pool, timeout)
        @pool = pool
        @timeout = timeout
        @running = false
      end

      def start!
        @running = true

        @thread = Thread.new do
          while @running
            @pool.trim
            sleep @timeout
          end
        end
      end

      def stop
        @running = false
        @thread.wakeup
      end
    end

    def auto_trim!(timeout=5)
      @auto_trim = AutoTrim.new(self, timeout)
      @auto_trim.start!
    end

    # Tell all threads in the pool to exit and wait for them to finish.
    #
    def shutdown
      @mutex.synchronize do
        @shutdown = true
        @cond.broadcast

        @auto_trim.stop if @auto_trim
      end

      # Use this instead of #each so that we don't stop in the middle
      # of each and see a mutated object mid #each
      @workers.first.join until @workers.empty?

      @spawned = 0
      @workers = []
    end
  end
end
