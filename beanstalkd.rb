#!/usr/bin/ruby

require 'beanstalk-client'

interval = 10

host = $*
B = Beanstalk::Connection.new "#{host}"

while sleep interval do
    tubes = B.list_tubes

    tubes.each do |tube|
        stats = {
            #'current-watching' => 0,
            #'current-jobs-reserved' => 0,
            'current-jobs-ready' => 0,
            #'current-using' => 0,
            #'current-jobs-buried' => 0,
            #'current-waiting' => 0,
            'current-jobs-delayed' => 0,
            'current-jobs-urgent' => 0
        }


        ts = B.stats_tube(tube)
        ts.keys.sort.each do |key|
            next unless stats.has_key?(key)
            stats[key] += ts[key]
        end

        now = Time.now.to_i

        #puts "#{tube}"
        stats.each do |name, value|
            key = name.split('-').last
            #puts "#{key}.value #{value}"
            if key == 'ready'
                puts "PUTVAL #{host}.fotolia.loc/beanstalkd/gauge-#{tube} interval=#{interval} #{now}:#{value}"
            end
            
            if key == 'delayed'
                puts "PUTVAL #{host}.fotolia.loc/beanstalkd/gauge-#{tube}-delayed interval=#{interval} #{now}:#{value}"
            end
            
            if key == 'urgent'
                puts "PUTVAL #{host}.fotolia.loc/beanstalkd/gauge-#{tube}-urgent interval=#{interval} #{now}:#{value}"
            end
        end
    end
end
