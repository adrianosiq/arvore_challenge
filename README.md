# Árvore | Atividade Prática Backend

## Pré-requisitos
Para executar os próximos passos é necessário ter o docker e docker-compose instalado.

## Começando

```
git clone https://github.com/adrianosiq/cumbuca_challenge && cd arvore_challenge
```

Para rodar o teste em localhost

* Rodando o phoenix web server: `docker compose up web`
* Acessar o docker container `docker compose run --rm web bash`

Agora visite [`localhost:4000`](http://localhost:4000) no seu navegador.

**Testando a aplicação:**

* Acessar o docker container `docker compose run --rm test bash`
* Rodando ExUnit for staled tests `mix test --stale`
* Test coverage: `mix coveralls`

## Endpoints

**Deploy da aplicação**

A aplicação encontra-se no endereço: [`https://arvore-challenge.fly.dev/api`](https://arvore-challenge.fly.dev/api/) ou [`https://arvore-challenge.fly.dev/api/graphiql`](https://arvore-challenge.fly.dev/api/graphiql)

## Criando uma nova entidade

```graphql
mutation CreateEntity($name: String!, $entityType: String!, $inep: String, $parentId: Int) {
      createEntity(name: $name, entityType: $entityType, inep: $inep, parentId: $parentId) {
        id
        entityType
        inep
        name
        parentId
        subtreeIds
        accessKey
        secretAccessKey
      }
    }
```

```curl
curl --location 'https://arvore-challenge.fly.dev/api' \
--header 'Content-Type: application/json' \
--data '{"query":"mutation CreateEntity($name: String!, $entityType: String!, $inep: String, $parentId: Int) {\r\n      createEntity(name: $name, entityType: $entityType, inep: $inep, parentId: $parentId) {\r\n        id\r\n        entityType\r\n        inep\r\n        name\r\n        parentId\r\n        subtreeIds\r\n        accessKey\r\n        secretAccessKey\r\n      }\r\n    }","variables":{"entityType":"network","name":"Some Network"}}'
```

```json
{
    "data": {
        "createEntity": {
            "accessKey": "h3YQWvVDDngEKYy2eDFcxP4aKAUIO45f",
            "entityType": "network",
            "id": 3,
            "inep": null,
            "name": "Some Network",
            "parentId": null,
            "secretAccessKey": "TH5AIaSP1/CKA8ySnNF2jZPvVBRr9FbY77IjVxsC9O7iQft/R59kUPUMS8tfBBFi",
            "subtreeIds": []
        }
    }
}
```

## Autenticação
Observação: para autenticação utilizar o `access_key` e `secret_access_key`

```graphql
mutation Autorization($access_key: String!, $secret_access_key: String!) {
	autorization(access_key: $access_key, secret_access_key: $secret_access_key) {
		access_token
		expires_in
		token_type
	}
}
```

```curl
curl --location 'https://arvore-challenge.fly.dev/api' \
--header 'Content-Type: application/json' \
--data '{"query":"mutation Autorization($accessKey: String!, $secretAccessKey: String!) {\r\n      autorization(accessKey: $accessKey, secretAccessKey: $secretAccessKey) {\r\n        accessToken\r\n        expiresIn\r\n        tokenType\r\n      }\r\n    }","variables":{"accessKey":"h3YQWvVDDngEKYy2eDFcxP4aKAUIO45f","secretAccessKey":"TH5AIaSP1/CKA8ySnNF2jZPvVBRr9FbY77IjVxsC9O7iQft/R59kUPUMS8tfBBFi"}}'
```

```json
{
    "data": {
        "autorization": {
            "accessToken": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcnZvcmVfY2hhbGxlbmdlIiwiZXhwIjoxNjk0NjU0NDI5LCJpYXQiOjE2OTQ1NjgwMjksImlzcyI6ImFydm9yZV9jaGFsbGVuZ2UiLCJqdGkiOiJiZWZmZDI2Zi1kNWYwLTRlMjYtOTU2Zi02Y2I2Y2E1OTM3OWQiLCJuYmYiOjE2OTQ1NjgwMjgsInN1YiI6MywidHlwIjoiQmVhcmVyIn0.S-DHeLc45NHrQSdbbQKVcr9jR4a5JJV18c_06bev0N1M_snOYBRRYmVFqYjdsigQYEWlW7H9BcZiWNZVaBoazQ",
            "expiresIn": 86400,
            "tokenType": "Bearer"
        }
    }
}
```

## Recuperar uma entidate
Observação: Para acessar essa rota é necessário o access token válido.

```graphql
query  getEntity($id: Int!)  {
	entity(id: $id)  {
		id
		entityType
		inep
		name
		parentId
		subtreeIds
	}
}
```

```curl
curl --location 'https://arvore-challenge.fly.dev/api' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcnZvcmVfY2hhbGxlbmdlIiwiZXhwIjoxNjk0NjU0NDI5LCJpYXQiOjE2OTQ1NjgwMjksImlzcyI6ImFydm9yZV9jaGFsbGVuZ2UiLCJqdGkiOiJiZWZmZDI2Zi1kNWYwLTRlMjYtOTU2Zi02Y2I2Y2E1OTM3OWQiLCJuYmYiOjE2OTQ1NjgwMjgsInN1YiI6MywidHlwIjoiQmVhcmVyIn0.S-DHeLc45NHrQSdbbQKVcr9jR4a5JJV18c_06bev0N1M_snOYBRRYmVFqYjdsigQYEWlW7H9BcZiWNZVaBoazQ' \
--data '{"query":"query getEntity($id: Int!) {\r\n      entity(id: $id) {\r\n        id\r\n        entityType\r\n        inep\r\n        name\r\n        parentId\r\n        subtreeIds\r\n      }\r\n    }","variables":{"id":3}}'
```

```json
{
    "data": {
        "entity": {
            "entityType": "network",
            "id": 3,
            "inep": null,
            "name": "Some Network",
            "parentId": null,
            "subtreeIds": []
        }
    }
}
```

## Atualizando uma entidade
Observação: Para acessar essa rota é necessário o access token válido.

```graphql
mutation UpdateEntity($id: Int!, $name: String!, $inep: String, $parentId: Int) {
      updateEntity(id: $id, name: $name, inep: $inep, parentId: $parentId) {
        id
        entityType
        inep
        name
        parentId
        subtreeIds
      }
    }
```

```curl
curl --location 'https://arvore-challenge.fly.dev/api' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcnZvcmVfY2hhbGxlbmdlIiwiZXhwIjoxNjk0NjU0NDI5LCJpYXQiOjE2OTQ1NjgwMjksImlzcyI6ImFydm9yZV9jaGFsbGVuZ2UiLCJqdGkiOiJiZWZmZDI2Zi1kNWYwLTRlMjYtOTU2Zi02Y2I2Y2E1OTM3OWQiLCJuYmYiOjE2OTQ1NjgwMjgsInN1YiI6MywidHlwIjoiQmVhcmVyIn0.S-DHeLc45NHrQSdbbQKVcr9jR4a5JJV18c_06bev0N1M_snOYBRRYmVFqYjdsigQYEWlW7H9BcZiWNZVaBoazQ' \
--data '{"query":"mutation UpdateEntity($id: Int!, $name: String!, $inep: String, $parentId: Int) {\r\n      updateEntity(id: $id, name: $name, inep: $inep, parentId: $parentId) {\r\n        id\r\n        entityType\r\n        inep\r\n        name\r\n        parentId\r\n        subtreeIds\r\n      }\r\n    }","variables":{"id":3,"name":"Update Some Network"}}'
```

```json
{
    "data": {
        "updateEntity": {
            "entityType": "network",
            "id": 3,
            "inep": null,
            "name": "Update Some Network",
            "parentId": null,
            "subtreeIds": []
        }
    }
}
```

## Tecnologias
* Linguagem: Elixir
* Framework: Phoenix Framework
* Database: MySQL 8
* Arquitetura da API: GraphQL
* CI/CD: Semaphore
* Outros: Fly.io e AWS RDS MySQL para publicação da aplicação

## Estrutura de diretórios

* config/: Runtime configuration for the mix application
* lib/: Source code of our application
* lib/arvore_challenge/: Domain code
* lib/arvore_challenge_web/: Application code to handle HTTP communication
* test/: ExUnit test suite
* test/support/: This directory usually contains helpers and factory
* priv/: Code that isn't used in runtime, like database migrations, seeds and scripts
* priv/migrations/: Database structure migrations. We don't migrate any kind of data here
* deps/: Directory with all dependencies downloaded by `mix deps.get`
* _build/: Compiled code by `mix compile`
