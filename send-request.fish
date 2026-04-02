#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set BLUE (set_color blue)
set NC (set_color normal)

# Проверка аргументов
if test (count $argv) -lt 1
    echo -e "$RED❌ Ошибка: Не указана задача$NC"
    echo -e "$YELLOWИспользование:$NC $argv[0] \"ваша задача\" [количество раундов]"
    echo -e "$YELLOWПример:$NC $argv[0] \"напиши функцию сортировки\" 3"
    exit 1
end

set TASK $argv[1]
set ROUNDS 2
if test (count $argv) -ge 2
    set ROUNDS $argv[2]
end

# Проверка что rounds - число
if not string match -r '^[0-9]+$' $ROUNDS > /dev/null
    echo -e "$RED❌ Ошибка: Количество раундов должно быть числом$NC"
    exit 1
end

echo -e "$BLUE========================================$NC"
echo -e "$GREEN🎯 Задача:$NC $TASK"
echo -e "$GREEN🔄 Раунды:$NC $ROUNDS"
echo -e "$BLUE========================================$NC"
echo -e "$YELLOW⏳ Отправка запроса к оркестратору...$NC\n"

# Отправляем запрос и сохраняем ответ (используем random вместо pid)
set RANDOM (random)
set RESPONSE_FILE "/tmp/debate_response_$RANDOM.json"
curl -s -X POST http://localhost:8080/debate \
  -H "Content-Type: application/json" \
  -d "{\"task\": \"$TASK\", \"max_rounds\": $ROUNDS}" \
  | jq '.' > $RESPONSE_FILE

# Проверяем успешность
if test $status -eq 0 -a -s $RESPONSE_FILE
    echo -e "$GREEN✅ Ответ получен!$NC\n"
    
    # Выводим информацию о дебатах
    set ROUNDS_DONE (jq -r '.rounds' $RESPONSE_FILE)
    echo -e "$BLUE📊 Статистика:$NC"
    echo -e "   Проведено раундов: $GREEN$ROUNDS_DONE$NC"
    echo -e ""
    
    # Выводим финальный код
    echo -e "$BLUE💻 Финальный код:$NC"
    echo -e "$YELLOW----------------------------------------$NC"
    jq -r '.final_code' $RESPONSE_FILE | while read line
        echo "  $line"
    end
    echo -e "$YELLOW----------------------------------------$NC"
    
    # Выводим историю дебатов
    if test $ROUNDS_DONE -gt 0
        echo -e "\n$BLUE📜 История дебатов:$NC"
        set i 0
        while test $i -lt $ROUNDS_DONE
            set round_num (math $i + 1)
            echo -e "\n$GREEN--- Раунд $round_num ---$NC"
            
            set CODE (jq -r ".history[$i].code" $RESPONSE_FILE)
            set CRITIQUE (jq -r ".history[$i].critique" $RESPONSE_FILE)
            
            echo -e "$YELLOW📝 Код:$NC"
            echo $CODE | head -10 | while read line
                echo "  $line"
            end
            set CODE_LINES (echo $CODE | wc -l)
            if test $CODE_LINES -gt 10
                echo "  ... (сокращено)"
            end
            
            echo -e "$YELLOW🔍 Критика:$NC"
            echo $CRITIQUE | while read line
                echo "  $line"
            end
            
            set i (math $i + 1)
        end
    end
    
    # Сохраняем полный ответ
    set TIMESTAMP (date +"%Y%m%d_%H%M%S")
    set SAVE_FILE "debate_response_$TIMESTAMP.json"
    cp $RESPONSE_FILE $SAVE_FILE
    echo -e "\n$GREEN💾 Полный ответ сохранен в: $SAVE_FILE$NC"
    
else
    echo -e "$RED❌ Ошибка при выполнении запроса$NC"
    echo -e "$YELLOWПроверьте:$NC"
    echo -e "  1. Запущен ли порт-форвард (./deploy.fish)"
    echo -e "  2. Доступен ли оркестратор (curl http://localhost:8080/health)"
    exit 1
end

# Очистка
rm -f $RESPONSE_FILE

echo -e "\n$BLUE========================================$NC"
