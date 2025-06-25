#!/bin/bash

parameters_info() {

	info "ВЫ ВЫБРАЛИ:"

	case ${1} in
	1)
		info_sub "Параметр:"
		param "Сортировка записей по коду ответа"
		;;
	2)
		info_sub "Параметр:"
		param "Фильтрация уникальных IP, встречающиеся в записях"
		;;
	3)
		info_sub "Параметр:"
		param "Фильтрация всех запросов с ошибками (код ответа — 4хх или 5хх)"
		;;
	4)
		info_sub "Параметр:"
		param "Фильтрация уникальных IP, которые встречаются среди ошибочных запросов"
		;;
	esac

	info "СОРТИРОВКА ЗАПУЩЕНА..."
}

output_info() {
	readonly END_TIME=$(date +%s)
	readonly EXECUTE_TIME=$((END_TIME - START_TIME))
	readonly REPORT_END_TIME=$(date '+%Y-%m-%d %H:%M')

	echo""
	info_sub "Скрипт запущен в ${REPORT_START_TIME}"
	info_sub "Скрипт завершен в ${REPORT_END_TIME}"
	info "Создано 5 отчетов за время: ${EXECUTE_TIME} сек."
	param "Файлы отчетов размещены ${DIR}/sort_logs"
	success "СОРТИРОВКА ВЫПОЛНЕНА УСПЕШНО"
}

progress_info() {
	echo -ne "\rВыполняется... ${CYAN}Создание отчета${NC} ${MAGENTA}${BOLD}${1}${NC} логов"
}
