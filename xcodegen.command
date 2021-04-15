# начинаем замер времени скрипта
START_TIME=$(date +%s)
# найдем директорию, в которой лежит файл исполняемого скрипта
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
# перейдем в нее
cd "$DIR"
# Проверка установки xcodegen
if hash xcodegen 2>/dev/null; 
then
    echo xcodegen is installed
else    
    echo xcodegen is not installed, run setup.command
fi
# генерируем проект
xcodegen generate
# завершаем замер времени скрипта
END_TIME=$(date +%s)
ELAPSED_TIME=$(( $END_TIME - $START_TIME ))
echo "Xcodegen worked for \033[1;32m$ELAPSED_TIME\033[0m seconds"