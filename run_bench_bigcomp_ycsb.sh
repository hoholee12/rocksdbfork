#!/bin/bash

mkdir results 2>/dev/null

echo "$3" on "$2"
echo dataset $((1024*$1))
dataset=$((1024*$1))

sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"

if [[ $3 == "seekrandom" ]]; then
	dataset=$(($dataset/50))
fi

if [[ $4 == "bloom" ]]; then
	bloom="-bloom_bits=10"
fi

shard=$5
if [[ $5 == "" ]]; then
	shard=1
fi

#run
sudo time ./db_bench \
 -benchmarks="$3,stats" \
 -num=$dataset \
 -threads=8 \
 -histogram \
 -statistics \
 -report_ops_latency=true \
 -key_size=16 \
 -value_size=1008 \
 -use_existing_db=true \
 -db=/home/jeongho/mnt \
 -use_direct_io_for_flush_and_compaction=true \
 -use_direct_reads=true \
 -cache_size=$((1024*1024*1024*2)) \
 -cache_numshardbits=$shard \
 $bloom \
 &> results/"$3"_on_"$2".txt \
 
 cp latency.csv results/"$3"_on_"$2"_latency.csv
 
echo after run...
df -T | grep mnt

#-bloom_bits=10 \