
module Archelaus

  OVERPASS_URI = 'http://overpass-api.de/api/interpreter'

  class << self

    def fetch_features(grid)

      p0p1 = grid.swne.collect(&:to_fixed5).join(',')

      q = %{
        [out:json];
        (
          way[waterway=river](#{p0p1});
          way[waterway=stream](#{p0p1});
          way[natural=water](#{p0p1});

          way[natural=wood](#{p0p1});
          way[landuse=forest](#{p0p1});

          way[amenity=place_of_worship](#{p0p1});

          node[historic](#{p0p1});
          node[natural=spring](#{p0p1});
        );
        (._;>;);
        out;
      }
        .split("\n").collect(&:strip).reject { |e| e[0, 1] == '#' }.join('')

      puts http_get(OVERPASS_URI, data: q)
    end
  end

  class Grid

    attr_reader :features

    def load_features

      d = JSON.parse(File.read(features_path)) rescue nil; return unless d
      @features = Archelaus::FeatureDict.new(self, d)
    end

    protected

    def features_path

      File.join(
        'var/features',
        "f__#{origin}_#{origin_corner.lat.to_fixed5}_#{origin_corner.lon.to_fixed5}.json")
    end
  end

  class FeatureDict

    attr_reader :grid
    attr_reader :nodes, :ways, :relations

    def initialize(grid, data)

      @grid = grid

      @nodes = {}
      @ways = {}
      @relations = {}

      data['elements']
        .each do |e|
          case e['type']
          when 'node'
            @nodes[e['id']] = Archelaus::FeatureDict::Node.new(self, e)
          when 'way'
            @ways[e['id']] = Archelaus::FeatureDict::Way.new(self, e)
          when 'relation'
            @relations[e['id']] = Archelaus::FeatureDict::Relation.new(self, e)
          end
        end
    end

    def node(i); @nodes[i]; end
    def way(i); @ways[i]; end
    def relation(i); @relations[i]; end

    def waterways

      @waterways ||=
        @ways.values.select { |w| w.tags.keys.include?('waterway') }
    end

    class Nwr
      attr_reader :dict, :data
      def initialize(dict, d); @dict = dict; @data = d; end
      def id; @data['id']; end
      def type; @data['type']; end
      def tags; @data['tags'] || {}; end
      protected
      def grid; @dict.grid; end
    end
    class Node < Nwr
      def lat; @data['lat']; end
      def lon; @data['lon']; end
    end
    class Way < Nwr
      def nodes
        @nodes ||=
          @data['nodes'].collect { |i| dict.node(i) }
      end
      def hexes
        @hexes ||=
          filter(nodes.collect { |n| grid.locate(n.lat, n.lon) }.uniq.compact)
      end
      protected
      def filter(hexes)
        if tags['waterway']
          filter_waterway(hexes)
        else
          hexes
        end
      end
      def filter_waterway(hexes)
        hexes.reject { |h| h.ele == nil }
      end
    end
    class Relation < Nwr
    end
  end
end

