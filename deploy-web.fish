#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$GREEN🚀 Деплой веб-интерфейса Debate Agents$NC"

# Проверяем что образ существует
docker image inspect web-ui:latest > /dev/null 2>&1
if test $status -ne 0
    echo -e "$RED❌ Образ web-ui:latest не найден. Запустите ./build-web.fish$NC"
    exit 1
end

# Загружаем образ в k3s (для локального кластера)
echo -e "$YELLOW📦 Загрузка образа в k3s...$NC"
docker save web-ui:latest | sudo k3s ctr images import -

# Применяем деплоймент
echo -e "$YELLOW🔧 Применение манифеста...$NC"
sudo k3s kubectl apply -f web-app-deployment.yaml

# Ждем готовности
echo -e "$YELLOW⏳ Ожидание готовности подов...$NC"
sleep 10

# Получаем NodePort
set NODEPORT (sudo k3s kubectl get svc -n $NAMESPACE web-ui-svc -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

if test -n "$NODEPORT"
    echo -e "\n$GREEN========================================$NC"
    echo -e "$GREEN✅ Веб-интерфейс развернут!$NC"
    echo -e "$GREEN========================================$NC"
    echo -e "$YELLOW🌐 Доступ:$NC http://localhost:$NODEPORT"
    echo -e "$YELLOWИли через port-forward:$NC"
    echo -e "   sudo k3s kubectl port-forward -n $NAMESPACE svc/web-ui-svc 8081:80"
else
    echo -e "\n$YELLOW⏳ Сервис еще создается, попробуйте через несколько секунд:$NC"
    echo -e "   sudo k3s kubectl port-forward -n $NAMESPACE svc/web-ui-svc 8081:80"
end
echo -e "$GREEN========================================$NC"
