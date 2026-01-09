# Jogo do Morte

Sistema de gerenciamento para o Jogo do Morte - um bolão onde participantes apostam em celebridades que podem falecer durante o ano.

## Funcionalidades

- **Autenticação**: Login e registro de usuários com Devise
- **Lista de Celebridades**: Cada jogador pode criar uma lista de até 20 celebridades
- **Autocomplete**: Sistema de busca para evitar duplicatas ao adicionar celebridades
- **Interface Admin**: 
  - Mesclar celebridades duplicadas
  - Marcar celebridades como mortas e calcular pontos automaticamente (100 - idade)
- **Dashboard**: 
  - Ranking geral de pontuação
  - Gráficos de top jogadores e timeline de mortes
  - Visualização de listas de outros jogadores

## Setup

1. Instale as dependências:
```bash
bundle install
```

2. Inicie o PostgreSQL no Docker:
```bash
docker-compose up -d
```

Ou use o script automatizado:
```bash
./setup_db.sh
```

Ou manualmente:
```bash
docker-compose up -d
rails db:create db:migrate db:seed
```

3. Configure o banco de dados (se não usou o script):
```bash
rails db:create db:migrate
```

4. Crie o usuário admin:
```bash
rails db:seed
```

O admin padrão é:
- Email: `admin@example.com`
- Senha: `password123`

5. Inicie o servidor:
```bash
rails server
```

## Configuração do Banco de Dados

O projeto usa PostgreSQL rodando em Docker. As configurações estão em:
- `docker-compose.yml` - Configuração do container PostgreSQL
- `config/database.yml` - Configuração de conexão do Rails

Credenciais padrão:
- Host: `localhost`
- Port: `5432`
- User: `deaths_game`
- Password: `deaths_game_password`
- Database: `deaths_game_development`

## Uso

### Para Jogadores

1. Faça login ou crie uma conta
2. Acesse "Minha Lista" para adicionar celebridades
3. Use o autocomplete para verificar se a celebridade já existe
4. Visualize o ranking no Dashboard

### Para Admin

1. Faça login como admin
2. Acesse "Admin - Celebridades"
3. Para mesclar duplicatas: clique em "Mesclar" e selecione a celebridade destino
4. Para marcar como morto: clique em "Marcar como Morto" e informe idade e data

## Regras do Jogo

- Cada jogador aposta R$20,00
- Lista de até 20 celebridades
- Quando uma celebridade morre: pontos = 100 - idade
- Vencedor: maior pontuação ao final do ano
