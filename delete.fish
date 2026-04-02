#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$RED🗑️  Удаление Debate Agents из k3s$NC"

# Удаляем port-forward
echo -e "$YELLOW🔌 Остановка port-forward...$NC"
pkill -f "kubectl port-forward.*orchestrator-svc" 2>/dev/null
echo -e "$GREEN✅ Port-forward остановлен$NC"

# Удаляем все деплойменты
echo -e "$YELLOW📦 Удаление деплойментов...$NC"
sudo k3s kubectl delete deployment orchestrator -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete deployment generator -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete deployment critic -n $NAMESPACE 2>/dev/null

# Удаляем сервисы
echo -e "$YELLOW🔧 Удаление сервисов...$NC"
sudo k3s kubectl delete service orchestrator-svc -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete service generator-svc -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete service critic-svc -n $NAMESPACE 2>/dev/null

# Опционально: удалить namespace
echo -e -n "$YELLOW🗑️  Удалить namespace $NAMESPACE? (y/N): $NC"
read -l answer
if test "$answer" = "y" -o "$answer" = "Y"
    echo -e "$YELLOWУдаление namespace...$NC"
    sudo k3s kubectl delete namespace $NAMESPACE 2>/dev/null
    echo -e "$GREEN✅ Namespace удален$NC"
end

echo -e "\n$GREEN========================================$NC"
echo -e "$GREEN✅ Все ресурсы удалены!$NC"
echo -e "$GREEN========================================$NC"
