#!/bin/bash

wd="/home/xqi10/PythonProjects/three_way_zigzag"

if [ $# -lt 5 ];then
	echo "Usage: `basename $0` uid.list original_fod_folder transformation_folder out_folder target_template"
	exit
fi

uidlist=${1} #uid.list
foddir=${2}
transdir=${3}
deformeddir=${4}
target=${5}


jobdir="${wd}/tmpjobs/jobdir_fod_apply"
if [ -d ${jobdir} ]; then
 rm -rf ${jobdir}
 mkdir -p ${jobdir}
else
 mkdir -p ${jobdir}
fi

count=0
joblist="${jobdir}/job.list"

for uid in `cat ${uidlist}`
do
	fod="${foddir}/${uid}_fod.mif"
	trans="${transdir}/${uid}_*_transcomb.nii.gz"
	deformed="${deformeddir}/${uid}_fod_deformed.mif"

	cmd="bash ${wd}/trans2fod.sh ${fod} ${trans} ${target} ${deformed}"

	jobname="applyfod_${count}"
	jobscript="${jobdir}/job_${jobname}_qsub.sh"
	

	echo "!/bin/bash" >${jobscript}
	echo "${cmd}" >> ${jobscript}
	echo "${jobname}" >> ${joblist}

	let count=count+1
done

submit_jobs_v9_wait ${joblist} 24:00:00 8G 1 ${jobdir} ${count}


