#!/bin/bash

generate_files_and_folders() {
	check_space

	if [[ ${OVERLY} -eq 0 ]]; then
		source ${DIR}/name_operations.sh
		local depth=1
		create_one_depth ${path}

		while [[ ${FOLDERS} -lt ${count_folders} ]] && [[ ${OVERLY} -eq 0 ]]; do
			create_depth ${depth}
			((depth++))
		done
	fi
}

create_depth() {
	local -r depth=$1

	for folder in $(find ${path} -mindepth ${depth} -maxdepth ${depth} -type d); do
		if [[ ${FOLDERS} -ge ${count_folders} ]] || [[ ${OVERLY} -eq 1 ]]; then
			break
		elif [[ ${folder##*/} =~ ^[a-zA-Z]*_[0-9]{6}$ ]]; then
			create_one_depth ${folder}
		fi
	done
}

create_one_depth() {
	local folder_in_depth_dir=$1
	local count_folders_num=$((RANDOM % (10 - 5) + 5))
	local folder_name

	for ((i = 0; i < count_folders_num; i++)); do
		folder_name=$(folder_label ${folder_in_depth_dir})
		while [[ -d "${folder_in_depth_dir}/${folder_name}" ]]; do
			folder_name=$(folder_label ${folder_in_depth_dir})
		done

		if mkdir "${folder_in_depth_dir}/${folder_name}"; then
			((FOLDERS++))
			log_folder_create
			create_files_in_folder ${folder_in_depth_dir}/${folder_name}
		fi

		if [[ ${FOLDERS} -ge ${count_folders} ]] || [[ ${OVERLY} -eq 1 ]]; then
			progress_info
			break
		fi
	done
}

create_files_in_folder() {
	local folder_in_depth_dir="$1"

	for ((j = 0; j < count_files; j++)); do
		file_name=$(file_label ${folder_in_depth_dir})
		while [[ -e "${folder_in_depth_dir}/${file_name}" ]]; do
			file_name=$(file_label ${folder_in_depth_dir})
		done

		check_space
		if [[ ${OVERLY} -eq 1 ]]; then
			break
		fi

		if fallocate -l ${file_size^} ${folder_in_depth_dir}/${file_name} 2>/dev/null; then
			((FILES++))
			log_file_create
			progress_info
		fi
	done
}

check_space() {
	#local -r space=$(df / | grep /$ | awk '{print $4}')
	local -r space=$(df / | awk 'NR==2 {print $4}')

	if [[ ${space} -le 1048576 ]]; then
		OVERLY=1
	else
		OVERLY=0
	fi
}
