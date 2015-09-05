require 'thread'

module Oliver

  class ThreadPool

    def initialize(min, max, &block)
      # this pool is simmilar to blocking queue
      # it is waiting for something to be pushed into storage
      # then it is proccessing it by block, so it is generic functionality
      # is defined in block on each instance
      # Then bolck is spawned min - max times  
      @storage = Array.new
      @mutex = Mutex.new
      # semafor to wake up threads when something is pushed into storage
      @work_semaphore = ConditionVariable.new

      @min = Integer(min)
      @max = Integer(max)

      @threads = Array.new

      @spawned = 0
      @waiting = 0

      # block which will be executed by all threads in this pool
      @block = block

      @shutdown = false

      @trim_requested = 0
      @auto_trim = nil
      @reaper = nil

      @mutex.synchronize do
        @min.times { spawn_thread }
      end
    end

    attr_reader :spawned, :trim_requested

    def backlog
      @mutex.synchronize { @storage.size }
    end

    def spawn_thread
      @spawned += 1

      th = Thread.new do
        storage = @storage
        block   = @block
        mutex   = @mutex
        work_semaphore = @work_semaphore

        while true
          work = nil

          continue = true

          mutex.synchronize do
            while storage.empty?
              if @trim_requested > 0
                @trim_requested -= 1
                continue = false
                break
              end

              if @shutdown
                continue = false
                break
              end

              @waiting += 1
              work_semaphore.wait mutex
              @waiting -= 1
            end

            work = storage.shift if continue
          end

          break unless continue

          begin
            block.call(work)
          rescue Exception => e
            raise e
          end
        end

        mutex.synchronize do
          @spawned -= 1
          @threads.delete th
        end
      end

      @threads << th

      th
    end

    private :spawn_thread

    # Add +work+ to the storage list for a Thread to pickup and process.
    def <<(work)
      @mutex.synchronize do
        if @shutdown
          raise "Unable to add work while shutting down"
        end

        @storage << work

        if @waiting < @storage.size and @spawned < @max
          spawn_thread
        end

        @work_semaphore.signal
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
          @work_semaphore.signal
        end
      end
    end

    # If there are dead threads in the pool make them go away while decreasing
    # spwaned counter so that new healty threads could be created again.
    def reap
      @mutex.synchronize do
        dead_threads = @threads.reject(&:alive?)

        dead_threads.each do |worker|
          worker.kill
          @spawned -= 1
        end

        @threads -= dead_threads
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

    class Reaper
      def initialize(pool, timeout)
        @pool = pool
        @timeout = timeout
        @running = false
      end

      def start!
        @running = true

        @thread = Thread.new do
          while @running
            @pool.reap
            sleep @timeout
          end
        end
      end

      def stop
        @running = false
        @thread.wakeup
      end
    end

    def auto_reap!(timeout=5)
      @reaper = Reaper.new(self, timeout)
      @reaper.start!
    end

    # Tell all threads in the pool to exit and wait for them to finish.
    #
    def shutdown
      @mutex.synchronize do
        @shutdown = true
        @work_semaphore.broadcast
        @auto_trim.stop if @auto_trim
        @reaper.stop if @reaper
      end

      # Use this instead of #each so that we don't stop in the middle
      # of each and see a mutated object mid #each
      if !@threads.empty?
          @threads.first.join until @threads.empty?
      end

      @spawned = 0
      @threads = []
    end
  end
end
