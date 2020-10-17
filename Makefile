LUAS = $(wildcard *.lua)
IMGS = $(wildcard www/*.gif www/icons/*/*.png)

all: enphaseEnvoy.c4z

enphaseEnvoy.c4z: driver.xml $(LUAS) $(IMGS) www/doc.rtf
	zip $@ $^

www/doc.rtf: README.md
	pandoc -s -f markdown -t rtf -o $@ $^

clean:
	rm enphaseEnvoy.c4z www/doc.rtf
