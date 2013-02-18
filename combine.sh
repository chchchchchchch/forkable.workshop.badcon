#!/bin/bash

  KOMBIDIR=o
  INPUTDIR=i

# ----------------------------------------------------------------------- #
# CONVERT LAYERS FROM ALL SVG TO LINES (FOR GREP) IN ONE SVG 
# AND ADD A TEMPORARY ID (TO DIFFERENTIATE SVG SOURCES)

  for SVG in `ls $INPUTDIR/*.svg`
   do
      UNIFY=`echo $SVG | md5sum | sed 's/[a-z]//g' | cut -c 1-4`

      COLOR=`echo a\`echo $SVG | \
             md5sum | \
             sed 's/[^a-fA-F0-9]*//g' | \
             cut -c 1-4\`ff0000 | cut -c 1-6 `

  sed 's/ / \n/g' $SVG | \
  sed '/^.$/d' | \
  sed -n '/<\/metadata>/,/<\/svg>/p' | sed '1d;$d' | \
  sed ':a;N;$!ba;s/\n/ /g' | \
  sed 's/<\/g>/\n<\/g>/g' | \
  sed 's/\(<g.*inkscape:groupmode="layer"[^>]*>\)/QWERTZUIOP\1/g' | \
  sed ':a;N;$!ba;s/\n/ /g' | \
  sed 's/QWERTZUIOP/\n\n\n\n/g' | \
  sed "s/typus=\"/typus=\"$UNIFY/g" | \
  sed 's/ff2ad4/TGBNHZUJMKIL/g' | \
  sed 's/ffffff/QAYXSWEDCVFR/g' | \
  sed "s/fill:[#]\{0,1\}[a-fA-F0-9]\{6\}/fill:#$COLOR/g" | \
  sed "s/stroke:[#]\{0,1\}[a-fA-F0-9]\{6\}/stroke:#$COLOR/g" | \
  sed "s/color:[#]\{0,1\}[a-fA-F0-9]\{6\}/color:#$COLOR/g" | \
  sed 's/display:none/display:inline/g'  >> all.tmp 

 done

# ----------------------------------------------------------------------- #
# CHANGE SVG VARIABLE TO THE NEW ALL-IN-ONE SVG

  SVG=all.svg

# ----------------------------------------------------------------------- #
# MAKE A LIST WITH ALL DIFFERENT TYPUS

  LIST=${SVG%%.*}.list 
  sed 's/ / \n/g' ${SVG%%.*}.tmp  | \
  grep typus=\" | \
  cut -d "\"" -f 2                        > $LIST 

# ----------------------------------------------------------------------- #
# MAKE A COMBINATORY SVG FROM ->
# ROOT LAYERS (= typus="XXXX00")
# AND OPTIONAL BRANCHES (= typus="XXXX00-YYYY00")

  NEWSVG=combined.svg
  SVGHEADER=`tac \`ls $INPUTDIR/*.svg | head -1 \` | \
             sed -n '/<\/metadata>/,$p' | tac`

  echo "$SVGHEADER"                                 >  $NEWSVG 

 for TYPUS in `cat $LIST | \
               cut -d "-" -f 1 | \
               rev | cut -c 3- | rev | \
               cut -c 5- | \
               sort | uniq`
  do
     echo $TYPUS

     TYPUS=`cat $LIST | cut -d "-" -f 1 | \
            sort | uniq | \
            grep "^[0-9]\{4\}${TYPUS}..$" | \
            shuf -n 1`

     grep -n typus=\"$TYPUS\" ${SVG%%.*}.tmp | \
     shuf -n 1                                      >> ${NEWSVG}.tmp

     while [ `echo $TYPUS | wc -c` -gt 1 ]
      do     
              echo $TYPUS
        if [ `echo $TYPUS | wc -c` -gt 1 ]; then
           TYPUS=`grep "^$TYPUS-[a-zA-Z]\{0,100\}[0-9][0-9]$" $LIST | \
                  shuf -n 1`
           grep -n typus=\"$TYPUS\" ${SVG%%.*}.tmp | \
           shuf -n 1                                >> ${NEWSVG}.tmp
        fi
     done


  done

  sort -n ${NEWSVG}.tmp | cut -d ":" -f 2-          >> $NEWSVG
  echo "</svg>"                                     >> $NEWSVG

  rm ${NEWSVG}.tmp

# ----------------------------------------------------------------------- #
# CREATE A UNIQUE FILENAME BASED ON LAYER TYPEN

  SVGID=`sed 's/ / \n/g' $NEWSVG  | \
         grep typus=\" | \
         cut -d "\"" -f 2 | \
         md5sum | cut -d " " -f 1 | 
         sed 's/\(.\)/\1\n/g' | \
         sed '/^$/d' | sed 'n;d;' | \
         sed ':a;N;$!ba;s/\n//g'`

# ----------------------------------------------------------------------- #
# REMOVE TEMPORARY SVG UNIFY ID AND SAVE ANNOTATED SVG

  sed -i 's/typus=\"[0-9]\{4\}/typus=\"/g' $NEWSVG
  ANNOTATED=$KOMBIDIR/${SVGID}_ANNOTATED.svg
  cp $NEWSVG $ANNOTATED

# ----------------------------------------------------------------------- #
# (RE-)MODFIY COLORS

  sed -i "s/fill:[#]\{0,1\}[a-fA-F0-9]\{6\}/fill:#000000/g" $NEWSVG
  sed -i "s/stroke:[#]\{0,1\}[a-fA-F0-9]\{6\}/stroke:#000000/g" $NEWSVG
  sed -i "s/color:[#]\{0,1\}[a-fA-F0-9]\{6\}/color:#000000/g" $NEWSVG

  sed -i 's/QAYXSWEDCVFR/ffffff/g' $NEWSVG $ANNOTATED
  sed -i 's/TGBNHZUJMKIL/ff2ad4/g' $NEWSVG $ANNOTATED

# ----------------------------------------------------------------------- #
# FILTER ANNOTATIONS

  sed 's/>/>\n/g' $NEWSVG | sed 's/\(<.*ff2ad4.*[^>]*>\)//g' | \
  sed ':a;N;$!ba;s/\n//g' \
  > $KOMBIDIR/${SVGID}.svg

# ----------------------------------------------------------------------- #
# MAKE ANNOTATIONS BLACK

  sed -i 's/ff2ad4/000000/g' $ANNOTATED

# ----------------------------------------------------------------------- #
# CLEAN UP

  rm $LIST ${SVG%%.*}.tmp $NEWSVG



exit 0;