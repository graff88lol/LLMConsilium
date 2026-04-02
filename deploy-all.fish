#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set NC (set_color normal)

echo -e "$GREEN🚀 Полный деплой Debate Agents с веб-интерфейсом$NC"

# Деплой бэкенда
./deploy.fish

# Сборка и деплой веб-интерфейса
./build-web.fish
./deploy-web.fish

echo -e "\n$GREEN========================================$NC"
echo -e "$GREEN✅ Полный деплой завершен!$NC"
echo -e "$GREEN========================================$NC"
