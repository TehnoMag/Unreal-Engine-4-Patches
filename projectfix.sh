#!/bin/bash

#Place Full Path to Engine Directory
ENGINE_PATH="E\:\\\Unreal Engine 4\\\Engine\\\Engine"
#Place you project name
PROJECT="MyProject"
#Place you project module names with space as delimeter
MODULES="Module1 Module2"

echo $PROJECT
echo $ENGINE_PATH

#STEP1 Fixing Includes Search paths for generated files (Engine Issue)

PRJFILE="Intermediate/ProjectFiles/${PROJECT}.vcxproj"

for module in `echo $MODULES`;
do
	sed -i "s/${PROJECT}Editor\\\Inc\\\\${module}/UE4Editor\\\Inc\\\\${module}/g" ${PRJFILE}
done

sed -i "s/\.\.\\\Build\\\Win64\\\\${PROJECT}Editor/${ENGINE_PATH}\\\Intermediate\\\Build\\\Win64\\\UE4Editor/g" ${PRJFILE}
sed -i "s/\\\\${PROJECT}Editor\\\/\\\UE4Editor\\\/g" ${PRJFILE}

#STEP2 Fixing encoding page to UTF-8 (Git issue)

for file in $(find {Source,Config}/ -type f);
do
	encoding=$(file -i $file | awk -F= '{print $NF}')

	if [[ "$encoding" != "utf-8" ]];
	then
		echo "Fixing $file"
		mv $file $file.tmp
		iconv -f $encoding -t utf-8 $file.tmp > $file 
		rm $file.tmp
	fi
done
