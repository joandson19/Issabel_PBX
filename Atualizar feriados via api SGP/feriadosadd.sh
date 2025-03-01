#!/bin/bash

# Configurações
API_URL="https://URLSGP/api/model/feriado/?token=TOKENSGP&app=APPSGP"
MYSQL_USER="USERMYSQL"
MYSQL_PASS="PASSMYSQL"
MYSQL_DB="asterisk"
#GROUP_ID=4  # ID do grupo "FERIADOS (NAO ATENDE)"
CURRENT_YEAR=$(date +"%Y")  # Ano atual

# Função para executar comandos no MySQL
exec_mysql() {
    mysql -u $MYSQL_USER -p$MYSQL_PASS -D $MYSQL_DB -e "$1"
}

# Obter o GROUP_ID baseado na descrição " Lembre de usar a descrição exatamente como está no ISSABEL"
# No meu issabel está "FERIADOS (NAO ATENDE)" e serve de exemplo abaixo para alterar no seu.
GROUP_ID=$(exec_mysql "SELECT id FROM timegroups_groups WHERE description = 'FERIADOS (NAO ATENDE)';" | awk 'NR==2 {print $1}')

# Verificar se o GROUP_ID foi encontrado
if [[ -z "$GROUP_ID" ]]; then
    echo "Erro: Não foi possível encontrar o ID do grupo com a descrição fornecida."
    exit 1
fi

echo "Grupo encontrado, ID do grupo: $GROUP_ID"

# Função para converter mês numérico em abreviação
get_month_abbreviation() {
    local month=$1
    case $month in
        01) echo "jan";;
        02) echo "feb";;
        03) echo "mar";;
        04) echo "apr";;
        05) echo "may";;
        06) echo "jun";;
        07) echo "jul";;
        08) echo "aug";;
        09) echo "sep";;
        10) echo "oct";;
        11) echo "nov";;
        12) echo "dec";;
        *) echo "";;
    esac
}

# Função para limpar os feriados existentes no grupo
clear_holidays() {
    echo "Limpando todos os feriados para o grupo ID: $GROUP_ID"
    exec_mysql "DELETE FROM timegroups_details WHERE timegroupid = $GROUP_ID;"

    if [[ $? -eq 0 ]]; then
        echo "Feriados existentes removidos com sucesso."
    else
        echo "Erro ao limpar feriados existentes."
        exit 1
    fi
}

# Função para inserir um feriado
insert_holiday() {
    local date=$1
    local description=$2

    # Extrair dia e mês da data
    day=$(date -d "$date" +"%d")
    month=$(date -d "$date" +"%m")

    # Converter mês numérico em abreviação
    month_abbrev=$(get_month_abbreviation "$month")

    # Montar o campo "time" no formato correto
    # Pode alterar para o horário que usar em sua operação, só atente-se ao formato correto.
    time_field="08:00-17:59|*|$day|$month_abbrev"

    # Inserir o feriado na tabela timegroups_details
    exec_mysql "INSERT INTO timegroups_details (name, timegroupid, time) VALUES ('$description', $GROUP_ID, '$time_field');"

    if [[ $? -eq 0 ]]; then
        echo "Feriado inserido com sucesso: $date - $description"
    else
        echo "Erro ao inserir feriado: $date - $description"
        exit 1
    fi
}

# Obter dados da API
response=$(curl -s -X GET "$API_URL" -H "Content-Type: application/x-www-form-urlencoded")

# Verificar se a resposta da API é válida
if [[ -z "$response" ]]; then
    echo "Erro: Não foi possível obter dados da API."
    exit 1
fi

# Limpar os feriados existentes antes de adicionar os novos
clear_holidays

# Processar JSON e inserir feriados
echo "$response" | jq -c '.[]' | while read -r holiday; do
    date=$(echo "$holiday" | jq -r '.data')
    description=$(echo "$holiday" | jq -r '.descricao')

    # Extrair o ano da data do feriado
    holiday_year=$(date -d "$date" +"%Y")

    # Verificar se o feriado é do ano atual
    if [[ "$holiday_year" == "$CURRENT_YEAR" ]]; then
        # Inserir feriado no Issabel
        insert_holiday "$date" "$description"
    else
        echo "Feriado ignorado (não é do ano atual): $date - $description"
    fi
done

# Aplicar as alterações no Issabel e recarregar o Asterisk
/usr/share/issabel/privileged/applychanges

echo "Alterações aplicadas e Asterisk recarregado com sucesso."
