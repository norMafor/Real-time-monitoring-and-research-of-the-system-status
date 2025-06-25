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

	readonly folder_name_letter=${1}
	readonly file_name_letter=${2}
	readonly size_mb=${3}
	file_size=$((${3::-2} * 1048576))

	source ${DIR}/interface.sh
	parameters_info ${2} ${3}

	source ${DIR}/file_operations.sh
	generate_files_and_folders
	echo""

	output_info
}

main "$@"
