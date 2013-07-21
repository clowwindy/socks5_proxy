socks5-proxy
===========

A simple socks5 proxy with TCP and UDP support.

Usage
-----------

Download the lastest Node stable release. You can find them [here](http://nodejs.org/). Don't just use master branch of
Node source code from Github! It's not stable.

Create a file named `config.json`, with the following content.

    {
        "local_port":1080,
        "timeout":600
    }

Explaination of the fields:

    local_port      local port
    timeout         in seconds

`cd` into the directory of `config.json`. Run `bin/socks5` on your server. To run it in the background, run
`nohup bin/socks5 > log &`.

Change the proxy setting in your browser into

    protocol: socks5
    hostname: 127.0.0.1
    port:     your local_port

License
-----------------
MIT
