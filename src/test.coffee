# A SOCKS5 UDP test client
net = require("net")
dgram = require 'dgram'

inetNtoa = (buf) ->
  buf[0] + "." + buf[1] + "." + buf[2] + "." + buf[3]
  
inetAton = (ipStr) ->
  parts = ipStr.split(".")
  unless parts.length is 4
    null
  else
    buf = new Buffer(4)
    i = 0

    while i < 4
      buf[i] = +parts[i]
      i++
    buf
  

d = dgram.createSocket('udp4')
d.on 'message', (data, rinfo) ->
  console.log data
  c = dgram.createSocket('udp4')
  c.send(data, 0, data.length, rinfo.port, rinfo.address, ->
    console.log "server"
    console.log c.address()
    c.close()
  )
  
d.bind(80)

conn = net.connect(1081, "127.0.0.1", ->
  conn.write new Buffer("\x05\x02\x00\x01")
)

step = 0
conn.on "data", (data) ->
  console.log data
  console.log "conn addr", conn.address()
  if step is 0
    conn.write new Buffer("\x05\x03\x00\x01\x00\x00\x00\x00\x00\x00")
  if step is 1
    ip = inetNtoa(data.slice(4, 8))
    port = data.readUInt16BE(8)
    console.log ip, port
    data = new Buffer("\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00hello world\n")
    ipBuf = inetAton("172.16.1.100")
    ipBuf.copy data, 4, 0, ip.length
    data.writeUInt16BE 80, 8
    console.log "send"
    console.log data
    c = dgram.createSocket 'udp4'
    c.on 'message', (data, rinfo) ->
      console.log "receive"
      console.log "c addr", c.address()
      console.log "c rinfo", rinfo
      console.log data
    c.send data, 0, data.length, port, ip, (err, bytes) ->
      console.log "c addr", c.address()
      
  step += 1

