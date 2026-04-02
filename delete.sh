#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

NAMESPACE="debate-agents"

echo -e "${RED}🗑️  Удаление Debate Agents из k3s${NC}"

# Удаляем port-forward
echo -e "${YELLOW}🔌 Остановка port-forward...${NC}"
pkill -f "kubectl port-forward.*orchestrator-svc" 2>/dev/null
echo -e "${GREEN}✅ Port-forward остановлен${NC}"

# Удаляем все деплойменты
echo -e "${YELLOW}📦 Удаление деплойментов...${NC}"
sudo k3s kubectl delete deployment orchestrator -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete deployment generator -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete deployment critic -n $NAMESPACE 2>/dev/null

# Удаляем сервисы
echo -e "${YELLOW}🔧 Удаление сервисов...${NC}"
sudo k3s kubectl delete svc orchestrator-svc -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete svc generator-svc -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete svc critic-svc -n $NAMESPACE 2>/dev/null

# Опционально: удалить namespace (раскомментировать если нужно полностью очистить)
read -p "Удалить namespace $NAMESPACE? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🗑️  Удаление namespace...${NC}"
    sudo k3s kubectl delete namespace $NAMESPACE 2>/dev/null
    echo -e "${GREEN}✅ Namespace удален${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Все ресурсы удалены!${NC}"
echo -e "${GREEN}========================================${NC}"
