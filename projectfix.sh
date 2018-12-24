#!/bin/bash

#Place Full Path to Engine Directory
ENGINE_PATH="E\:\\\Unreal Engine 4\\\Engine\\\Engine"
#Place you project name
PROJECT="MyProject"
#Place you project module names with space as delimeter
MODULES="Module1 Module 2"
PLATFORMS="Win64 Win32 Linux"

echo $PROJECT
echo $ENGINE_PATH

#for Linux host found platform ID in Intermeidate directory
PLATFORM_ID=$(ls Intermediate/Build/Linux/ | grep -v Editor)
echo $PLATFORM_ID

#STEP1 Fixing Includes Search paths for generated files (Engine Issue)

PRJFILE="Intermediate/ProjectFiles/${PROJECT}.vcxproj"
QTCFILE="${PROJECT}Includes.pri"

for module in `echo $MODULES`;
do
	echo "Fixing Path for module ${module}"
	sed -i "s/${PROJECT}Editor\\\Inc\\\\${module}/UE4Editor\\\Inc\\\\${module}/g" ${PRJFILE} 2>/dev/null
	sed -i "s/${PROJECT}Editor\/Inc\/${module}/UE4Editor\/Inc\/${module}/g" ${QTCFILE} 2>/dev/null
done

for platform in `echo $PLATFORMS`;
do
	[ "$(uname)" == "Linux" ] && plat_id="\/${PLATFORM_ID}\/" || plat_id=""

	echo "Fixing Path for platoform ${platform}"
	sed -i "s/\.\.\\\Build\\\\${platform}\\\\${PROJECT}Editor/${ENGINE_PATH}\\\Intermediate\\\Build\\\\${platform}\\\UE4Editor/g ${PRJFILE}" 2>/dev/null
	sed -i "s/Intermediate\/Build\/${platform}${plat_id}${PROJECT}Editor/${ENGINE_PATH}\/Intermediate\/Build\/${platform}${plat_id}UE4Editor" ${QTCFILE} 2>/dev/null
done


sed -i "s/\\\\${PROJECT}Editor\\\/\\\UE4Editor\\\/g" ${PRJFILE} 2>/dev/null
sed -i "s/\/${PROJECT}Editor\//\/UE4Editor\//g" ${QTCFILE} 2>/dev/null

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
