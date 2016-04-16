module ScoutApm
  module Serializers
    class SlowJobsSerializerToJson
      attr_reader :jobs

      # Jobs is a series of slow job records
      def initialize(jobs)
        @jobs = jobs
      end

      # An array of job records
      def as_json
        jobs.map do |job|
          {
            "queue" => job.queue_name,
            "name" => job.job_name,
            "time" => job.time,
            "total_time" => job.total_time,
            "exclusive_time" => job.exclusive_time,
            "mem_delta" => job.mem_delta,
            "allocations" => job.allocations,
            "seconds_since_startup" => job.seconds_since_startup,
            "hostname" => job.hostname,
            "metrics" => MetricsToJsonSerializer.new(job.metrics).as_json, # New style of metrics
            "context" => job.context,
          }
        end
      end
    end
  end
end

