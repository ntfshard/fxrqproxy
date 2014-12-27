#!/usr/bin/env ruby

require 'webrick'
require 'webrick/httpproxy'

# changing request from user to server
$enable_change_request = true
$request_regexp = /neco/
$request_target = 'hentai'

# changing server responce before user can see it
$enable_change_response = true
$response_regexp = /hentai/
$response_target = 'nya'

handler = proc do |req, res|
	if($enable_change_response)
		res.body.gsub!($response_regexp, $response_target)
	end
end

module WEBrick
	class ChangeRqProxy < HTTPProxyServer
		def proxy_service(req, res)
			if($enable_change_request)
				regexp = /neco/
				#p req
				#p req.request_method  can be "GET", "CONNECT"(for https), ...
				req.unparsed_uri.gsub!($request_regexp, $request_target)
				req.request_line.gsub!($request_regexp, $request_target)
				#req.request_uri  is a #<URI::HTTP:0x000006003fdeb8 URL:http://127.1.10.1:10000/?neco=nya>
				req.query_string.gsub!($request_regexp, $request_target)	if req.query_string
			end
			super(req, res)
		end
	end
end

proxy = WEBrick::ChangeRqProxy.new(Port: 8000, ProxyContentHandler: handler)

trap 'INT'  do proxy.shutdown end
trap 'TERM' do proxy.shutdown end

proxy.start
