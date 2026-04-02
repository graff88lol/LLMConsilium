#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set RED (set_color red)
set NC (set_color normal)

set NAMESPACE "debate-agents"

echo -e "$RED🗑️  Удаление веб-интерфейса Debate Agents$NC"

sudo k3s kubectl delete deployment web-ui -n $NAMESPACE 2>/dev/null
sudo k3s kubectl delete service web-ui-svc -n $NAMESPACE 2>/dev/null

echo -e "$GREEN✅ Веб-интерфейс удален$NC"
