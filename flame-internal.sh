#!/bin/bash
echo 0 > /proc/sys/kernel/kptr_restrict

PORT_TO_USE=$((PORT + 1))

cd ./linux-$(uname -r | cut -d'.' -f1-3 | cut -d'-' -f1)/tools/perf
PORT=$PORT_TO_USE SILENT_START=true ./perf record -e cycles:u -g -- node --perf-basic-prof /usr/src/app/app.js &
sleep 1
curl "http://localhost:$PORT_TO_USE/api/tick"
curl "http://localhost:$PORT_TO_USE/api/end"
sleep 1

if [ ! -d FlameGraph ]
then
git clone https://github.com/brendangregg/FlameGraph 
fi

./perf script --header | egrep -v "( __libc_start| LazyCompile | v8::internal::| Builtin:| Stub:| LoadIC:|\[unknown\]| LoadPolymorphicIC:)" | sed 's/ LazyCompile:[*~]\?/ /' | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > flame1.svg
cp flame1.svg "/usr/src/app/out/flame-internal-$NODE_VERSION.svg"

# Stackvis -  another method to generate the flamegraph, but sometimes they look collapsed
# so i'll stick with brendangregg
# ./perf script | egrep -v "( __libc_start| LazyCompile | v8::internal::| Builtin:| Stub:| LoadIC:|\[unknown\]| LoadPolymorphicIC:)" | sed 's/ LazyCompile:[*~]\?/ /' > perfs.out
# stackvis perf < perfs.out > flamegraph.htm
# cp flamegraph.htm "/usr/src/app/out/flamegraph-$NODE_VERSION.htm"

