#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$GREEN🚀 Начинаем деплой Debate Agents в k3s$NC"

# Создание namespace если не существует
echo -e "$YELLOW📦 Создание namespace...$NC"
sudo k3s kubectl create namespace $NAMESPACE 2>/dev/null; or echo -e "$YELLOWNamespace уже существует$NC"

# Применяем generator
echo -e "$YELLOW🤖 Деплой Generator...$NC"
sudo k3s kubectl apply -f generator-fixed.yaml

# Применяем critic
echo -e "$YELLOW🔍 Деплой Critic...$NC"
sudo k3s kubectl apply -f critic-fixed.yaml

# Ждем готовности generator
echo -e "$YELLOW⏳ Ожидание готовности Generator...$NC"
while true
    set pod_status (sudo k3s kubectl get pods -n $NAMESPACE -l app=generator -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
    if test "$pod_status" = "True"
        break
    end
    sleep 2
    echo -n "."
end
echo -e "\n$GREEN✅ Generator готов$NC"

# Ждем готовности critic
echo -e "$YELLOW⏳ Ожидание готовности Critic...$NC"
while true
    set pod_status (sudo k3s kubectl get pods -n $NAMESPACE -l app=critic -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
    if test "$pod_status" = "True"
        break
    end
    sleep 2
    echo -n "."
end
echo -e "\n$GREEN✅ Critic готов$NC"

# Применяем orchestrator
echo -e "$YELLOW🎼 Деплой Orchestrator...$NC"
sudo k3s kubectl apply -f orchestrator-fixed.yaml

# Ждем готовности orchestrator
echo -e "$YELLOW⏳ Ожидание готовности Orchestrator...$NC"
while true
    set pod_status (sudo k3s kubectl get pods -n $NAMESPACE -l app=orchestrator -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
    if test "$pod_status" = "True"
        break
    end
    sleep 2
    echo -n "."
end
echo -e "\n$GREEN✅ Orchestrator готов$NC"

# Проверяем скачивание моделей
echo -e "$YELLOW📥 Проверка скачивания моделей...$NC"
echo -e "$GREENМодели в Generator:$NC"
sudo k3s kubectl exec -n $NAMESPACE deployment/generator -- ollama list 2>/dev/null; or echo -e "$REDGenerator не готов$NC"
echo ""
echo -e "$GREENМодели в Critic:$NC"
sudo k3s kubectl exec -n $NAMESPACE deployment/critic -- ollama list 2>/dev/null; or echo -e "$REDCritic не готов$NC"

# Запускаем port-forward в фоне
echo -e "$YELLOW🔌 Настройка port-forward...$NC"
pkill -f "kubectl port-forward.*orchestrator-svc" 2>/dev/null
sudo k3s kubectl port-forward -n $NAMESPACE svc/orchestrator-svc 8080:8080 > /dev/null 2>&1 &
echo -e "$GREEN✅ Port-forward запущен на :8080$NC"

echo -e "\n$GREEN========================================$NC"
echo -e "$GREEN✅ Деплой успешно завершен!$NC"
echo -e "$GREEN========================================$NC"
echo -e "$YELLOWAPI доступен:$NC http://localhost:8080"
echo -e "$YELLOWHealth check:$NC curl http://localhost:8080/health"
echo -e "$YELLOWПример запроса:$NC ./send-request.fish \"напиши hello world\" 2"
echo -e "$GREEN========================================$NC"
