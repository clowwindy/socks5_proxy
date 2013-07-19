utils = require('./utils')

inetNtoa = (buf) ->
  buf[0] + "." + buf[1] + "." + buf[2] + "." + buf[3]

dgram = require 'dgram'

# +----+------+------+----------+----------+----------+
# |RSV | FRAG | ATYP | DST.ADDR | DST.PORT |   DATA   |
# +----+------+------+----------+----------+----------+
# | 2  |  1   |  1   | Variable |    2     | Variable |
# +----+------+------+----------+----------+----------+

exports.createServer = (port, timeout) ->
  # TODO close sockets after timeout if there is no traffic
  server = dgram.createSocket("udp4")

  server.on("message", (data, rinfo) ->
    console.log("server got: " + data + " from " + rinfo.address + ":" + rinfo.port)
    frag = data[2]
    utils.debug "frag:#{frag}"
    if frag != 0
      utils.wran "drop a message since frag is not 0"
      return
    addrtype = data[3]
    if addrtype is 3
      addrLen = data[4]
    else unless addrtype in [1, 4]
      utils.error "unsupported addrtype: " + addrtype
      connection.destroy()
      return
    # read address and port
    if addrtype is 1
      remoteAddr = inetNtoa(data.slice(4, 8))
      remotePort = data.readUInt16BE(8)
      headerLength = 10
    else if addrtype is 4
      remoteAddr = inet.inet_ntop(data.slice(4, 20))
      remotePort = data.readUInt16BE(20)
      headerLength = 22
    else
      remoteAddr = data.slice(5, 5 + addrLen).toString("binary")
      remotePort = data.readUInt16BE(5 + addrLen)
      headerLength = 5 + addrLen + 2
    utils.debug "UDP send to #{remoteAddr}:#{remotePort}"
    
    client = dgram.createSocket("udp4")
    client.on "message", (data1, rinfo1) ->
      utils.debug "client got #{data1} from #{rinfo1.address}:#{rinfo1.port}"
      data2 = Buffer.concat([data.slice(0, headerLength), data1])
      server.send data2, 0, data2.length, rinfo.port, rinfo.address, (err, bytes) ->
        utils.debug "remote to client sent"

    client.on "error", (err) ->
      utils.debug "error: #{err}"

    client.send data, headerLength, data.length - headerLength, remotePort, remoteAddr, (err, bytes) ->
      utils.debug "client to remote sent"

  )
  
  server.on("listening", ->
    address = server.address()
    console.log("server listening " + address.address + ":" + address.port)
  ) 
  
  server.bind(port)
  
  return server