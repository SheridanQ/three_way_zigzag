#!/bin/bash

#run_ants_t1w_template_building.sh ./t1w ./template_t1w_0 # prefix: build (default)

# WHERE
#scriptdir="/home/xqi10/PythonProjects/three_way_zigzag"

buildcmd="${ANTSPATH}/buildtemplateparallel.sh"

# API
inputdir=${1}
echo $inputdir

outputdir=${2}
if [ -d ${outputdir} ];then
	rm -rf ${outputdir}
	mkdir -p ${outputdir}
else
	mkdir -p ${outputdir}
fi

# PRIVATE PARAMETERS
dim="-d 3"
prefix="-o build"
para="-c 4"
queue="-q high"
gradient="-g 0.25"
iteration="-i 6"
#cores="-j 2"
max="-m 30x90x30"
transformation="-t GR"
similarity="-s CC"
#nfour="-n 1"
#initial="-z ${scriptdir}/ICBM152.nii.gz"

cmd0="ln -s ${inputdir}/*.nii.gz ${outputdir}"
cmd1="cd ${outputdir}"
cmd2="${buildcmd} ${dim} ${prefix} ${para} ${queue} ${gradient} ${iteration} ${max} ${transformation} ${similarity} *.nii.gz"


$cmd0
$cmd1

$cmd2


