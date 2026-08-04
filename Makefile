.PHONY: db-up db-down db-reset db-shell db-status extract verify note

db-up:
	docker compose up -d

db-down:
	docker compose down

db-reset:
	docker compose down -v
	docker compose up -d

db-shell:
	docker compose exec mysql sh -lc 'mysql -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD" "$$MYSQL_DATABASE"'

db-status:
	docker compose ps

extract:
	./scripts/extraer-fuentes.sh

verify:
	./scripts/verificar-repo.sh

note:
	@test -n "$(TEMA)" || (echo 'Uso: make note TEMA="tema de la clase"' >&2; exit 2)
	./scripts/nueva-nota.sh "$(TEMA)"
