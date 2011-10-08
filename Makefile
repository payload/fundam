coffee = coffee

compile:
	$(coffee) -o build/ -c src/

watch:
	$(coffee) -o build/ -cw src/

