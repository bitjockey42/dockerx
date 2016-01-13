TARGET = /usr/local/bin/dockerx

install:
	cp ./src/dockerx.sh $(TARGET)

deletefile:
	rm $(TARGET)

uninstall: deletefile
