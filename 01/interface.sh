#!/bin/bash

parameters_info() {
	info "ВЫ ВВЕЛИ СЛЕДУЮЩИЕ ПАРАМЕТРЫ:"

	info_sub "Абсолютный путь к директории генерации файлов:"
	param "${path}"
	info_sub_short "Количество вложенных папок: "
	param "${count_folders}"
	info_sub_short "Список букв в названии папок: "
	param "${folder_name_letter}"
	info_sub_short "Количество файлов в каждой папке: "
	param "${count_files}"
	info_sub_short "Список букв в названии и расширении файлов: "
	param "${file_name_letter}"
	info_sub_short "Размер генерируемых файлов в килобайтах: "
	param "${size_kb}"

	info "ГЕНЕРАЦИЯ ЗАПУЩЕНА..."
}

output_info() {
	readonly END_TIME=$(date +%s)
	readonly EXECUTE_TIME=$((END_TIME - START_TIME))
	readonly REPORT_END_TIME=$(date '+%Y-%m-%d %H:%M')

	if [[ ${OVERLY} -eq 1 ]]; then
		error "WARNING: Недостаточно места на диске" 1>&2
	else
		success "Места на диске достаточно для выполнения задания по указанным параметрам"
	fi

	info_sub "Скрипт запущен в ${REPORT_START_TIME}"
	info_sub "Скрипт завершен в ${REPORT_END_TIME}"
	info "Сгенерировано папок: ${FOLDERS}  и файлов: ${FILES}  за время: ${EXECUTE_TIME} сек."

	report_log_addition

	success "ГЕНЕРАЦИЯ ВЫПОЛНЕНА УСПЕШНО"
}

report_log_addition() {
	if [ -e "${DIR}/report.log" ]; then
		info_sub "Файл ${LOG_PATH} содержит информацию о генерации"

		{
			echo "Сгенерировано папок: ${FOLDERS}  и файлов: ${FILES}  за время: ${EXECUTE_TIME} сек."
			echo "Скрипт запущен в ${REPORT_START_TIME}"
			echo "Скрипт завершен в ${REPORT_END_TIME}"
		} | cat - "${LOG_PATH}" >temp && mv temp "${LOG_PATH}"
	fi
}

progress_info() {
	echo -ne "\rВыполняется... Генерация ${CYAN}${BOLD}${FOLDERS}${NC} папок и  ${CYAN}${BOLD}${FILES}${NC} файлов"
}

log_file_create() {
	echo "${REPORT_DATE} создан файл размером ${file_size} байт: ${folder_in_depth_dir}/${file_name}" >>${LOG_PATH}
}

log_folder_create() {
	echo "${REPORT_DATE} создана папка: ${folder_in_depth_dir}/${folder_name}" >>${LOG_PATH}
}
