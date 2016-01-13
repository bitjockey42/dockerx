TARGET = /usr/local/bin/dockerx

install:
	cp ./src/dockerx.sh $(TARGET)

reinstall: deletefile install

deletefile:
	rm $(TARGET)

uninstall: deletefile
