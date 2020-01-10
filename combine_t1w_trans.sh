#!/bin/bash

# WHERE
#toolbox="/home/xqi10/PythonProjects/FODDTI_base_study"
#toolcmd="${toolbox}/apply_dtitrans2dti.sh"

wd="/home/xqi10/PythonProjects/three_way_zigzag"

if [ $# -lt 4 ];then
	echo "Usage: `basename $0` uid.list pre_transdir(None or folder) t1w_transdir outtransdir"
	exit
fi

uidlist=${1} #uid
pre_transdir=${2} #uid_*transcomb.nii.gz
t1w_transdir=${3} #*uid*Affine.txt *uid*Warp.nii.gz
outtransdir=${4} #uid_t1w_transcomb.nii.gz


jobdir="${wd}/tmpjobs/jobdir_t1w_combo"
if [ -d ${jobdir} ]; then
 rm -rf ${jobdir}
 mkdir -p ${jobdir}
else
 mkdir -p ${jobdir}
fi

count=0
joblist="${jobdir}/joblist.txt"
for uid in `cat ${uidlist}`
do
	# inputs
	t1w_transln="${t1w_transdir}/*${uid}*Affine.txt"
	t1w_transnl="${t1w_transdir}/*${uid}*Warp.nii.gz"
	t1w_target="${t1w_transdir}/buildtemplate.nii.gz"
	
	# outputs
	outtrans="${outtransdir}/${uid}_t1w_transcomb.nii.gz"

	if [ ${pre_transdir} = "None" ];then
		# cmd
		cmd="antsApplyTransforms -d 3 --float 1 -r ${t1w_target} -o [${outtrans},1] -t ${t1w_transnl} -t ${t1w_transln}"
	else
		pre_trans="${pre_transdir}/${uid}_*_transcomb.nii.gz"
		cmd="antsApplyTransforms -d 3 --float 1 -r ${t1w_target} -o [${outtrans},1] -t ${t1w_transnl} -t ${t1w_transln} -t ${pre_trans}"
	fi

	# job
	jobname="combt1w_${count}"
	jobscript="${jobdir}/job_${jobname}_qsub.sh"

	echo "#!/bin/bash" >${jobscript}
	echo ${cmd} >> ${jobscript}
	echo ${jobname}>>${joblist}

	let count=count+1
done


submit_jobs_v9_wait ${joblist} 24:00:00 8G 1 ${jobdir} ${count}







