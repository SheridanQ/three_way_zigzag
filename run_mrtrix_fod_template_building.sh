#!/bin/bash

# WHERE
scriptdir="/share/apps/mrtrix334/bin/"

wd="/home/xqi10/PythonProjects/three_way_zigzag"

if [ $# -lt 2 ];then
	echo "Usage: `basename $0` foddir maskdir outdir"
	exit
fi

foddir=${1}
maskdir=${2}
outdir=${3}

nthreads=24
maskdir="-mask_dir ${maskdir}"
outwarp="-warp_dir ${outdir}/out_warps"
outwarped="-transformed_dir ${outdir}/out_warped"
outlntrans="-linear_transformations_dir ${outdir}/out_lntrans"
output="${outdir}/build_fod_template.mif"
outputmask="-template_mask ${outdir}/build_fod_template_mask.mif"
tempdir="-tempdir ${outdir}/tmp"
mkdir -p ${outdir}/tmp

cmd="${scriptdir}/population_template ${foddir} ${output} -voxel_size 1 ${maskdir} ${outwarp} ${outwarped} ${outlntrans} ${outputmask} ${tempdir} -force -nthreads ${nthreads} -nocleanup -linear_no_pause"
echo ${cmd} > ${outdir}/job_build_fod_qsub.sh
echo "build_fod" > ${outdir}/joblist.txt
echo " ">>${outdir}/joblist.txt

submit_jobs_v9 ${outdir}/joblist.txt 120:00:00 60G ${nthreads} ${outdir} 1