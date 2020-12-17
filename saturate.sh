#!/bin/bash

for lg in $(seq 1 10 | tr ' ' '\n')
do
    map_prefix="saturate/cs_rp3b.window_patterns.map.LG."
    test_prefix="windowpatterns/cs_rp4.window_patterns.99.lg."
    paste <(cat "$map_prefix""$lg" ) <(cat "$map_prefix""$lg" | tail -n +2 ) | awk '($5-$2) > 0.56 {print $2"\t"$3"\t"$5"\t"$6}' >"$map_prefix""$lg"".unsaturated"
    
    touch "$map_prefix""$lg"".newpatterns"
    rm "$map_prefix""$lg"".newpatterns"
    while read line
    do
    
        pattern1=$(echo $line | awk '{print $2}')
        pattern2=$(echo $line | awk '{print $4}')
        p=$(echo $line | awk '{print $1}')
        q=$(echo $line | awk '{print $3}')
        cat "$test_prefix""$lg"".placed" | tr ',' '\t' | tr ';' '\t' | awk -v P="$p" -v Q="$q" '$5==P || $5==Q' | awk '$7<5' | awk '{print $2":"$3"-"$13}' | grep -v "n" \
        | ./find_path_between_patterns.pl "$p""-""$pattern1" "$q""-""$pattern2" \
        | tr '-' '\t' \
        | awk -v L="$lg" '{print L"\t"$1"\t"$2}' \
        >>"$map_prefix""$lg"".newpatterns"
    
    done<"$map_prefix""$lg"".unsaturated"
    
    rm "$map_prefix""$lg"".unsaturated"

done
