# Виды

## Соглашение о структуре вида

`/assets` — ресурсы вида

`/templates` — шаблоны вида


 
### Структура шаблонов вида

#### Примеси
`/templates/mixins.jade` — общие примеси, используемые во всех шаблонах



#### Модули

`/templates/[A-Z][A-Za-z]/` — директория модуля

`/templates/[A-Z][A-Za-z]/layout.jade` — раскладка модуля



#### Модуль модуля (приложение)

`/templates/[A-Z][A-Za-z]/[a-z]/` — модуль модуля (приложение)

`/templates/[A-Z][A-Za-z]/[a-z]/index.jade` — шаблон приложения (точка входа в приложение)

`/templates/[A-Z][A-Za-z]/[a-z]/layout.jade` — раскладка приложения (наследует раскладку модуля)

`/templates/[A-Z][A-Za-z]/[a-z]/includes/` — скрипты приложения

`/templates/[A-Z][A-Za-z]/[a-z]/partials/` — части шаблонов
