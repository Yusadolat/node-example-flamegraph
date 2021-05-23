#!/bin/bash
echo 0 > /proc/sys/kernel/kptr_restrict
cd ./linux-$(uname -r | cut -d'.' -f1-3 | cut -d'-' -f1)/tools/perf
./perf record -F99 -p "$(pgrep -n node)" -g -- sleep 30

if [ ! -d FlameGraph ]
then
git clone https://github.com/brendangregg/FlameGraph 
fi

./perf script --header | egrep -v "( __libc_start| LazyCompile | v8::internal::| Builtin:| Stub:| LoadIC:|\[unknown\]| LoadPolymorphicIC:)" | sed 's/ LazyCompile:[*~]\?/ /' | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > flame1.svg
cp flame1.svg "/usr/src/app/out/flame-external-$NODE_VERSION.svg"

# ./perf script | egrep -v "( __libc_start| LazyCompile | v8::internal::| Builtin:| Stub:| LoadIC:|\[unknown\]| LoadPolymorphicIC:)" | sed 's/ LazyCompile:[*~]\?/ /' > perfs.out
# stackvis perf < perfs.out > flamegraph.htm
# cp flamegraph.htm /usr/src/app/out/
# cp flamegraph.htm "/usr/src/app/out/flamegraph-$NODE_VERSION.htm"
