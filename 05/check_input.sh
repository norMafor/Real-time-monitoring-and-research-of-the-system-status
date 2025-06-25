#!/bin/bash

check_input() {
	local box=0

	# Проверка наличия выбора
	if [[ $# -ne 1 ]]; then
		error "Введено $# параметров!"
		info_sub "Выберите:"
		info "1 - Сортировка записей по коду ответа"
		info "2 - Фильтрация уникальных IP, встречающиеся в записях"
		info "3 - Фильтрация всех запросов с ошибками (код ответа — 4хх или 5хх)"
		info "4 - Фильтрация уникальных IP, которые встречаются среди ошибочных запросов"
		box=1
	else
		if ! [[ ${1} =~ ^[1-4]$ ]]; then
			error "Неверно введен выбор параметра. Необходимо ввести целое число от 1 до 4"
			box=1
		else
			use_log
			if [[ $? -eq 1 ]]; then
				box=1
			fi
		fi
	fi

	return $box
}

use_log() {
	local box=0
	local target=" $(cd ${DIR} && cd ./../04 && pwd)"
	#local log_files=$(find "${target}" -name "*.log")

	if ! ls $target/*.log &>/dev/null; then
		error "Нет логов в ${target}!"
		box=1
	fi

	return ${box}
}
