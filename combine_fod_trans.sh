#!/bin/bash

# This script convert fod transformation calculated by mrtrix to ants format.
# work with:
# ${wd}/make_dummy_header.sh
# ${wd}/def2disp_with_dummy.py

# Xiaoxiao Qi, Rakeen

wd="/home/xqi10/PythonProjects/three_way_zigzag"

if [ $# -lt 5 ];then
	echo "`basename ${0}` uid.list pre_transdir(None or folder) fod_source_dir fod_templatedir outtransdir"
	exit
fi 

uidlist=${1} #uid
pre_transdir=${2} #uid_*transcomb.nii.gz
fod_source_dir=${3} 
fod_template_dir=${4} #template, outwarp, outwarped
outtransdir=${5} #uid_fod_transcomb.nii.gz

jobdir="${wd}/tmpjobs/jobdir_fod_combo"
if [ -d ${jobdir} ]; then
 rm -rf ${jobdir}
 mkdir -p ${jobdir}
else
 mkdir -p ${jobdir}
fi

count=0
joblist="${jobdir}/joblist.txt"

mkdir -p ${fod_template_dir}/ants_fod_warps
fod_template="${fod_template_dir}/build_fod_template.nii.gz"

for uid in `cat ${uidlist}`
do
	fod_source="${fod_source_dir}/${uid}*.mif"
	fod_warp="${fod_template_dir}/out_warps/${uid}.mif"
	outdp="${fod_template_dir}/ants_fod_warps/${uid}.nii.gz"

	cmd1="bash ${wd}/convert_miftrans2ants.sh ${fod_source} ${fod_warp} ${fod_template} ${outdp}"

	outtrans="${outtransdir}/${uid}_fod_transcomb.nii.gz"

	if [ ${pre_transdir} = "None" ];then
		# cmd
		cmd2="cp ${outdp} ${outtrans}"
	else
		pre_trans="${pre_transdir}/${uid}_*_transcomb.nii.gz"
		cmd2="antsApplyTransforms -d 3 --float 1 -r ${fod_template} -o [${outtrans},1] -t ${outdp} -t ${pre_trans}"
	fi

	# job
	jobname="combfod_${count}"
	jobscript="${jobdir}/job_${jobname}_qsub.sh"
	
	echo "#!/bin/bash" >${jobscript}
	echo ${cmd1} >> ${jobscript}
	echo ${cmd2} >> ${jobscript}
	echo ${jobname}>>${joblist}

	let count=count+1
done


submit_jobs_v9_wait ${joblist} 24:00:00 8G 1 ${jobdir} ${count}
