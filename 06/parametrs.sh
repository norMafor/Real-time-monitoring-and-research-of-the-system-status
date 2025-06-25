#!/bin/bash

segregation() {
	#local log_path=$(cd ${DIR} && cd ./../04 && pwd)
	local log_path=$(cd ./../04 && pwd)
	local logs=$(ls ${log_path}/*.log)
	local count=0
	local flags

	mkdir -p ${DIR}/reports

	case ${1} in
	1) flags="--sort-panel=STATUS_CODES,BY_DATA,ASC" ;;
	2) flags="--sort-panel=HOSTS,BY_DATA,ASC" ;;
	3) flags="--ignore-status=200 --ignore-status=201" ;;
	4) flags="--ignore-status=200 --ignore-status=201 --sort-panel=HOSTS,BY_DATA,ASC" ;;
	*)
		exit 1
		;;
	esac

	for log in ${logs}; do
		local html_name="${DIR}/reports/${1}_log_access_$((count + 1)).html"

		goaccess -f ${log} --log-format=COMBINED ${flags} -o ${html_name} >/dev/null 2>&1

		((count++))
		progress_info ${count}
	done

}
