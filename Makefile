
ifdef VERSION
	ARCHIVE_NAME := niwashi_recipe_$(VERSION).tar.gz
else
	ARCHIVE_NAME := niwashi_recipe.tar.gz
endif

release:
	tar -czf $(ARCHIVE_NAME) $(shell find . -maxdepth 1 ! -name ".*" -type d -print)
