#!/bin/bash

# Функция для проверки имени файла
check_file_name() {
	local file_name="$1"

	if [[ ${#file_name} -gt 7 ]]; then
		error "Неверное имя файла, длина не должна превышать 7 символов"
		return 1
	elif ! [[ "$file_name" =~ ^[a-zA-Z]{1,7}$ ]]; then
		error "Неверное имя файла, должно быть от 1 до 7 английских букв"
		return 1
	fi
}

# Функция для проверки расширения файла
check_file_extension() {
	local extension="$1"

	if [[ ${#extension} -gt 3 ]]; then
		error "Неверное расширение файла, длина не должна превышать 3 символов"
		return 1
	elif ! [[ "$extension" =~ ^[a-zA-Z]{1,3}$ ]]; then
		error "Неверное расширение файла, должно быть от 1 до 3 английских букв"
		return 1
	fi
}

check_input() {
	local box=0

	# Проверка количества параметров
	if ! [[ $# -eq 3 ]]; then
		error "Неверное количество параметров, должно быть введено 3 параметра"
		box=1
	fi

	# Проверка первого параметра (буквы для имени папок)
	if ! [[ ${1} =~ ^[a-zA-Z]{1,7}$ ]]; then
		error "Неверно введены буквы для папок, должно быть от 1 до 7 английских букв"
		box=1
	else
		if [[ ${box} -eq 0 ]]; then
			if ! check_reuse "${3}"; then
				box=1
			fi
		fi
	fi

	# Проверка второго параметра (буквы  для имени файла)
	if ! [[ ${2} =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]; then
		error "Неверно введены буквы для файлов, должно быть от 1 до 7 английских букв и расширение от 1 до 3 английских букв"
		box=1
	else
		if [[ ${box} -eq 0 ]]; then

			local file_name="${2%.*}"
			local file_ext="${2#*.}"
			if ! check_file_name "${file_name}" || ! check_reuse "${file_name}" || ! check_file_extension "${file_ext}"; then
				box=1
			fi
		fi
	fi

	# Проверка третьего параметра (размер файла)

# 	if [[ $3 == *Mb ]]; then
# 		size_mb=${3%Mb}
# 	fi

	if ! [[ ${3} =~ ^[0-9]+Mb$ ]] || [[ ${3::-2} -lt 1 || ${3::-2} -gt 100 ]]; then
		error "Неверно введен размер файлов, размер файлов может быть от 1 до 100Mb"
		box=1
	fi

	if [[ $box -eq 1 ]]; then
		return $box
	else
		success "Параметры введены корректно!"
		return $box
	fi
}
check_reuse() {
	local prev_letter=""

	for ((i = 0; i < ${#1}; i++)); do
		local current_letter="${1:i:1}"
		if [[ $current_letter == $prev_letter ]]; then
			error "Ошибка: найдены повторяющиеся символы в имени папки или файлa"
			return 1
		fi
		prev_letter=$current_letter
	done

	return 0
}
