#!/bin/bash

main() {
	readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	source ${DIR}/start_config.conf

	source ${DIR}/check_input.sh
	check_input $@ 1>&2
	if [[ $? -eq 1 ]]; then
		retry "Некорректные параметры. Попробуйте еще раз!" 1>&2
		exit 1
	fi

	source ${DIR}/interface.sh
	parameters_info ${1}

	source ${DIR}/fresh.sh
	fresh ${1}

	output_info
}

main "$@"
