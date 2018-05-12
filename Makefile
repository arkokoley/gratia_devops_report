all: report.md
	@if ! type "pandoc" >/dev/null; then\
		make install; \
	fi
	./pp report.md | pandoc --toc -f markdown -o report.pdf 
	@if type "evince" >/dev/null; then\
		evince report.pdf & \
	else\
		xreader report.pdf & \
	fi

install: 
	sudo apt install pandoc graphviz librsvg2-bin
