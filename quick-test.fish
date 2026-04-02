#!/usr/bin/env fish

set GREEN (set_color green)
set RED (set_color red)
set NC (set_color normal)

echo -e "$GREEN🚀 Быстрый тест Debate Agents$NC"

# Проверка health
echo -e "\n$GREEN1. Проверка health оркестратора:$NC"
curl -s http://localhost:8080/health | jq '.' || echo -e "$RED❌ Оркестратор не отвечает$NC"

# Простой тест
echo -e "\n$GREEN2. Тестовый запрос (функция сложения):$NC"
./send-request.fish "напиши функцию сложения двух чисел" 1

# Тест с исправлением
echo -e "\n$GREEN3. Тест с потенциальным исправлением (деление на ноль):$NC"
./send-request.fish "функция деления без проверки на ноль" 2

echo -e "\n$GREEN✅ Тестирование завершено$NC"
