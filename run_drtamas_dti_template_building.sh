#!/bin/bash

# WHERE
scriptdir="/home/xqi10/PythonProjects/three_way_zigzag"
buildcmd="${scriptdir}/dtireg_create_template_PBS"

wd="/home/xqi10/PythonProjects/three_way_zigzag"

if [ $# -lt 2 ];then
	echo "Usage: `basename $0` dtidir outdir"
	exit
fi

dtidir=${1}
outdir=${2}

start_step=0 ### Do only the diffeomorphic registration, not in testing though.
njobs=23

ls ${dtidir}/* > ${outdir}/subjectslist.txt
bash ${buildcmd} -s=${outdir}/subjectslist.txt -ss=${start_step} -n=${njobs} -o=${outdir}



