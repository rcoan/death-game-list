# Deploy no Render.com

Este guia explica como fazer deploy da aplicação Deaths Game no Render.com.

## Pré-requisitos

1. Conta no Render.com (https://render.com)
2. Repositório Git configurado (já configurado: `git@github.com:rcoan/death-game-list.git`)

## Passos para Deploy

### 1. Criar PostgreSQL Database no Render

1. Acesse o dashboard do Render
2. Clique em "New +" → "PostgreSQL"
3. Configure:
   - **Name**: `deaths-game-db`
   - **Database**: `deaths_game_production`
   - **User**: `deaths_game`
   - **Plan**: Starter ($6/mês) ou superior conforme necessidade
4. Anote a **Internal Database URL** e **External Database URL**

### 2. Criar Web Service

1. No dashboard do Render, clique em "New +" → "Web Service"
2. Conecte seu repositório GitHub (`rcoan/death-game-list`)
3. Configure o serviço:
   - **Name**: `deaths-game`
   - **Environment**: `Ruby`
   - **Region**: Escolha a região mais próxima
   - **Branch**: `main`
   - **Root Directory**: (deixe vazio)
   - **Build Command**: `./bin/render-build.sh`
   - **Start Command**: `bundle exec puma -C config/puma.rb`
   - **Plan**: Starter ($7/mês) ou superior

### 3. Configurar Variáveis de Ambiente

No painel do Web Service, vá em "Environment" e adicione:

- **RAILS_ENV**: `production`
- **RAILS_MASTER_KEY**: Copie o conteúdo de `config/master.key` (ou gere um novo com `rails credentials:edit`)
- **DATABASE_URL**: Use a **Internal Database URL** do PostgreSQL criado
- **SECRET_KEY_BASE**: Gere com `rails secret` (ou deixe o Render gerar automaticamente)

### 4. Conectar Database ao Web Service

1. No painel do Web Service, vá em "Connections"
2. Clique em "Connect Database"
3. Selecione o PostgreSQL database criado (`deaths-game-db`)
4. O Render automaticamente adicionará a variável `DATABASE_URL`

### 5. Deploy Automático

Após configurar tudo:
1. O Render fará o deploy automaticamente quando você fizer push para `main`
2. Ou clique em "Manual Deploy" → "Deploy latest commit"

## Usando render.yaml (Alternativa)

Se preferir usar o arquivo `render.yaml` para configurar tudo via código:

1. No dashboard do Render, clique em "New +" → "Blueprint"
2. Conecte o repositório
3. O Render detectará automaticamente o `render.yaml` e criará os serviços

**Nota**: Você ainda precisará configurar manualmente:
- `RAILS_MASTER_KEY` no Web Service
- Conectar o Database ao Web Service

## Verificações Pós-Deploy

1. Acesse a URL do serviço (ex: `https://deaths-game.onrender.com`)
2. Verifique se o health check está funcionando: `https://seu-app.onrender.com/up`
3. Execute o seed se necessário (via Rails console no Render ou SSH)

## Comandos Úteis

### Acessar Rails Console no Render

1. No painel do Web Service, clique em "Shell"
2. Execute: `bundle exec rails console`

### Executar Migrations Manualmente

No Shell do Render:
```bash
bundle exec rails db:migrate
```

### Executar Seeds

No Shell do Render:
```bash
bundle exec rails db:seed
```

## Troubleshooting

### Erro: "DATABASE_URL not set"
- Verifique se o Database está conectado ao Web Service
- Confirme que a variável `DATABASE_URL` está configurada

### Erro: "RAILS_MASTER_KEY not set"
- Adicione a variável `RAILS_MASTER_KEY` no painel de Environment
- Use o conteúdo do arquivo `config/master.key`

### Build falha
- Verifique os logs do build no Render
- Confirme que todas as dependências estão no `Gemfile`
- Verifique se o script `bin/render-build.sh` tem permissão de execução

## Custos Estimados

- **Web Service (Starter)**: $7/mês
- **PostgreSQL (Starter)**: $6/mês
- **Total**: ~$13/mês

Para produção com mais tráfego, considere:
- **Web Service (Standard)**: $25/mês
- **PostgreSQL (Basic-1gb)**: $19/mês

## Links Úteis

- [Render Docs](https://render.com/docs)
- [Render Pricing](https://render.com/pricing)
- [Rails on Render](https://render.com/docs/deploy-rails)

