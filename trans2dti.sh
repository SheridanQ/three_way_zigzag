#!/bin/bash

# This script is used to transform tensor image calculated from DRTAMAS
wd="/home/xqi10/PythonProjects/FODDTI_base_study"

 if [ $# -lt 4 ];then
 	echo "Usage: `basename $0` inputdti trans target outdti"
 	exit 
 fi 
 
inputdti=${1}
trans=${2}
target=${3}
outdti=${4}


outdir=`dirname ${outdti}`
tmpdir=${outdir}/tmp_${RANDOM}_${RANDOM}_${RANDOM}_$$
(umask 077 && mkdir ${tmpdir}) || {
	echo "Could not create temporary directory! Exiting." 1>&2
	exit 1
}

antsdti=${tmpdir}/ants_dti.nii.gz
deformed_dti=${tmpdir}/ants_deformed_dti.nii.gz
reoriented_dti=${tmpdir}/ants_reoriented_dti.nii.gz

source activate clusterneuroimaging
python ${wd}/convert4D5DDTI.py -i ${inputdti} -o ${antsdti} -d 0 -convert 1
echo "Converting format"
antsApplyTransforms -d 3 -e 2 -i ${antsdti} -o ${deformed_dti} -t ${trans} -r ${target}
ReorientTensorImage 3 ${deformed_dti} ${reoriented_dti} ${trans}
python ${wd}/convert4D5DDTI.py -i ${reoriented_dti} -o ${outdti} -d 0 -convert 0
echo "Converting format back"
conda deactivate
rm -rf ${tmpdir}