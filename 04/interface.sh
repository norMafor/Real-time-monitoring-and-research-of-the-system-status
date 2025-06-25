#!/bin/bash

parameters_info() {

	info "ГЕНЕРАЦИЯ ЗАПУЩЕНА..."
}

output_info() {
	readonly END_TIME=$(date +%s)
	readonly EXECUTE_TIME=$((END_TIME - START_TIME))
	readonly REPORT_END_TIME=$(date '+%Y-%m-%d %H:%M')

	info_sub "Скрипт запущен в ${REPORT_START_TIME}"
	info_sub "Скрипт завершен в ${REPORT_END_TIME}"
	info "Сгенерировано 5 log-файлов за время: ${EXECUTE_TIME} сек."

	success "ГЕНЕРАЦИЯ ВЫПОЛНЕНА УСПЕШНО!"
}

progress_info() {
	echo -ne "\rВыполняется... ${CYAN}Генерация${NC} ${MAGENTA}${BOLD}$entries${NC} записей для ${CYAN}$log_date${NC} в файл ${BLUE}${BOLD}$filename${NC}\n"
}
