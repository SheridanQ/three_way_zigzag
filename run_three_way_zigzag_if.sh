#!/bin/bash

# data parameters: t1w, dti, fod (in the same working folder)

# control parameters: zigzag_prefix ("template_" (default))

# run_ants_t1w_template_building.sh ./t1w ./template_t1w_0 # prefix: build (by default)
# apply_t1w_trans_to_DTI.sh

sd="/home/xqi10/PythonProjects/three_way_zigzag"

t1w_apply_cmd="${sd}/apply_trans2t1w.sh"
t1w_build_cmd="${sd}/run_ants_t1w_template_building.sh" # basename $0 t1w outt1wdir
t1w_combo_cmd="${sd}/combine_t1w_trans.sh" # $0 t1w_transdir dti outdti

dti_apply_cmd="${sd}/apply_trans2dti.sh"
dti_build_cmd="${sd}/run_drtamas_dti_template_building.sh"
dti_combo_cmd="${sd}/combine_dti_trans.sh"

fod_apply_cmd="${sd}/apply_trans2fod.sh"
fod_build_cmd="${sd}/run_mrtrix_fod_template_building.sh"
fod_combo_cmd="${sd}/combine_fod_trans.sh"

mask_apply_cmd="${sd}/apply_trans2mask.sh"

workdir=${1}

uidlist="${workdir}/uid.list"
t1w="${workdir}/t1w"
dti="${workdir}/dti"
fod="${workdir}/fod"
mask="${workdir}/mask"

zz_pre="template_"
zz_cnt=1 # zigzag count, must start from zero 
zz_iter=${2} # how many zigzags, can be parameter

filenum=$(wc -l < "$uidlist")
echo "There are ${filenum} subjects to build the templates."
# internal count: 0: t1w; 1: dti; 2: fod.
#zcnt=2 # constance

# zigzag iterations
while [ ${zz_cnt} -lt ${zz_iter} ]
do

	# T1w stage
	zcnt=0
	start_0="${workdir}/start_t1w_${zz_cnt}${zcnt}"
	template_0="${workdir}/${zz_pre}t1w_${zz_cnt}${zcnt}"
	combine_0="${workdir}/combinedtrans_t1w_${zz_cnt}${zcnt}"
	mkdir -p ${template_0}
	mkdir -p ${combine_0}
	## DTI stage
	let zcnt=zcnt+1

	start_1="${workdir}/start_dti_${zz_cnt}${zcnt}"
	template_1="${workdir}/${zz_pre}dti_${zz_cnt}${zcnt}"
	combine_1="${workdir}/combinedtrans_dti_${zz_cnt}${zcnt}"

	mkdir -p ${start_1}
	mkdir -p ${template_1}
	mkdir -p ${combine_1}
	## FOD stage
	let zcnt=zcnt+1

	start_2="${workdir}/start_fod_${zz_cnt}${zcnt}"
	template_2="${workdir}/${zz_pre}fod_${zz_cnt}${zcnt}"
	combine_2="${workdir}/combinedtrans_fod_${zz_cnt}${zcnt}"

	start_mask_2="${workdir}/start_mask_${zz_cnt}${zcnt}"

	mkdir -p ${start_2}
	mkdir -p ${template_2}
	mkdir -p ${combinedtrans_2}
	mkdir -p ${start_mask_2}

	### start###
	# T1w stage
	if [ ${zz_cnt} -eq 0 ];then
		start_0=${t1w}
		bash ${t1w_build_cmd} ${start_0} ${template_0} # t1w, template_t1w_0
		bash ${t1w_combo_cmd} ${uidlist} None ${template_0} ${combine_0}
	elif [ ${zz_cnt} -gt 0 ];then
		if [ ! -f ${template_0}/buildtemplate.nii.gz ];then
			bash ${t1w_build_cmd} ${start_0} ${template_0}
		fi
		
		check_count=`ls -1 ${combine_0}/*t1w_transcomb.nii.gz 2>/dev/null | wc -l`
		if [ ${check_count} != ${filenum} ];then
			echo "The t1w transcomb files: ${check_count}, regenerating files......"
			let pre_zz_cnt=zz_cnt-1
			pre_zcnt=2
			pre_combine_2="${workdir}/combinedtrans_fod_${pre_zz_cnt}${pre_zcnt}"
			bash ${t1w_combo_cmd} ${uidlist} ${pre_combine_2} ${template_0} ${combine_0}
		fi
	fi
	# DTI stage
	check_count=`ls -1 ${start_1}/*dti_deformed.nii 2>/dev/null | wc -l`
	if [ ${check_count} != ${filenum} ];then
		echo "The dti_deformed files: ${check_count}, regenerating files......"
		bash ${dti_apply_cmd} ${uidlist} ${dti} ${combine_0} ${start_1} ${template_0}/buildtemplate.nii.gz
	fi
	
	if [ ! -f ${template_1}/average_template_diffeo_6.nii ];then
		echo "DTI template not built, building DTI template......"
		bash ${dti_build_cmd} ${start_1} ${template_1}
	fi
	
	check_count=`ls -1 ${combine_1}/*dti_transcomb.nii.gz 2>/dev/null | wc -l`
	if [ ${check_count} != ${filenum} ];then
		echo "The dti_transcomb files: ${check_count}, regenerating files......"
		bash ${dti_combo_cmd} ${uidlist} ${combine_0} ${template_1} ${combine_1}
	fi

	# FOD stage
	check_count=`ls -1 ${start_2}/*fod_deformed.mif 2>/dev/null | wc -l`
	if [ ${check_count} != ${filenum} ];then
		echo "The fod_deformed files: ${check_count}, regenerating files......"
		bash ${fod_apply_cmd} ${uidlist} ${fod} ${combine_1} ${start_2} ${template_1}/average_template_diffeo_6.nii
	fi

	check_count=`ls -1 ${start_mask_2}/*mask_deformed.nii.gz 2>/dev/null | wc -l`
	if [ ${check_count} != ${filenum} ];then
		echo "The mask_deformed files: ${check_count}, regenerating files......"
		bash ${mask_apply_cmd} ${uidlist} ${mask} ${combine_1} ${start_mask_2} ${template_1}/average_template_diffeo_6.nii
	fi

	if [ ! -f ${template_2}/build_fod_template.mif ];then
		echo "FOD template not built, building FOD template......"
		bash ${fod_build_cmd} ${start_2} ${start_mask_2} ${template_2}
	fi
	mrconvert ${template_2}/build_fod_template.mif ${template_2}/build_fod_template.nii.gz -force
	
	check_count=`ls -1 ${combine_2}/*fod_transcomb.nii.gz 2>/dev/null | wc -l`
	if [ ${check_count} != ${filenum} ];then
		echo "The fod_transcomb files: ${check_count}, regenerating files......"
		bash ${fod_combo_cmd} ${uidlist} ${combine_1} ${start_2} ${template_2} ${combine_2}
	fi

	let zz_cnt=zz_cnt+1
	zcnt=0
	start_0="${workdir}/start_t1w_${zz_cnt}${zcnt}"
	mkdir -p ${start_0}

	check_count=`ls -1 ${start_0}/*t1w_deformed.nii.gz 2>/dev/null | wc -l`
	if [ ${check_count} != ${filenum} ];then
		echo "The t1w_deformed files: ${check_count}, regenerating files......"
		bash ${t1w_apply_cmd} ${uidlist} ${t1w} ${combine_2} ${start_0} ${template_2}/build_fod_template.nii.gz
	fi
done