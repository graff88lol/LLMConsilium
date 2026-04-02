#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

NAMESPACE="debate-agents"

echo -e "${GREEN}📊 Мониторинг Debate Agents${NC}"
echo -e "${BLUE}========================================${NC}"

# Статус подов
echo -e "${YELLOW}🔍 Статус подов:${NC}"
sudo k3s kubectl get pods -n $NAMESPACE

echo -e "\n${YELLOW}💾 Использование ресурсов:${NC}"
sudo k3s kubectl top pods -n $NAMESPACE 2>/dev/null || echo -e "${RED}Метрики не доступны${NC}"

echo -e "\n${YELLOW}🔌 Сервисы:${NC}"
sudo k3s kubectl get svc -n $NAMESPACE

echo -e "\n${YELLOW}🤖 Модели в Generator:${NC}"
sudo k3s kubectl exec -n $NAMESPACE deployment/generator -- ollama list 2>/dev/null || echo -e "${RED}Generator не доступен${NC}"

echo -e "\n${YELLOW}🔍 Модели в Critic:${NC}"
sudo k3s kubectl exec -n $NAMESPACE deployment/critic -- ollama list 2>/dev/null || echo -e "${RED}Critic не доступен${NC}"

echo -e "\n${YELLOW}📝 Последние логи Orchestrator:${NC}"
sudo k3s kubectl logs -n $NAMESPACE deployment/orchestrator --tail=10 2>/dev/null || echo -e "${RED}Orchestrator не доступен${NC}"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}Для непрерывного мониторинга используйте:${NC}"
echo -e "  sudo k3s kubectl logs -n $NAMESPACE deployment/orchestrator -f"
echo -e "  watch -n 2 sudo k3s kubectl get pods -n $NAMESPACE"
