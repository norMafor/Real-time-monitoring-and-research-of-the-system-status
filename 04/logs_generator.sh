#!/bin/bash

# Генератор логов Nginx в формате combined
# Создает 5 файлов с логами за последние 5 дней

# Функция генерации случайного IP
generate_valid_ip() {
    local first_octet=$((RANDOM % 254 + 1))  # Генерируем от 1 до 254
    local second_octet=$((RANDOM % 256))      # Генерируем от 0 до 255
    local third_octet=$((RANDOM % 256))       # Генерируем от 0 до 255
    local fourth_octet=$((RANDOM % 256))      # Генерируем от 0 до 255

    # Проверка на диапазон для частных адресов
    while [[ $first_octet -eq 10 || $first_octet -eq 172 && $second_octet -ge 16 && $second_octet -le 31 || $first_octet -eq 192 && $second_octet -eq 168 ]]; do
        first_octet=$((RANDOM % 254 + 1))  # Генерируем новый первый октет
    done

    echo "${first_octet}.${second_octet}.${third_octet}.${fourth_octet}"
}

# Коды ответов HTTP и их значения (RFC 9110)
# 200 - OK: Успешный запрос
# 201 - Created: Ресурс создан
# 400 - Bad Request: Неверный синтаксис
# 401 - Unauthorized: Требуется аутентификация
# 403 - Forbidden: Доступ запрещен
# 404 - Not Found: Ресурс не найден
# 500 - Internal Server Error: Ошибка сервера
# 501 - Not Implemented: Метод не поддерживается
# 502 - Bad Gateway: Ошибка шлюза
# 503 - Service Unavailable: Сервис недоступен
status_codes=(200 201 400 401 403 404 500 501 502 503)

methods=("GET" "POST" "PUT" "PATCH" "DELETE")
user_agents=(
	"Mozilla/5.0"
	"Google Chrome/114.0.5735.134"
	"Opera/9.80"
	"Safari/537.36"
	"Internet Explorer/11.0"
	"Microsoft Edge/114.0.1823.58"
	"Python-urllib/3.10"
	"curl/7.81.0"
)

generate_log_line() {
	local timestamp=$1
	local time_local=$(date -d "@$timestamp" "+%d/%b/%Y:%H:%M:%S %z")
	local ip=$(generate_valid_ip)
	local status=${status_codes[$((RANDOM % ${#status_codes[@]}))]}
	local method=${methods[$((RANDOM % ${#methods[@]}))]}
	local bytes=$((RANDOM % 5000 + 100))

	# Генерация случайного URL
	local urls=("/api/v1/users" "/posts" "/images" "/download" "/search")
	local url=${urls[$((RANDOM % ${#urls[@]}))]}
	url+="?query=$RANDOM"

	local agent=${user_agents[$((RANDOM % ${#user_agents[@]}))]}

	# Формат combined
	echo "$ip - - [$time_local] \"$method $url HTTP/1.1\" $status $bytes \"-\" \"$agent\""
}

# Создаем 5 файлов логов
for days_ago in {0..4}; do
	log_date=$(date -d "-$days_ago days" "+%Y-%m-%d")
	filename="nginx_$log_date.log"
	entries=$((RANDOM % 901 + 100))

	#echo -e "${CYAN}Генерация${NC} ${MAGENTA}${BOLD}$entries${NC} записей для ${CYAN}$log_date${NC} в файл ${BLUE}${BOLD}$filename${NC}"
	progress_info

	# Генерируем временные метки и сортируем
	declare -a timestamps
	start_ts=$(date -d "$log_date 00:00:00" +%s)
	end_ts=$(date -d "$log_date 23:59:59" +%s)

	for ((i = 0; i < entries; i++)); do
		timestamps[$i]=$((start_ts + RANDOM % (end_ts - start_ts)))
	done

	# Сортировка временных меток
	readarray -t sorted < <(printf '%s\n' "${timestamps[@]}" | sort -n)

	# Запись в файл
	for ts in "${sorted[@]}"; do
		generate_log_line "$ts" >>"$filename"
	done

	unset timestamps

done
