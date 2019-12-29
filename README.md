# xmrpc

A small utility for calling the Monero JSON RPC interface(s).

When developing software that uses the Monero RPC interface, one often ends up
using `curl` to test the methods. This little script just aids the lazy from
typing out the long `curl` commands or formatting the JSON payload.

## Install

Just copy [xmrpc.sh](./xmrpc.sh) to somewhere in your `PATH`.

## Usage

    xmrpc.sh [host:]port method [name:value ...]

### Examples

    xmrpc.sh 28081 get_version
    xmrpc.sh node.xmr.to:18081 get_version
    xmrpc.sh 28081 get_block height:123456
    xmrpc.sh 28081 get_block hash:aaaac8fe6bd05f32aa68b9bd13d66d2056335a1a4a88c788f7a07ab8a1e64912
    xmrpc.sh 28084 get_transfers in:true
    xmrpc.sh 28084 get_address account_index:0 address_index:[0,1]

### Searching

If you have the Monero source tree and set an enviroment variable `MONERO_ROOT`
to its path, you can then use the `doc` command to search methods and get the
expected parameters from the code. For example:

    xmrpc.sh doc transfer
    xmrpc.sh doc ".*bulk.*pay"
    xmrpc.sh doc ".*pay"
    xmrpc.sh doc ".*"

## Supporting the project

If you use it and want to donate, XMR donations to:

```
451ytzQg1vUVkuAW73VsQ72G96FUjASi4WNQse3v8ALfjiR5vLzGQ2hMUdYhG38Fi15eJ5FJ1ZL4EV1SFVi228muGX4f3SV
```

![QR code](./qr-small.png)

would be very much appreciated.

## License

Please see the [LICENSE](./LICENSE) file.

[//]: # ( vim: set tw=80: )
