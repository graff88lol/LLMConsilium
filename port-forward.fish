#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$GREEN🔌 Запуск port-forward для Debate Agents$NC"

# Убиваем старые процессы
pkill -f "kubectl port-forward.*orchestrator-svc" 2>/dev/null
pkill -f "kubectl port-forward.*web-ui-svc" 2>/dev/null

# Запускаем port-forward для orchestrator
echo -e "$YELLOW➡️  Orchestrator API: http://localhost:8080$NC"
sudo k3s kubectl port-forward -n $NAMESPACE svc/orchestrator-svc 8080:8080 > /dev/null 2>&1 &

# Запускаем port-forward для веб-интерфейса
echo -e "$YELLOW➡️  Web UI: http://localhost:8081$NC"
sudo k3s kubectl port-forward -n $NAMESPACE svc/web-ui-svc 8081:80 > /dev/null 2>&1 &

echo -e "\n$GREEN✅ Port-forward запущены в фоне$NC"
echo -e "$GREEN🌐 Откройте в браузере: http://localhost:8081$NC"
echo -e "$YELLOW📡 API доступен: http://localhost:8080$NC"
echo -e "\n$YELLOWДля остановки: pkill -f 'kubectl port-forward'$NC"
