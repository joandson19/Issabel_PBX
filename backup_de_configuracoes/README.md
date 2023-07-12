Neste script, você pode adicionar quantos diretórios quiser à matriz SOURCE_DIRS, fornecendo os caminhos completos para cada diretório que deseja fazer backup. Certifique-se de ajustar as variáveis TELEGRAM_API_KEY, TELEGRAM_CHAT_ID e BACKUP_DIR de acordo com suas informações pessoais. Lembre-se também de conceder as permissões adequadas ao script antes de executá-lo.
Certifique-se de fornecer as permissões adequadas ao script antes de executá-lo usando o comando:
* chmod +x script_backup.sh.

No meu caso acima estou usando como exemplo as pastas as quais necessito fazer backup, mas use ao seu modo.
Após testar e assegurar de que o script está ok, você pode por uma rotina de backup na cron e assim ter seus backups diários com o exemplo abaixo.

comando abaixo entra no editor da crontab
* crontab -e

incluar o conteudo abaixo na ultima linha
* 00 20 * * * /usr/bin/bash /usr/bin/telegram

No exemplo acima eu agendei para todos os dias as 20 horas.
