#!/bin/bash
#
# Copyright (c) 2025 Ivan V. Belikov
#
# Лицензия: MIT License (см. файл LICENSE)
# https://opensource.org/licenses/MIT
# ------------------------------------------------------------
# Задаём окружение для cron
export PATH="/opt/zimbra/common/bin:/opt/zimbra/bin:/usr/sbin:/usr/bin:/bin:/sbin"
umask 0022

# Параметры подключения 
LDAP_HOST="ldap://127.0.0.1:389" # ← если потребуется необходимо отредактировать под свой IP адрес 
LDAP_BIND_DN="uid=zimbra,cn=admins,cn=zimbra"
LDAP_PASS="$(zmlocalconfig -s zimbra_ldap_password | awk '{print $2}')"  # ← авто-подставляем пароль


# Целевой файл
CSV_EXPORT="/opt/zimbra/accounts_with_date.csv"
DEBUG_LOG="/opt/zimbra/logs/ldap_debug.log"

# Заголовок
echo "Email;Дата создания;Статус;Notes;Последний вход;DisplayName" > "$CSV_EXPORT"
echo "[$(date)] Старт LDAP-сканирования по всем доменам" >> "$DEBUG_LOG"

# Получаем список всех доменов
DOMAINS=$(zmprov gad)

for DOMAIN in $DOMAINS; do
  LDAP_BASE_DN="dc=$(echo "$DOMAIN" | sed 's/\./,dc=/g')"
  echo -e "\n[$(date)] Обработка домена: $DOMAIN ($LDAP_BASE_DN)" | tee -a "$DEBUG_LOG"

  /opt/zimbra/common/bin/ldapsearch -x \
    -H "$LDAP_HOST" \
    -D "$LDAP_BIND_DN" \
    -w "$LDAP_PASS" \
    -b "$LDAP_BASE_DN" \
    "(objectClass=zimbraAccount)" \
    zimbraMailDeliveryAddress zimbraCreateTimestamp zimbraAccountStatus zimbraNotes zimbraLastLogonTimestamp displayName 2>>"$DEBUG_LOG" | \
  awk '
  BEGIN {
    email=""; created=""; status=""; notes=""; last=""; name=""; in_notes=0
  }
  /^zimbraMailDeliveryAddress: / { email=$2; in_notes=0 }
  /^zimbraCreateTimestamp: /     { created=$2; in_notes=0 }
  /^zimbraAccountStatus: /       { status=$2; in_notes=0 }
  /^zimbraLastLogonTimestamp: /  { last=$2; in_notes=0 }
  /^displayName: /               { name=substr($0, index($0,$2)); in_notes=0 }
  /^zimbraNotes: / {
    sub(/^zimbraNotes: /, "", $0)
    notes=$0
    in_notes=1
    next
  }
  /^[a-zA-Z0-9-]+: / { in_notes=0 }
  /^ / && in_notes {
    sub(/^ /, "")
    notes = notes "\n" $0
  }
  /^$/ {
    if (email != "") {
      gsub(/"/, "\"\"", notes)
      gsub(/\n/, " ", notes)
      printf("%s;%s;%s;%s;%s;%s\n", email, created, status, notes, last, name)
      email=created=status=notes=last=name=""; in_notes=0
    }
  }
  ' >> "$CSV_EXPORT"
done

echo -e "\n[$(date)] Готово. Данные сохранены в $CSV_EXPORT" | tee -a "$DEBUG_LOG"
