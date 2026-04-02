#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$GREEN📊 Мониторинг Debate Agents$NC"
echo -e "$BLUE========================================$NC"

# Статус подов
echo -e "$YELLOW🔍 Статус подов:$NC"
sudo k3s kubectl get pods -n $NAMESPACE

echo -e "\n$YELLOW💾 Использование ресурсов:$NC"
sudo k3s kubectl top pods -n $NAMESPACE ^/dev/null || echo -e "$REDМетрики не доступны$NC"

echo -e "\n$YELLOW🔌 Сервисы:$NC"
sudo k3s kubectl get svc -n $NAMESPACE

echo -e "\n$YELLOW🤖 Модели в Generator:$NC"
sudo k3s kubectl exec -n $NAMESPACE deployment/generator -- ollama list ^/dev/null || echo -e "$REDGenerator не доступен$NC"

echo -e "\n$YELLOW🔍 Модели в Critic:$NC"
sudo k3s kubectl exec -n $NAMESPACE deployment/critic -- ollama list ^/dev/null || echo -e "$REDCritic не доступен$NC"

echo -e "\n$YELLOW📝 Последние логи Orchestrator:$NC"
sudo k3s kubectl logs -n $NAMESPACE deployment/orchestrator --tail=10 ^/dev/null || echo -e "$REDOrchestrator не доступен$NC"

echo -e "\n$BLUE========================================$NC"
echo -e "$GREENДля непрерывного мониторинга используйте:$NC"
echo -e "  sudo k3s kubectl logs -n $NAMESPACE deployment/orchestrator -f"
echo -e "  watch -n 2 sudo k3s kubectl get pods -n $NAMESPACE"
