#!/bin/bash

parameters_info() {

	info "ВЫ ВЫБРАЛИ:"

	case ${1} in
	1)
		info_sub "Метод очистки по log-файлу"
		param "Путь к log-файлу: ${LOG_CLEAN_PATH}"
		;;
	2)
		info_sub "Метод очистки по дате и времени"
		param "Начало очистки: $(date -d @${START_CREATE})"
		param "Конец очистки: $(date -d @${END_CREATE})"
		;;
	3)
		info_sub "Метод очистки по маске"
		param "Маска: ${FOLDER_MASK}"
		;;
	esac

	info "ОЧИСТКА ЗАПУЩЕНА..."
}

output_info() {
	readonly END_TIME=$(date +%s)
	readonly EXECUTE_TIME=$((END_TIME - START_TIME))
	readonly REPORT_END_TIME=$(date '+%Y-%m-%d %H:%M')

	echo""
	info_sub "Скрипт запущен в ${REPORT_START_TIME}"
	info_sub "Скрипт завершен в ${REPORT_END_TIME}"
	info "Удалено папок: ${FOLDERS} за время: ${EXECUTE_TIME} сек."
	success "ОЧИСТКА ВЫПОЛНЕНА УСПЕШНО"
	report_ex
}

report_ex() {
	if [ -e "${DIR}/fresh.log" ]; then
		info_sub "Файл ${LOG_PATH} содержит информацию об очистке"

		{
			echo "Удалено папок: ${FOLDERS} за время: ${EXECUTE_TIME} сек."
			echo "Скрипт запущен в ${REPORT_START_TIME}"
			echo "Скрипт завершен в ${REPORT_END_TIME}"
		} | cat - "${LOG_PATH}" >temp && mv temp "${LOG_PATH}"
	fi
}

progress_info() {
	echo -ne "\rВыполняется... Очистка ${CYAN}${BOLD}${FOLDERS}${NC} папок"
}

report_folder_clean() {
	echo "${1}" deleted >>${LOG_PATH}
}

report_not_exist_folder() {
	echo "Невозможно удалить ${1}. Папка не существует" >>${LOG_PATH}
}

report_havent_permission_folder() {
	echo "Невозможно удалить ${1}. Нет прав на удаление" >>${LOG_PATH}
}
