#!/bin/bash

segregation() {
	#local log_path=$(cd ${DIR} && cd ./../04 && pwd)
	local log_path=$(cd ./../04 && pwd)
	local logs=$(ls ${log_path}/*.log)
	local count=0

	mkdir -p ${DIR}/sort_logs

	for log in ${logs}; do
		base_name=$(basename "${log}")

		# Извлекаем имя файла и расширение
		file_name="${base_name%.*}"
		extension="${base_name##*.}"

		local sort_log_name="${DIR}/sort_logs/${1}_${file_name}_sort.${extension}"

		progress_info ${count}

		{
			case ${1} in
			1) # Все записи, отсортированные по коду ответа и по IP
				awk '{print $0}' ${log} | sort -k9,9n -k1,1V ;;
			2) # Все уникальные IP, встречающиеся в записях, отсортированные по возрастанию
				awk '{print $1}' ${log} | sort -u | sort -V ;;
			3) # Все запросы с ошибками (код ответа — 4хх или 5хх), отсортированные по коду ответа и по IP
				awk '$9 ~ /^4|^5/' ${log} | sort -k9,9n -k1,1V ;;
			4) # Все уникальные IP, которые встречаются среди ошибочных запросов, отсортированные по возрастанию
				awk '$9 ~ /^4|^5/' ${log} | awk '{print $1}' | sort -u | sort -V ;;
			esac
		} >>${sort_log_name}

		((count++))
		progress_info ${count}
	done
}
