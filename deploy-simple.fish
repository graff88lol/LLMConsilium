#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$GREEN🚀 Деплой Debate Agents в k3s$NC"

# Создание namespace
sudo k3s kubectl create namespace $NAMESPACE 2>/dev/null

# Деплой всех компонентов
echo -e "$YELLOW🤖 Деплой Generator...$NC"
sudo k3s kubectl apply -f generator-fixed.yaml

echo -e "$YELLOW🔍 Деплой Critic...$NC"
sudo k3s kubectl apply -f critic-fixed.yaml

echo -e "$YELLOW🎼 Деплой Orchestrator...$NC"
sudo k3s kubectl apply -f orchestrator-fixed.yaml

# Ждем 30 секунд для старта
echo -e "$YELLOW⏳ Ожидание 30 секунд для старта подов...$NC"
sleep 30

# Показываем статус
echo -e "\n$GREEN📊 Статус подов:$NC"
sudo k3s kubectl get pods -n $NAMESPACE

# Запускаем port-forward
echo -e "$YELLOW🔌 Настройка port-forward...$NC"
pkill -f "kubectl port-forward.*orchestrator-svc" 2>/dev/null
sudo k3s kubectl port-forward -n $NAMESPACE svc/orchestrator-svc 8080:8080 > /dev/null 2>&1 &

echo -e "\n$GREEN========================================$NC"
echo -e "$GREEN✅ Деплой завершен!$NC"
echo -e "$GREEN========================================$NC"
echo -e "$YELLOWAPI доступен:$NC http://localhost:8080"
echo -e "$YELLOWПроверка логов:$NC sudo k3s kubectl logs -n $NAMESPACE deployment/orchestrator"
echo -e "$GREEN========================================$NC"
