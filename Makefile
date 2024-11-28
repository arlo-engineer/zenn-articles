build:
	docker compose build

up:
	docker compose up

down:
	docker compose down

article:
	docker compose run --rm app npx zenn new:article

package.ci:
	docker compose run --rm app npm ci