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
    echo -e "$(cat <<EOF
\033[1mUSAGE\033[0m
    $me [host:]port method [name:value ...]

\033[1mEXAMPLES\033[0m
    $me 28081 get_version
    $me node.xmr.to:18081 get_version
    $me 28081 get_block height:123456
    $me 28081 get_block hash:aaaac8fe6bd05f32aa68b9bd13d66d2056335a1a4a88c788f7a07ab8a1e64912
    $me 28084 get_transfers in:true
    $me 28084 get_address account_index:0 address_index:[0,1]

\033[1mSEARCHING\033[0m
    If you have the Monero source tree and set an enviroment variable
    MONERO_ROOT to its path, you can then use the \`doc\` command to search
    methods and get the expected parameters from the code. For example:

    $me doc transfer
    $me doc ".*bulk.*pay"
    $me doc ".*pay"
    $me doc ".*"
EOF
)"
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

if [[ "$1" == "doc" ]]; then
    [ -z "$MONERO_ROOT" ] \
        && echo "Environment variable MONERO_ROOT needs setting for the doc command!" \
        && exit -2
    m=$(echo -n "$2" | tr a-z A-Z)
    cat "$MONERO_ROOT/src/rpc/core_rpc_server_commands_defs.h" \
        "$MONERO_ROOT/src/wallet/wallet_rpc_server_commands_defs.h" \
        | sed -n '/COMMAND_RPC_'${m}'/,/};/p' | sed -E 's/};/};\
  }/g'
    exit
fi

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
