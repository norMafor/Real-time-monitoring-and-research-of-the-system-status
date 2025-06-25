#!/bin/bash

main() {
	readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	config_file="${DIR}/start_config.conf"
	[[ -f "${config_file}" ]] || {
		echo "Config file missing!"
		exit 1
	}
	source "${config_file}"

	if [[ $# -ne 0 ]]; then
		info "Скрипт должен запускаться без параметров." 1>&2
		retry "Некорректные параметры. Попробуйте еще раз!" 1>&2
		exit 1
	fi

	source ${DIR}/interface.sh
	parameters_info ${1}

	source ${DIR}/logs_generator.sh

	output_info
}

main "$@"
