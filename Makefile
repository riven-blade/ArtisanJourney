HUGO = hugo
OUTPUT_DIR = public
REMOTE_USER = root
REMOTE_HOST = 27.102.115.224
REMOTE_HOST_PORT = 30041
REMOTE_HOST_PASSWORD = E2pyNszM5WXM7dGh
REMOTE_DIR = /usr/share/nginx/html
GIT_BRANCH = main

all: deploy push-github

build:
	@echo "Building Hugo site..."
	$(HUGO)

clean:
	@echo "Cleaning up generated files..."
	rm -rf $(OUTPUT_DIR)

serve:
	@echo "Starting Hugo server..."
	$(HUGO) server --disableFastRender --buildDrafts --buildFuture

deploy: build
	@echo "Deploying to remote server..."
	sshpass -p "$(REMOTE_HOST_PASSWORD)" /usr/bin/rsync -avz --delete -e "ssh -p $(REMOTE_HOST_PORT)" $(OUTPUT_DIR)/ $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR)

push-github:
	@echo "Pushing changes to GitHub..."
	git add .
	git commit -m "Update site content on `date '+%Y-%m-%d %H:%M:%S'`"
	git push origin $(GIT_BRANCH)

help:
	@echo "Available commands:"
	@echo "  make               Build, deploy to server, and push to GitHub"
	@echo "  make build         Build the Hugo static site"
	@echo "  make clean         Clean the output directory"
	@echo "  make serve         Run Hugo development server"
	@echo "  make deploy        Build and deploy site to remote server via rsync"
	@echo "  make push-github   Build and push site changes to GitHub"