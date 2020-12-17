#!/bin/bash
lg=$1
mapref="saturate/cs_rp3b.window_patterns.map"
patternbase="windowpatterns/cs_rp4.window_patterns.99.lg."
cat $mapref \
| awk -v L="$lg" '$1==L {print $1"\t"$4"\t"$5}' \
| sed -e "s/,//g" \
>"$mapref"".LG.""$lg"

cat "$patternbase""$lg" \
| awk '{print $1"\t"$3"\t"$4"\t"$2":"$5}' \
>"$patternbase""$lg"".fmt"

./antmap-partion_by_LG.pl "$mapref"".LG.""$lg" "$patternbase""$lg"".fmt" \
>"$patternbase""$lg"".placed"



