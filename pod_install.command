# найдем директорию, в которой лежит файл исполняемого скрипта
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 

# перейдем в нее
cd "$DIR"

# Проверка установки Bundler
if hash bundler 2>/dev/null; 
then
    echo Bundler is installed
else    
    echo Bundler is not installed, run setup.command
    exit 1
fi

# создаем generated файлы
function mkdir_touch {
  mkdir -p "$(dirname "$1")"
  command touch "$1"
}

mkdir_touch Resources/R.generated.swift

# генерируем проект
sh xcodegen.command

# подгрузим поды
bundle exec pod install