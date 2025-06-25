#!/bin/bash

main() {

	readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	source ${DIR}/start_config.conf

	source ${DIR}/check_input.sh
	check_input $@ 1>&2
	if [[ $? -eq 1 ]]; then
		info "Некорректные параметры. Попробуйте еще раз!" 1>&2
		exit 1
	fi

	readonly path=$1
	readonly count_folders=$2
	readonly folder_name_letter=$3
	readonly count_files=$4
	file_name_letter=$5
	readonly file_letter=${file_name_letter%.*}
	readonly file_extension=${file_name_letter#*.}

	size_kb=$6
	file_size=$((${6::-2} * 1024))

	source ${DIR}/interface.sh
	parameters_info ${5} ${6}

	source ${DIR}/file_operations.sh
	generate_files_and_folders
	echo""

	output_info
}

main "$@"
