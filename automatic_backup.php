#!/usr/bin/php
<?php
load_default_timezone();

// Configurações do backup
$sBackupFilename = 'issabelbackup-'.date('YmdHis').'-ab.tar';
$sBackupDir = '/var/www/backup';
$BackupComponents = 'as_db,as_config_files,as_sounds,as_mohmp3,as_dahdi,email,fax,endpoint,otros,otros_new';

// Executa o backup
$retval = NULL;
system('/usr/share/issabel/privileged/backupengine --backup --backupfile '.
    $sBackupFilename.' --tmpdir '.$sBackupDir.' --components='.$BackupComponents.' 2>/dev/null || true', $retval);

if ($retval === 0) {
    // Caminho do arquivo gerado
    $filePath = $sBackupDir . '/' . $sBackupFilename;

    // Verifica se o arquivo foi realmente criado
    if (file_exists($filePath) && is_readable($filePath)) {
        // Configurações do Telegram
        $telegramBotToken = "TOKEN"; // Altere para seu token
        $chatId = "CHAT_ID"; // Altere para o id do bot

        echo "Backup gerado com sucesso! Enviando para o Telegram...\n";
        sendBackupToTelegram($telegramBotToken, $chatId, $filePath);
    } else {
        echo "Erro: O arquivo de backup não foi encontrado ou não pode ser lido!\n";
    }
} else {
    echo "Erro ao gerar o backup!\n";
}

exit($retval);

function sendBackupToTelegram($botToken, $chatId, $filePath)
{
    $url = "https://api.telegram.org/bot$botToken/sendDocument";

    // Compatível com PHP 5.4 (usa @ para arquivos)
    $postFields = [
        'chat_id'   => $chatId,
        'document'  => '@' . $filePath, // Formato antigo para PHP 5.4
        'caption'   => "Backup do Issabel gerado em " . date('d/m/Y H:i:s')
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_HTTPHEADER, ["Content-Type:multipart/form-data"]);
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);

    $result = curl_exec($ch);

    if (curl_errno($ch)) {
        echo "Erro no cURL: " . curl_error($ch) . "\n";
    } else {
        echo "Resposta do Telegram: $result\n";
    }

    curl_close($ch);
}

function load_default_timezone()
{
    $sDefaultTimezone = @date_default_timezone_get();
    if ($sDefaultTimezone == 'UTC') {
        $sDefaultTimezone = 'America/Bahia';
        $regs = NULL;
        if (is_link("/etc/localtime") && preg_match("|/usr/share/zoneinfo/(.+)|", readlink("/etc/localtime"), $regs)) {
            $sDefaultTimezone = $regs[1];
        } elseif (file_exists('/etc/sysconfig/clock')) {
            foreach (file('/etc/sysconfig/clock') as $s) {
                $regs = NULL;
                if (preg_match('/^ZONE\s*=\s*"(.+)"/', $s, $regs)) {
                    $sDefaultTimezone = $regs[1];
                }
            }
        }
    }
    date_default_timezone_set($sDefaultTimezone);
}
?>
