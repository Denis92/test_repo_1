# найдем директорию, в которой лежит файл исполняемого срипта
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 

# перейдем в нее
cd "$DIR"

# обновим поды
bundle exec pod update