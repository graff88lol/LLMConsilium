#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 Быстрый тест Debate Agents${NC}"

# Проверка health
echo -e "\n${GREEN}1. Проверка health оркестратора:${NC}"
curl -s http://localhost:8080/health | jq '.' || echo -e "${RED}❌ Оркестратор не отвечает${NC}"

# Простой тест
echo -e "\n${GREEN}2. Тестовый запрос (функция сложения):${NC}"
./send-request.sh "напиши функцию сложения двух чисел" 1

# Тест с исправлением
echo -e "\n${GREEN}3. Тест с потенциальным исправлением (деление на ноль):${NC}"
./send-request.sh "функция деления без проверки на ноль" 2

echo -e "\n${GREEN}✅ Тестирование завершено${NC}"
