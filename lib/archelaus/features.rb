
module Archelaus

  OVERPASS_URI = 'http://overpass-api.de/api/interpreter'

  class << self

    def fetch_features(grid)

      p0p1 = grid.swne.collect(&:to_fixed5).join(',')

      d = 0.0002
      p0p1b =
        grid.swne
      p0p1b =
        [ p0p1b[0] - d, p0p1b[1] - d, p0p1b[2] + d, p0p1b[3] + d ]
          .collect(&:to_fixed5).join(',')

      q = %{
        [out:json];
        (
          way[waterway=river](#{p0p1b});
          way[waterway=stream](#{p0p1b});
          way[natural=water](#{p0p1b});

          way[natural=wood](#{p0p1b});
          way[landuse=forest](#{p0p1b});

          way[amenity=place_of_worship](#{p0p1});

          node[historic](#{p0p1});
          node[natural=spring](#{p0p1});
          node[natural=peak](#{p0p1});

          rel[type=multipolygon][landuse=forest](#{p0p1b});
          rel[type=multipolygon][water](#{p0p1b});
        );
        (._;>;);
        out;
      }
        .split("\n").collect(&:strip).reject { |e| e[0, 1] == '#' }.join('')

      http_get(OVERPASS_URI, data: q)
    end
  end

  class Grid

    attr_reader :features

    def load_features

      d = JSON.parse(File.read(features_path)) rescue nil; return unless d
      @features = Archelaus::FeatureDict.new(self, d)

      r = File.read(patch_path) rescue nil
      Kernel.eval(r, binding) if r
    end

    protected

    def features_path

      File.join(
        'var/features',
        "f__#{origin}_#{origin_corner.lat.to_fixed5}_#{origin_corner.lon.to_fixed5}.json")
    end

    def patch_path

      File.join(
        'var/features',
        "f__#{origin}_#{origin_corner.lat.to_fixed5}_#{origin_corner.lon.to_fixed5}.rb")
    end
  end

  class FeatureDict

    attr_reader :grid
    attr_reader :nodes, :ways#, :relations
    attr_reader :blocked_hexes

    def initialize(grid, data)

      @grid = grid

      elements = data['elements'].inject({}) { |h, e| h[e['id']] = e; h }
      @nodes = {}
      @ways = {}
      #@relations = {}

      data['elements']
        .each do |e|
          next unless e['type'] == 'relation'
          next unless e['tags']['type'] == 'multipolygon'
          t = e['tags']
          wood = t['landuse'] == 'forest' || t['natural'] == 'wood'
          next unless wood
#$stderr.puts("-" * 80)
#$stderr.puts(e.inspect)
          e['members'].each do |m|
            me = elements[m['ref']]
            (me['tags'] ||= {})['landuse'] = 'forest'
          end
        end
          #
          # flag the members of the polygons as "forest"

      data['elements']
        .each do |e|
          case e['type']
          when 'node'
            @nodes[e['id']] = Archelaus::FeatureDict::Node.new(self, e)
          when 'way'
            @ways[e['id']] = Archelaus::FeatureDict::Way.new(self, e)
          #when 'relation'
          #  @relations[e['id']] = Archelaus::FeatureDict::Relation.new(self, e)
          end
        end

      @blocked_hexes = { waterway: [] }
    end

    def block_hex(type, x, y)

      (@blocked_hexes[type.to_sym] ||= []) << [ x, y ]
    end

    def node(i); @nodes[i]; end
    def way(i); @ways[i]; end
    #def relation(i); @relations[i]; end

    def waterways

      @waterways ||=
        @ways.values.select { |w| w.tags.keys.include?('waterway') }
    end

    def lakes

      @lakes ||=
        @ways.values.select { |w| w.tags['natural'] == 'water' }
    end

    def woods

      @woods ||=
        @ways.values.select { |w|
          w.tags['landuse'] == 'forest' ||
          w.tags['natural'] == 'wood' }
    end

    def make_node(data)

      data[:id] =
        begin
          i = 1; i = i + 1 while @nodes.has_key?(i)
          i
        end unless data[:id]

      d = data.inject('type' => 'node') { |h, (k, v)| h[k.to_s] = v; h }

      @nodes[d['id']] = Archelaus::FeatureDict::Node.new(self, d)

      d['id']
    end

    def nodes(point)

      @nodes.values
        .select { |n| point.compute_distance(n) < 90 }
        .collect(&:id)
    end

    class Nwr

      attr_reader :dict, :data

      def initialize(dict, d); @dict = dict; @data = d; end

      def id; @data['id']; end
      def type; @data['type']; end
      def tags; @data['tags'] || {}; end

      def t

        @t ||=
          self.class.name.split('::').last[0, 1].downcase + id.to_s + ' ' +
          tags
            .collect { |k, v| rewrite_tag(k, v) }
            .compact
            .join(', ')
      end

      protected

      def grid; @dict.grid; end

      def rewrite_tag(k, v)

        km = "rewrite_tag_key_#{k}"
        return send(km, k, v) if respond_to?(km, true)

        vm = "rewrite_tag_val_#{k}"
        return send(vm, k, v) if respond_to?(vm, true)

        "#{k.gsub(/_/,' ')}: #{v}"

        # "leaf type: needleleaved"
        # "leaf type: broadleaved"
        #   :-)
      end

      def rewrite_tag_drop_key(_, v); v; end
      def rewrite_discard(_, _); nil; end

      alias rewrite_tag_key_source rewrite_discard
      alias rewrite_tag_key_natural rewrite_tag_drop_key
      alias rewrite_tag_key_landuse rewrite_tag_drop_key
      alias rewrite_tag_key_water rewrite_tag_drop_key
      alias rewrite_tag_key_waterway rewrite_tag_drop_key
      alias rewrite_tag_key_name rewrite_tag_drop_key
    end

    class Node < Nwr

      def lat; @data['lat']; end
      def lon; @data['lon']; end
      def latlon; [ @data['lat'], @data['lon'] ]; end
    end

    class Way < Nwr

      def sid; "s#{@data['id']}"; end

      def nodes

        @nodes ||=
          @data['nodes'].collect { |i| dict.node(i) }
      end

      def hexes

        @hexes ||=
          filter(nodes.collect { |n| grid.locate(n.lat, n.lon) }.uniq.compact)
      end

      #def eles
      #  @eles ||=
      #    hexes.collect { |h| h.ele }.uniq.sort_by { |e| e || 0 }
      #end
      #def min_ele; @ele_min ||= eles.min; end
      #def max_ele; @ele_max ||= eles.max; end

      def add_node(id, y=nil)

        if y
          point = grid[id, y]
          @data['nodes'] << dict.make_node(lat: point.lat, lon: point.lon)
        else
          @data['nodes'] << id
        end
      end

      def remove_node(x, y)

        point = grid[x, y]
        nids = dict.nodes(point)
        @data['nodes'] = @data['nodes'] - nids
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

        blocked_hexes = dict.blocked_hexes[:waterway]
#rp blocked_hexes & hexes.collect(&:xy)

        hexes.reject { |h| h.ele == nil || blocked_hexes.include?(h.xy) }
      end
    end

    class Relation < Nwr

      def initialize(dict, d);
        @dict = dict; @data = d;
      end
    end
  end
end

