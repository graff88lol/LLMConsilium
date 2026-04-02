#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

NAMESPACE="debate-agents"

echo -e "${GREEN}🚀 Начинаем деплой Debate Agents в k3s${NC}"

# Создание namespace если не существует
echo -e "${YELLOW}📦 Создание namespace...${NC}"
sudo k3s kubectl create namespace $NAMESPACE 2>/dev/null || echo -e "${YELLOW}Namespace уже существует${NC}"

# Применяем generator
echo -e "${YELLOW}🤖 Деплой Generator...${NC}"
sudo k3s kubectl apply -f generator-fixed.yaml

# Применяем critic
echo -e "${YELLOW}🔍 Деплой Critic...${NC}"
sudo k3s kubectl apply -f critic-fixed.yaml

# Ждем готовности generator
echo -e "${YELLOW}⏳ Ожидание готовности Generator...${NC}"
while [[ $(sudo k3s kubectl get pods -n $NAMESPACE -l app=generator -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    sleep 2
    echo -n "."
done
echo -e "\n${GREEN}✅ Generator готов${NC}"

# Ждем готовности critic
echo -e "${YELLOW}⏳ Ожидание готовности Critic...${NC}"
while [[ $(sudo k3s kubectl get pods -n $NAMESPACE -l app=critic -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    sleep 2
    echo -n "."
done
echo -e "\n${GREEN}✅ Critic готов${NC}"

# Применяем orchestrator
echo -e "${YELLOW}🎼 Деплой Orchestrator...${NC}"
sudo k3s kubectl apply -f orchestrator-fixed.yaml

# Ждем готовности orchestrator
echo -e "${YELLOW}⏳ Ожидание готовности Orchestrator...${NC}"
while [[ $(sudo k3s kubectl get pods -n $NAMESPACE -l app=orchestrator -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    sleep 2
    echo -n "."
done
echo -e "\n${GREEN}✅ Orchestrator готов${NC}"

# Проверяем скачивание моделей
echo -e "${YELLOW}📥 Проверка скачивания моделей...${NC}"
echo -e "${GREEN}Модели в Generator:${NC}"
sudo k3s kubectl exec -n $NAMESPACE deployment/generator -- ollama list 2>/dev/null || echo -e "${RED}Generator не готов${NC}"
echo ""
echo -e "${GREEN}Модели в Critic:${NC}"
sudo k3s kubectl exec -n $NAMESPACE deployment/critic -- ollama list 2>/dev/null || echo -e "${RED}Critic не готов${NC}"

# Запускаем port-forward
echo -e "${YELLOW}🔌 Настройка port-forward...${NC}"
pkill -f "kubectl port-forward.*orchestrator-svc" 2>/dev/null
sudo k3s kubectl port-forward -n $NAMESPACE svc/orchestrator-svc 8080:8080 > /dev/null 2>&1 &
echo -e "${GREEN}✅ Port-forward запущен на :8080${NC}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Деплой успешно завершен!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}API доступен:${NC} http://localhost:8080"
echo -e "${YELLOW}Health check:${NC} curl http://localhost:8080/health"
echo -e "${YELLOW}Пример запроса:${NC} ./send-request.sh \"напиши hello world\" 2"
echo -e "${GREEN}========================================${NC}"
