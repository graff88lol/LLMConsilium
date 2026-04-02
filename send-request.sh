#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ Ошибка: Не указана задача${NC}"
    echo -e "${YELLOW}Использование:${NC} $0 \"ваша задача\" [количество раундов]"
    echo -e "${YELLOW}Пример:${NC} $0 \"напиши функцию сортировки\" 3"
    exit 1
fi

TASK="$1"
ROUNDS="${2:-2}"  # По умолчанию 2 раунда

# Проверка что rounds - число
if ! [[ "$ROUNDS" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}❌ Ошибка: Количество раундов должно быть числом${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎯 Задача:${NC} $TASK"
echo -e "${GREEN}🔄 Раунды:${NC} $ROUNDS"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}⏳ Отправка запроса к оркестратору...${NC}\n"

# Отправляем запрос и сохраняем ответ в файл
RESPONSE_FILE="/tmp/debate_response_$$.json"
curl -s -X POST http://localhost:8080/debate \
  -H "Content-Type: application/json" \
  -d "{\"task\": \"$TASK\", \"max_rounds\": $ROUNDS}" \
  | jq '.' > "$RESPONSE_FILE"

# Проверяем успешность
if [ $? -eq 0 ] && [ -s "$RESPONSE_FILE" ]; then
    echo -e "${GREEN}✅ Ответ получен!${NC}\n"
    
    # Выводим информацию о дебатах
    ROUNDS_DONE=$(jq -r '.rounds' "$RESPONSE_FILE")
    echo -e "${BLUE}📊 Статистика:${NC}"
    echo -e "   Проведено раундов: ${GREEN}$ROUNDS_DONE${NC}"
    echo -e ""
    
    # Выводим финальный код
    echo -e "${BLUE}💻 Финальный код:${NC}"
    echo -e "${YELLOW}----------------------------------------${NC}"
    jq -r '.final_code' "$RESPONSE_FILE" | sed 's/^/  /'
    echo -e "${YELLOW}----------------------------------------${NC}"
    
    # Выводим историю дебатов (если больше 0 раундов)
    if [ "$ROUNDS_DONE" -gt 0 ]; then
        echo -e "\n${BLUE}📜 История дебатов:${NC}"
        for i in $(seq 0 $((ROUNDS_DONE - 1))); do
            echo -e "\n${GREEN}--- Раунд $((i+1)) ---${NC}"
            
            CODE=$(jq -r ".history[$i].code" "$RESPONSE_FILE" | head -20)
            CRITIQUE=$(jq -r ".history[$i].critique" "$RESPONSE_FILE")
            
            echo -e "${YELLOW}📝 Код:${NC}"
            echo "$CODE" | sed 's/^/  /' | head -10
            if [ $(echo "$CODE" | wc -l) -gt 10 ]; then
                echo "  ... (сокращено)"
            fi
            
            echo -e "${YELLOW}🔍 Критика:${NC}"
            echo "$CRITIQUE" | sed 's/^/  /'
        done
    fi
    
    # Сохраняем полный ответ в файл
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    SAVE_FILE="debate_response_${TIMESTAMP}.json"
    cp "$RESPONSE_FILE" "$SAVE_FILE"
    echo -e "\n${GREEN}💾 Полный ответ сохранен в: $SAVE_FILE${NC}"
    
else
    echo -e "${RED}❌ Ошибка при выполнении запроса${NC}"
    echo -e "${YELLOW}Проверьте:${NC}"
    echo -e "  1. Запущен ли порт-форвард (./deploy.sh)"
    echo -e "  2. Доступен ли оркестратор (curl http://localhost:8080/health)"
    exit 1
fi

# Очистка
rm -f "$RESPONSE_FILE"

echo -e "\n${BLUE}========================================${NC}"
