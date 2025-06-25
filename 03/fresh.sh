#!/bin/bash

fresh() {
	local havent_permission=0
	local not_exist=0
	local folders
	case ${1} in
	1)
		folders=$(grep "создана папка:" ${LOG_CLEAN_PATH} | awk -F"создана папка: " '{print $2}' | tac)
		;;
	2)
		folders=$(find / -type d -newermt "@${START_CREATE}" -not -newermt "@${END_CREATE}" 2>/dev/null | grep -E "/[^/]*_[0-9]{6}$" | tac)
		;;
	3)
		folders=$(find / -type d -regex $(regular_mask) 2>/dev/null | tac)
		if [[ -z ${folders} ]]; then
			error "Папки по маске ${FOLDER_MASK} не существуют"
			retry "Некорректные параметры. Попробуйте еще раз!"
			exit 1
		fi
		;;
	esac

	for folder in ${folders}; do
		((FULL_COUNT++))

		if [[ -d ${folder} ]]; then
			if rm -rf ${folder} 2>/dev/null; then
				((FOLDERS++))
				report_folder_clean ${folder}
				progress_info
			else
				((havent_permission++))
				report_havent_permission_folder ${folder}
			fi
		else
			((not_exist++))
			report_not_exist_folder ${folder}
		fi
	done

	if [[ ${not_exist} -ne 0 ]]; then
		echo""
		error "WARNING! папок: ${not_exist} в общем запрошенном для удаления количестве: ${FULL_COUNT} не существует"
	fi
	if [[ ${havent_permission} -ne 0 ]]; then
		error "WARNING! У Вас нет прав на удаление ${havent_permission} папки"
		info "Пожалуйста, запустите скрипт ещё раз с sudo"
	fi
	#rm ${LOG_CLEAN_PATH}
}

regular_mask() {
	local regular
	local chars=$(echo ${FOLDER_MASK} | awk -F_ '{print $1}')
	local date=$(echo ${FOLDER_MASK} | awk -F_ '{print $2}')

	echo ".*/[${chars}]+_${date}$"
}
