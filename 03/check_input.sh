#!/bin/bash

# Функции отображения
show_error() {
	whiptail --title "Ошибка" --msgbox "$1" 10 60
}

show_info() {
	whiptail --title "Информация" --msgbox "$1" 10 60
}

show_menu() {
	# Заголовок
	TITLE="СПОСОБЫ ОЧИСТКИ"

	# Опции меню
	OPTIONS=("1" "Очистка по log-файлу"
		"2" "Очистка по дате/времени"
		"3" "Очистка по маске")

	# Создание меню
	return $(whiptail --title "$TITLE" --menu --nocancel "Вызовите скрипт с параметром - способ очистки:" 15 50 5 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
}

# Основная функция проверки ввода
check_input() {
	local choice=${1:-}

	if [[ -z "$choice" ]]; then
		show_menu
		exit 0
	fi

	case $choice in
	1)
		whiptail --msgbox "Вы выбрали способ очистки по log-файлу"
		choice_log
		return $?
		;;
	2)
		if ! get_datetime_range; then
			return 1
		fi
		;;
	3)
		choice_mask
		return $?
		;;
	*)
		return 1
		;;
	esac
}

# Выбор лог-файла
choice_log() {
	while true; do
		LOG_CLEAN_PATH=$(whiptail --inputbox "Введите ОТНОСИТЕЛЬНЫЙ путь к log-файлу:" 10 60 3>&1 1>&2 2>&3)

		# Проверка на отмену ввода
		if [ $? -ne 0 ]; then
			return 1
		fi

		# Проверка пустого ввода
		if [[ -z "$LOG_CLEAN_PATH" ]]; then
			show_error "Путь не может быть пустым!"
			continue
		fi

		# Проверка на абсолютный путь
		if [[ "$LOG_CLEAN_PATH" =~ ^/ ]]; then
			show_error "Необходимо указать ОТНОСИТЕЛЬНЫЙ путь!"
			continue
		fi

		# Полный путь относительно скрипта
		#LOG_CLEAN_PATH="../01/report.log"
		local full_path="${DIR}/${LOG_CLEAN_PATH}"

		# Проверка существования файла
		if [[ ! -f "$full_path" ]]; then
			show_error "Файл не существует по пути: ${full_path}"
			if whiptail --yesno "Хотите ввести путь заново?" 10 60; then
				continue
			else
				return 1
			fi
		fi

		return 0
	done
}

# Получение диапазона дат и времени
get_datetime_range() {
	while true; do
		# Ввод начальной даты и времени
		local start_create_str
		start_create_str=$(whiptail --inputbox "Введите начальную дату и время (Формат: ГГГГ-ММ-ДД ЧЧ-ММ):" 10 40 3>&1 1>&2 2>&3)
		[ $? -ne 0 ] && return 1 # Обработка отмены ввода

		# Ввод конечной даты и времени
		local end_create_str=$(whiptail --inputbox "Введите конечную дату и время (Формат: ГГГГ-ММ-ДД ЧЧ-ММ):" 10 40 3>&1 1>&2 2>&3)
		[ $? -ne 0 ] && return 1 # Обработка отмены ввода

		# Проверка формата
		if ! validate_format "$start_create_str" || ! validate_format "$end_create_str"; then
			show_error "Неверный формат! Пример: 2023-12-31 23-59"
			continue
		fi

		if ! check_real_date "$start_create_str" || ! check_real_date "$end_create_str"; then
			show_error "Несуществующая дата (например, 30 февраля)"
			continue
		fi

		# Проверка валидности даты и времени
		if ! validate_datetime "$start_create_str" || ! validate_datetime "$end_create_str"; then
			show_error "Некорректное время!"
			continue
		fi

		# Конвертация в timestamp
		if ! START_CREATE=$(convert_to_timestamp "$start_create_str"); then
			show_error "Ошибка конвертации начальной даты"
			continue
		fi

		if ! END_CREATE=$(convert_to_timestamp "$end_create_str"); then
			show_error "Ошибка конвертации конечной даты"
			continue
		fi

		local now_ts=$(date "+%s")

		# Отладочный вывод
		#echo "Start: $START_CREATE ($(date -d @$START_CREATE))" >&2
		#echo "End: $END_CREATE ($(date -d @$END_CREATE))" >&2
		#echo "Now: $now_ts ($(date -d @$now_ts))" >&2

		# Проверка логики диапазона
		if ((START_CREATE > END_CREATE)); then
			show_error "Дата начала должна быть раньше окончания!"
			continue
		fi

		# Убрать эту проверку, если разрешены будущие даты
		if ((END_CREATE > now_ts)); then
			show_error "Конечная дата не может быть в будущем!"
			continue
		fi

		return 0
	done
}

validate_time_format() {
	[[ "$1" =~ ^([01][0-9]|2[0-3])-([0-5][0-9])$ ]]
}

# Проверка формата (YYYY-MM-DD HH-MM)
validate_format() {
	[[ "$1" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\ ([01][0-9]|2[0-3])-([0-5][0-9])$ ]] || return 1
}

# Проверка существования даты
check_real_date() {
	local input="$1"
	local date_part="${input%% *}"

	# Проверка через GNU date
	date -d "${date_part}" &>/dev/null
	return $?
}

# Проверка корректности даты и времени
validate_datetime() {
	local input="$1"

	# Разделяем дату и время
	local date_part="${input%% *}" # Все до первого пробела (дата)
	local time_part="${input##* }" # Все после пробела (время)

	# Заменяем дефисы в времени на двоеточия
	time_part="${time_part/-/:}"

	# Собираем полную строку даты
	local dt="${date_part} ${time_part}"

	# Проверяем валидность
	date -d "${dt}" &>/dev/null
	return $?
}

# Конвертация в timestamp
convert_to_timestamp() {
	local input="$1"

	# Разделяем дату и время
	local date_part="${input%% *}"
	local time_part="${input##* }"

	# Заменяем дефисы в времени
	time_part="${time_part/-/:}"

	# Собираем строку для конвертации
	local dt="${date_part} ${time_part}"

	# Возвращаем timestamp
	date -d "${dt}" "+%s"
}

# Выбор маски
choice_mask() {
	while true; do
		FOLDER_MASK=$(whiptail --inputbox "Введите маску (формат: имя_DDMMYY):" 10 60 3>&1 1>&2 2>&3)

		if [[ ! "$FOLDER_MASK" =~ ^[a-zA-Z]{1,7}_[0-9]{6}$ ]]; then
			show_error "Неверный формат маски!\nПример: test_031223"
			continue
		fi

		return 0
	done
}
