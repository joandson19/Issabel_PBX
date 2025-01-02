nano /opt/scripts/voipbl.sh

```bash
#!/bin/bash

URL="https://voipbl.org/update/"

set -e
echo "Baixando lista atualizada no voipbl update"
curl -s $URL -o /tmp/voipbl.txt

echo "Carregando lista..."

# Verifique se o conjunto de regras existe e crie um, se necessário
if /usr/sbin/ipset list voipbl > /dev/null 2>&1; then
  echo "Limpando lista antiga no ipset!"
  ipset flush voipbl
else
  echo "Criando lista voipbl no ipset!" 
  ipset -N voipbl iphash
fi

  
# Verifique se há regra no iptables
if ! $(/sbin/iptables -I INPUT 1 -m limit --limit 5/min -m set --match-set voipbl src -j LOG --log-prefix "IPTables-VoIPBL-Dropped: " --log-level 4 > /dev/null 2>&1); then
  /sbin/iptables -I INPUT 1 -m set --match-set voipbl src -j LOG --log-prefix "IPTables-VoIPBL-Dropped: " --log-level 4
fi

if ! $(/sbin/iptables -w --check INPUT -m set --match-set voipbl src -j DROP > /dev/null 2>&1); then
  /sbin/iptables -I INPUT 2 -m set --match-set voipbl src -j DROP
fi

 
# Criar cadeia temporária
ipset destroy voipbl_temp > /dev/null 2>&1 || true
ipset -N voipbl_temp iphash hashsize 131072 maxelem 260000
 
cat /tmp/voipbl.txt |\
  awk '{print "if ! [[ \""$1"\" =~ ^#$|^0.0.0.0 ]]; then /usr/sbin/ipset -A voipbl_temp \""$1"\" ; fi;"}' | sh
 
ipset swap voipbl_temp voipbl
ipset destroy voipbl_temp || true
 
echo "Concluído com sucesso"
echo "Executado em: $(date)" >> /tmp/voipbl_update.log
```
