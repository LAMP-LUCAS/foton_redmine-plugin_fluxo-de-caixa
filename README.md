# foton Fluxo de Caixa

Plugin de fluxo de caixa para Redmine desenvolvido pela comunidade FOTON.

## Informações do Plugin

- **Nome:** foton Fluxo de Caixa
- **Autor:** LAMP/foton
- **Descrição:** Plugin de fluxo de caixa para Redmine desenvolvido pela comunidade FOTON
- **Versão:** 0.0.1

## Funcionalidades

- **Lançamentos de Fluxo de Caixa:** Registre receitas e despesas com data, descrição, valor (float), tipo, categoria e projeto.
- **Visualização Tabular:** Tabela paginada e filtrável por período, tipo, categoria e projeto.
- **Somatórios Automáticos:** Totais de receitas, despesas e saldo geral.
- **Importação/Exportação CSV:** Importe lançamentos a partir de um arquivo CSV e exporte os dados filtrados.
- **Permissões Avançadas:** Controle de acesso por papel, admin sempre tem acesso.
- **Configuração Dinâmica:** Colunas, projetos customizados, usuários permanentes e categorias customizadas.
- **Interface Responsiva:** Campos de data com seletor, valor com casas decimais, traduções pt-BR e en.

## Requisitos

- Redmine 5.0 ou superior
- Ruby 2.7 ou superior
- PostgreSQL, MySQL ou SQLite3
- Rails 6.1 ou superior

## Instalação

### 1. Download do Plugin

```bash
cd /caminho/para/redmine/plugins
git clone <URL_DO_REPOSITORIO>
```

### 2. Migração do Banco de Dados

```bash
docker compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

### 3. Publicação dos Assets

```bash
docker compose exec redmine bundle exec rake redmine:plugins:assets RAILS_ENV=production
```

### 4. Reinicie o Redmine

Se estiver usando Docker Compose:

```bash
docker compose restart redmine
```

## Configuração

- Ative o módulo no projeto (opcional).
- Configure permissões em Administração > Papéis e Permissões.
- Ajuste colunas, projetos e usuários permanentes em Administração > Configurações > Fluxo de Caixa.

## Uso

- Acesse o menu "Fluxo de Caixa" no topo ou no projeto.
- Use "Novo Lançamento" para adicionar receitas/despesas.
- Utilize filtros para refinar a visualização.
- Importe lançamentos via CSV (link "Importar CSV").
- Exporte lançamentos filtrados via CSV (link "Exportar CSV").
- Gerencie lançamentos com os botões de editar/excluir.

## Template de Importação

O template CSV está disponível em:
`import_template.csv` na raiz do plugin.

## Suporte

Desenvolvido e mantido pela comunidade FOTON.

---