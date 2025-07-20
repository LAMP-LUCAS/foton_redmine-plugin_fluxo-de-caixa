# Plugin foton Fluxo de Caixa - Documentação Técnica

## Visão Geral

O Plugin foton Fluxo de Caixa é uma solução avançada para gerenciamento financeiro integrado ao Redmine. Ele oferece um conjunto completo de funcionalidades para controle de receitas e despesas, com foco em usabilidade e eficiência.

### Principais Funcionalidades

1. **Gestão de Lançamentos**
   - Registro de receitas e despesas
   - Categorização e organização por projetos
   - Controle de status e autoria
   - Sistema avançado de filtros estilo Notion

2. **Interface Moderna**
   - Design responsivo e intuitivo
   - Modal de filtros com Select2
   - Tabelas dinâmicas e interativas

3. **Importação e Exportação**
   - Suporte a arquivos CSV
   - Template padronizado
   - Validação de dados

4. **Configurações Flexíveis**
   - Personalização de colunas
   - Controle de acesso granular
   - Internacionalização completa

## Estrutura do Projeto

``` directory
.
├── app
│   ├── assets
│   │   ├── javascripts
│   │   │   ├── cash_flow_filters.js
│   │   │   └── cash_flow.js
│   │   └── stylesheets
│   │       ├── cash_flow_filters.css
│   │       └── cash_flow_pro.css
│   ├── controllers
│   │   ├── admin
│   │   │   └── cash_flow_settings_controller.rb
│   │   ├── cash_flow_entries_controller.rb
│   │   └── cash_flow_settings_controller.rb
│   ├── helpers
│   │   └── cash_flow_entries_helper.rb
│   ├── models
│   │   └── cash_flow_entry.rb
│   └── views
│       ├── cash_flow_entries
│       │   ├── _filter_header.html.erb
│       │   ├── _form.html.erb
│       │   ├── _head_assets.html.erb
│       │   ├── edit.html.erb
│       │   ├── import_form.html.erb
│       │   ├── index.html.erb
│       │   └── new.html.erb
│       ├── cash_flow_settings
│       │   ├── _cash_flow_pro_settings.html.erb
│       │   └── index.html.erb
│       └── settings
│           └── _cash_flow_pro_settings.html.erb
├── config
│   ├── locales
│   │   ├── en.yml
│   │   └── pt-BR.yml
│   └── routes.rb
├── db
│   └── migrate
│       ├── 20230101000000_create_cash_flow_entries.rb
│       └── 20250717000000_add_issue_status_author_to_cash_flow_entries.rb
├── lib
│   ├── redmine_cash_flow_pro
│   │   └── hooks.rb
│   └── redmine_cash_flow_pro.rb
├── .config
├── estrutura_projeto.md
├── Gemfile
├── import_template.csv
├── init.rb
├── install_plugin.py
├── README.md
├── remove_plugin.py
└── update_plugin.py
```

## Arquitetura e Organização

O projeto segue uma arquitetura MVC (Model-View-Controller) robusta, alinhada com as melhores práticas do Rails e padrões do Redmine. A estrutura foi desenhada para maximizar a manutenibilidade e extensibilidade.

### Padrões de Projeto Utilizados

1. **MVC (Model-View-Controller)**
   - Separação clara de responsabilidades
   - Código modular e testável
   - Facilidade de manutenção

2. **Asset Pipeline**
   - Gerenciamento eficiente de recursos
   - Minificação automática
   - Versionamento de assets

3. **Hooks System**
   - Integração não-intrusiva com o Redmine
   - Carregamento condicional de recursos
   - Extensibilidade via hooks

## Detalhamento da Estrutura

### Diretório `app/`
Principal diretório da aplicação, seguindo a convenção Rails:

- **controllers/**
  - `cash_flow_entries_controller.rb`: Gerencia o CRUD de lançamentos financeiros
    - Implementa filtros dinâmicos
    - Gerencia importação/exportação CSV
    - Controla permissões de acesso
  - `cash_flow_settings_controller.rb`: Interface administrativa
  - `admin/cash_flow_settings_controller.rb`: Configurações avançadas

- **helpers/**
  - `cash_flow_entries_helper.rb`: Métodos auxiliares para views
    - Formatação de valores monetários
    - Helpers para filtros e categorias
    - Funções de formatação de data

- **models/**
  - `cash_flow_entry.rb`: Modelo principal
    - Validações de dados
    - Relações com projetos e usuários
    - Scopes para filtros

- **views/**
  - **cash_flow_entries/**
    - `index.html.erb`: Lista principal com filtros avançados
    - `_form.html.erb`: Formulário compartilhado
    - `new.html.erb`, `edit.html.erb`: CRUD
    - `import_form.html.erb`: Interface de importação
  - **cash_flow_settings/**: Views administrativas
  - **settings/**: Configurações do plugin

### Diretório `assets/`
Recursos estáticos e bibliotecas:

- **javascripts/**
  - `cash_flow_filters.js`: Implementação do modal de filtros
  - `lib/select2.min.js`: Biblioteca Select2 para selects avançados

- **stylesheets/**
  - `cash_flow_filters.css`: Estilos dos filtros e modal
  - `lib/select2.min.css`: Estilos do Select2

### Diretório `config/`
Configurações e internacionalização:

- `routes.rb`: Definição de rotas customizadas
- **locales/**
  - `pt-BR.yml`, `en.yml`: Traduções

### Diretório `db/migrate/`
Migrações do banco de dados:

- `20230101000000_create_cash_flow_entries.rb`: Estrutura inicial
- `20250717000000_add_issue_status_author.rb`: Campos adicionais

### Diretório `lib/`
Código de suporte e extensões:

- **redmine_cash_flow_pro/**
  - `hooks.rb`: Hooks para integração com Redmine

### Arquivos na Raiz

- **Scripts de Automação**
  - `install_plugin.py`: Instalação automatizada
  - `update_plugin.py`: Atualização do plugin
  - `remove_plugin.py`: Desinstalação segura
  - `.config`: Configurações dos scripts

- **Arquivos de Configuração**
  - `Gemfile`: Dependências do plugin
  - `init.rb`: Inicialização e configuração
  - `import_template.csv`: Modelo para importação

- **Documentação**
  - `README.md`: Guia principal
  - `estrutura_projeto.md`: Documentação técnica

## Práticas de Desenvolvimento

### Convenções de Código

- Ruby: seguimos o guia de estilo da comunidade Ruby
- JavaScript: ESLint com configuração padrão
- CSS: BEM (Block Element Modifier)

### Fluxo de Desenvolvimento

1. **Instalação**
   ```bash
   python install_plugin.py
   ```

2. **Atualização**
   ```bash
   python update_plugin.py
   ```

3. **Remoção**
   ```bash
   python remove_plugin.py
   ```

### Manutenção

- Assets são compilados automaticamente
- Migrações são versionadas
- Hooks garantem carregamento eficiente

## Considerações de Segurança

1. **Permissões**
   - Controle granular por papel
   - Validação em múltiplas camadas
   - Proteção contra CSRF

2. **Validação de Dados**
   - Sanitização de inputs
   - Validações no modelo
   - Controles de acesso

3. **Auditoria**
   - Registro de alterações
   - Rastreamento de usuários
   - Logs de operações

---

Este plugin representa uma solução robusta para gestão financeira no Redmine, combinando usabilidade moderna com práticas sólidas de desenvolvimento.
