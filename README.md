[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Этот проект распространяется под лицензией MIT.  
Вы можете свободно использовать, модифицировать и распространять скрипт,  
при условии сохранения уведомления об авторских правах и текста лицензии.

# Zimbra LDAP Account Export Script

A bash script for exporting real Zimbra mail accounts from LDAP across all domains into a CSV file.

---

## 🇷🇺 Описание (Русский)

Скрипт предназначен для автоматической выгрузки всех реальных почтовых ящиков Zimbra из LDAP по всем доменам, зарегистрированным на сервере.

Результат сохраняется в CSV-файл:

/opt/zimbra/accounts_with_date.csv

### Формат CSV

Email;Дата создания;Статус;Notes;Последний вход;DisplayName

Пример строки:

admin@domain.com;20161007172137Z;active;never_disable;20220614184815.765Z;Administrator

---

## Возможности

- Обход всех доменов Zimbra (zmprov gad)
- Подключение к LDAP от имени пользователя zimbra
- Автоматическое получение LDAP-пароля из zmlocalconfig
- Экспорт только реальных учётных записей (не alias)
- Корректная обработка многострочных zimbraNotes
- Поддержка ручного запуска и cron

---

## Используемые LDAP-атрибуты

- zimbraMailDeliveryAddress — основной email
- zimbraCreateTimestamp — дата создания
- zimbraAccountStatus — статус учётной записи
- zimbraNotes — заметки
- zimbraLastLogonTimestamp — последний вход
- displayName — отображаемое имя

---

## Требования

- Zimbra 8.8.15+
- Запуск от имени пользователя zimbra
- Bash, awk, ldapsearch (входят в поставку Zimbra)

---

## Установка и запуск

Сделать скрипт исполняемым:

chmod +x /opt/zimbra/scripts/check_ldap.sh

Ручной запуск:

sudo -u zimbra /opt/zimbra/scripts/check_ldap.sh

---

## Запуск через cron

Открыть crontab пользователя zimbra:

crontab -u zimbra -e

Пример ежедневного запуска в 03:00:

0 3 * * * /opt/zimbra/scripts/check_ldap.sh >> /opt/zimbra/logs/check_ldap_cron.log 2>&1

---

## Безопасность

LDAP-пароль не хранится в скрипте.
Он автоматически получается командой:

zmlocalconfig -s zimbra_ldap_password

Скрипт может выполняться только пользователем zimbra.

---

## 🇬🇧 Description (English)

This script exports all real Zimbra mail accounts from LDAP across all configured domains into a CSV file.

Output file:

/opt/zimbra/accounts_with_date.csv

### CSV format

Email;Creation Date;Status;Notes;Last Login;DisplayName

Example:

admin@domain.com;20161007172137Z;active;never_disable;20220614184815.765Z;Administrator

---

## Features

- Iterates through all Zimbra domains (zmprov gad)
- Connects to LDAP as the zimbra system user
- Automatically retrieves LDAP password from Zimbra config
- Exports real accounts only (no aliases)
- Properly handles multi-line zimbraNotes
- Suitable for manual and cron execution

---

## Requirements

- Zimbra 8.8.15+
- Script must run as user zimbra
- Bash, awk, ldapsearch available

