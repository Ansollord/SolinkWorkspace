# Solink Workspace Command Center

Стартовая онлайн-панель Solink Workspace.

Это первый статический прототип главного пульта проектов. Он показывает активные проекты, статус, momentum, следующие шаги и ссылки на проектные карточки.

## Публикация на GitHub Pages

1. Создать новый репозиторий на GitHub, например `solink-workspace`.
2. Загрузить в корень репозитория файлы из этой папки.
3. Открыть `Settings` -> `Pages`.
4. В `Build and deployment` выбрать:
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/root`
5. Сохранить.

После этого GitHub выдаст публичный адрес страницы.

## Текущий состав

- `index.html` - главная страница Command Center.
- `.nojekyll` - отключает обработку Jekyll на GitHub Pages.

## Следующий шаг

Вынести данные проектов в отдельный `projects.json`, чтобы страница обновлялась без ручного редактирования HTML.

