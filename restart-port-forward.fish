#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$GREEN🔧 Перезапуск port-forward для Debate Agents$NC"

# Порты которые используем
set PORTS 8080 8081

# Убиваем процессы на нужных портах
echo -e "$YELLOW🔍 Поиск и остановка процессов на портах: $PORTS$NC"

for PORT in $PORTS
    # Найти PID процесса на порту
    set PIDS (sudo lsof -t -i :$PORT 2>/dev/null)
    
    if test -n "$PIDS"
        for PID in $PIDS
            echo -e "$YELLOW  ⚠️  Убиваем процесс $PID на порту $PORT$NC"
            sudo kill -9 $PID 2>/dev/null
        end
    else
        echo -e "$GREEN  ✅ Порт $PORT свободен$NC"
    end
end

# Убиваем все kubectl port-forward процессы (на всякий случай)
echo -e "$YELLOW🔍 Убиваем все kubectl port-forward процессы...$NC"
sudo pkill -f "kubectl port-forward" 2>/dev/null
echo -e "$GREEN  ✅ Готово$NC"

# Небольшая пауза
sleep 2

# Запускаем port-forward для orchestrator (порт 8080 -> 8000)
echo -e "\n$YELLOW🚀 Запуск port-forward для Orchestrator (8080 -> 8000)...$NC"
sudo k3s kubectl port-forward -n $NAMESPACE svc/orchestrator-svc 8080:8000 > /dev/null 2>&1 &
if test $status -eq 0
    echo -e "$GREEN  ✅ Orchestrator API: http://localhost:8080$NC"
else
    echo -e "$RED  ❌ Ошибка запуска orchestrator port-forward$NC"
end

# Запускаем port-forward для веб-интерфейса (порт 8081 -> 80)
echo -e "$YELLOW🚀 Запуск port-forward для Web UI (8081 -> 80)...$NC"
sudo k3s kubectl port-forward -n $NAMESPACE svc/web-ui-svc 8081:80 > /dev/null 2>&1 &
if test $status -eq 0
    echo -e "$GREEN  ✅ Web UI: http://localhost:8081$NC"
else
    echo -e "$YELLOW  ⚠️  Web UI не найден (сервис может быть не развернут)$NC"
end

echo -e "\n$GREEN========================================$NC"
echo -e "$GREEN✅ Port-forward запущены!$NC"
echo -e "$GREEN========================================$NC"
echo -e "$YELLOW🌐 API: http://localhost:8080$NC"
echo -e "$YELLOW🌐 Web UI: http://localhost:8081$NC"
echo -e "\n$YELLOW📊 Проверка здоровья API:$NC"
echo -e "   curl http://localhost:8080/health"
echo -e "\n$YELLOW🔍 Проверить процессы:$NC"
echo -e "   ps aux | grep 'port-forward'"
echo -e "\n$YELLOW🛑 Остановить все:$NC"
echo -e "   ./stop-port-forward.fish"
echo -e "$GREEN========================================$NC"
