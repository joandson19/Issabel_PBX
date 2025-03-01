# Atualizar feriados no Issabel4 usando api do SGP

## A ideia aqui é que você cadastre os fériados no seu SGP e o Issabel4 possa consumir isso via API.

### Baixe o script
```
wget https://raw.githubusercontent.com/joandson19/Issabel_PBX/refs/heads/main/Atualizar%20feriados%20via%20api%20SGP/feriadosadd.sh -O /opt/feriadosadd.sh
```

### Abra o arquivo /opt/feriadosadd.sh e edite os campos necessários.
```
nano /opt/feriadosadd.sh
```

### Se você alterou corretamente, é hora de dar permissões.
```
chmod +x /opt/feriadosadd.sh
```

### Agora vamos adicionar na crond do SO para executar automaticamente.
### No meu exemplo abaixo estou deixando mensal, mas fica a seu critério.
```cmd
echo "0 0 1 * * root /opt/feriadosadd.sh" >> /etc/crontab
```
