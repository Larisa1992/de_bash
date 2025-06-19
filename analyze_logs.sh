!/bin/bash


echo -e "Отчет о логе веб сервера\n================" > report.txt


awk 'END { print "Общее количество запросов:\t", NR }' access.log >> report.txt

awk '!seen[$1]++ { uniqueIP++; } END { print "Количество уникальных IP-адресов:\t", uniqueIP; }' access.log >> report.txt

awk '
{
    # Извлекаем метод запроса из шестой колонки
    method=$6

    # Убираем лишние символы (" ") вокруг метода
    gsub(/^\"| \"$/, "", method)

    # Увеличиваем счётчик соответствующего метода
    methods[method]++
}

# Выводим итоги после обработки всех строк
END {print "\nКоличество запросов по методам:"
    for (m in methods) {
        print "\t"  m ": " methods[m]
    }
}' access.log >> report.txt



awk '
BEGIN { FS="\"" }                           # Разделитель полей — двойные кавычки
{
    full_request=$2                          # Второе поле содержит запрос вида "GET /index.html HTTP/1.1"
    if(full_request ~ /^GET/) {              # Фильтруем только GET-запросы
        match(full_request, "GET (.+) HTTP") # Извлекаем чистый URL между "GET " и " HTTP"
        clean_url = substr(full_request, RSTART+4, RLENGTH-9) # Извлекаем URL без GET и HTTP
        urls[clean_url]++                    # Увеличиваем счётчик для этого URL
    }
}

END {
    max_count = 0                            # Максимальная частота URL
    popular_url = ""                         # Самый популярный URL
    for(u in urls) {
        if(urls[u] > max_count) {            # Определяем максимальный URL
            max_count = urls[u]
            popular_url = u
        }
    }

    print "\nСамый популярный URL: \t" max_count popular_url
}'  access.log >> report.txt



