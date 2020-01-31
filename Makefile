THEME=liquorice


preview:
	hugo server -D -vw -t $(THEME)

build:
	hugo -v -t $(THEME)

.PHONY: preview build
