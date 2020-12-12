
module Archelaus

  class << self

    def http_get(uri, query)

      u = URI(uri)

      uq = query
        .inject(uri) { |r, (k, v)|
          "#{r}#{r.match(/\?/) ? '&' : '?'}#{k}=#{CGI.escape(v)}" }
p uri
p uq

      req = Net::HTTP::Get.new(uq)
      req.add_field('Content-Type', 'application/json')

      http = Net::HTTP.new(u.host, u.port)
        #
      if u.scheme == 'https'
        http.use_ssl = true
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      res = http.request(req)

      res.read_body
    end
  end
end


