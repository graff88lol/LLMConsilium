#!/usr/bin/env fish

set GREEN (set_color green)
set YELLOW (set_color yellow)
set NC (set_color normal)

echo -e "$YELLOW🛑 Остановка всех port-forward процессов...$NC"

# Убиваем все kubectl port-forward процессы
sudo pkill -f "kubectl port-forward" 2>/dev/null

# Дополнительно убиваем процессы на конкретных портах
for PORT in 8080 8081
    set PIDS (sudo lsof -t -i :$PORT 2>/dev/null)
    if test -n "$PIDS"
        for PID in $PIDS
            echo -e "$YELLOW  Убиваем процесс $PID на порту $PORT$NC"
            sudo kill -9 $PID 2>/dev/null
        end
    end
end

echo -e "$GREEN✅ Все port-forward процессы остановлены$NC"
