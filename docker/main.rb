require 'webrick'

server = WEBrick::HTTPServer.new(
    DocumentRoot: './',
    BindAddres: '0.0.0.0',
    Port: 8000
)

server.mount_proc('/') do |req,res|
    res.body = 'helo'
end

server.start
