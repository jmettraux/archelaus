
# https://www.opentopodata.org/api/

# europe !
# curl "https://api.opentopodata.org/v1/eudem25m?locations=57.688709,11.976404|57.2,11.8"

# To keep the public API sustainable some limitations are applied.
#
# Max 100 locations per request.
# Max 1 call per second.
# Max 1000 calls per day.

module Archelaus

  class << self

    def get_elevations(points)

      fail ArgumentError.new("too many points #{points.length} > 100") \
        if points.length > 100
    end
  end
end

