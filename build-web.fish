#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set NC (set_color normal)

echo -e "$GREEN🐳 Сборка Docker образа для веб-интерфейса...$NC"

cd web-app
docker build -t web-ui:latest .
cd ..

echo -e "$GREEN✅ Образ web-ui:latest создан$NC"
echo -e "$YELLOWДля деплоя выполните: ./deploy-web.fish$NC"
