
require 'json'


module Make
  class << self

    def liste

      Dir['var/elevations/**/*.json']
        .each do |pa|
          d = JSON.parse(File.read(pa))
          puts "#{pa[13..-1]}: ele: #{d['ele'].inspect}"
        end
    end
  end
end

