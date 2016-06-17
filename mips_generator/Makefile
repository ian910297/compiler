LIB=/usr/local/lib/antlr-4.5.3-complete.jar
antlr4=java -jar $(LIB)

all:
	$(antlr4) Rose.g4
	javac Rose*.java

clear:
	rm -f *.java *.class Rose*.tokens

