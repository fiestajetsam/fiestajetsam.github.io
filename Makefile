.PHONY: build serve

serve:
	@docker run --rm \
	--volume="${PWD}:/srv/jekyll" \
	--volume="${PWD}/vendor/bundle:/usr/local/bundle" \
	--publish 4000:4000 \
	jekyll/jekyll:3.8 \
	jekyll serve --drafts

build:
	@docker run --rm -it \
	--volume="${PWD}:/srv/jekyll" \
	--volume="${PWD}/vendor/bundle:/usr/local/bundle" \
	jekyll/jekyll:3.8 \
	jekyll build --verbose
