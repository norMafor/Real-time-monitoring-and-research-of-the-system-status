#!/bin/bash

folder_label() {
	local label=${folder_name_letter}
	local random_index

	for ((i = 0; i < 248; i++)); do
		random_index=$((RANDOM % ${#label}))
		label=${label:0:random_index}${label:random_index:1}${label:random_index:${#label}}
		if ! [[ -d "${1}/${label}_${DATE}" ]]; then
			break
		fi
	done

	echo "${label}_${DATE}"
}

file_label() {
	local label=${file_name_letter}
	local random_index

	for ((i = 0; i < 248 - ${#file_extension}; i++)); do
		random_index=$((RANDOM % ${#label}))
		label=${label:0:random_index}${label:random_index:1}${label:random_index:${#label}}
		if [[ ${#label} -ge 5 ]] && [[ ! -e "${1}/${label}_${DATE}.${file_extension}" ]]; then
			break
		fi
	done

	echo "${label}_${DATE}.${file_extension}"
}
