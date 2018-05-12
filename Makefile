all: report.md
	@if ! type "pandoc" >/dev/null; then\
		make install; \
	fi
	pandoc --toc -s report.md -o report.pdf
	@if type "evince" >/dev/null; then\
		evince report.pdf & \
	else\
		xreader report.pdf & \
	fi

install: 
	sudo apt install pandoc
