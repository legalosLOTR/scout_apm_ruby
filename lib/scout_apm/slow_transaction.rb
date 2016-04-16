module ScoutApm
  class SlowTransaction
    include ScoutApm::BucketNameSplitter

    attr_reader :metric_name
    attr_reader :total_call_time
    attr_reader :metrics
    attr_reader :meta
    attr_reader :uri
    attr_reader :context
    attr_reader :time
    attr_reader :prof
    attr_reader :raw_prof
    attr_reader :mem_delta
    attr_reader :allocations
    attr_accessor :hostname # hack - we need to reset these server side.
    attr_accessor :seconds_since_startup # hack - we need to reset these server side.

    def initialize(uri, metric_name, total_call_time, metrics, context, time, raw_stackprof, mem_delta, allocations)
      @uri = uri
      @metric_name = metric_name
      @total_call_time = total_call_time
      @metrics = metrics
      @context = context
      @time = time
      @prof = ScoutApm::StackprofTreeCollapser.new(raw_stackprof).call
      @raw_prof = raw_stackprof # Send whole data up to server
      @mem_delta = mem_delta
      @allocations = allocations
      @seconds_since_startup = (Time.now - ScoutApm::Agent.instance.process_start_time)
      @hostname = ScoutApm::Environment.instance.hostname
      ScoutApm::Agent.instance.logger.debug { "Slow Request [#{uri}] - Call Time: #{total_call_time} Mem Delta: #{mem_delta}"}
    end

    # Used to remove metrics when the payload will be too large.
    def clear_metrics!
      @metrics = nil
      self
    end

    def has_metrics?
      metrics and metrics.any?
    end

    def as_json
      json_attributes = [:key, :time, :total_call_time, :uri, [:context, :context_hash], :prof, :mem_delta, :allocations, :seconds_since_startup, :hostname]
      ScoutApm::AttributeArranger.call(self, json_attributes)
    end

    def context_hash
      context.to_hash
    end
  end
end
