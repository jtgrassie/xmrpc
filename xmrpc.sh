#!/bin/bash

# Copyright (c) 2014-2019, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

usage() {
    me="$(basename $0)"
    cat <<EOF
Usage:
    $me [host:]port method [name:value ...]

Examples:
    xmrpc.sh 28081 get_version
    xmrpc.sh node.xmr.to:18081 get_version
    xmrpc.sh 28081 get_block height:123456
    xmrpc.sh 28081 get_block hash:aaaac8fe6bd05f32aa68b9bd13d66d2056335a1a4a88c788f7a07ab8a1e64912
    xmrpc.sh 28084 get_transfers in:true
    xmrpc.sh 28084 get_address account_index:0 address_index:[0,1]
EOF
    exit -1
}

quote() {
    [[ "$1" =~ ^[0-9]+$ ]] && echo -n "$1" && return
    [[ "$1" =~ ^true|false$ ]] && echo -n "$1" && return
    [[ "${1::1}" == "[" ]] && echo -n "$(parse_arr $1)" && return
    echo -n "\"$1\""
}

parse_arr() {
    let e=${#1}-2
    sz=${1:1:$e}
    a=(${sz//,/ })
    for i in "${!a[@]}"; do
        a[$i]=$(quote ${a[i]})
    done
    aj=$(printf ",%s" "${a[@]}")
    aj=${aj:1}
    echo -n "[${aj}]"
}

parse_nv() {
    nv=(${1//:/ })
    c=${#nv[@]}
    [[ $c == 2 ]] && echo -n "$(quote ${nv[0]}):$(quote ${nv[1]})"
}

[[ $# < 2 ]] && usage;

if [[ "$1" == *:* ]]; then
    url="$1/json_rpc"
else
    url="http://localhost:$1/json_rpc"
fi
shift

method="$1"; shift

payload="{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"$method\""
if [ -n "$1" ]; then
    if [[ "${1::1}" == "[" ]]; then
        payload="$payload,\"params\":$(parse_arr $1)"
    else
        payload="$payload,\"params\":{"
        while [ -n "$1" ]; do
            payload="${payload}$(parse_nv $1)"
            [ -n "$2" ] && payload="$payload,"
            shift
        done
        payload="$payload}"
    fi
fi
payload="$payload}"

set -x
curl -sd "$payload" $url

# vim: set tw=80: