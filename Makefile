
# Colors display
dl_color = \033[34m
get_color = \033[32m
post_color = \033[36m
mail_color = \033[35m
no_color = \033[0m
print_get = @echo "\n\n\t${get_color}GET $(1)\n${no_color}"
print_post = @echo "\n\n\t${post_color}POST $(1)\${no_color}"
print_dl = @echo "\n\n\t${dl_color}DL $(1)\n${no_color}"
print_mail = @echo "\n\n\t${mail_color}MAIL $(1)\n${no_color}"

# Nit
CC = nitc
EXT = .nit
OUT = .out
SOURCES = curl_sample.nit mail_sample.nit curlunit.nit
EXECS = $(SOURCES:.nit=.out)

# Targets
%$(OUT): %$(EXT)
	$(CC) $< -o $@

all: $(EXECS)

max: unit tests post get dl

tests: post get dl

unit: curlunit$(OUT)
	$(call print_get, "http://instagr.am")
	@./$< http://instagr.am
	$(call print_get, "http://papercom.fr")
	@./$< http://papercom.fr
	$(call print_get, "http://deezfzefzefEZ.rf")
	@./$< http://deezfzefzefEZ.rf
	$(call print_get, "http://google.com")
	@./$< http://google.com

post: curl_sample$(OUT)
	$(call print_post, "172.16.217.134/post.php")
	@./$< POST 172.16.217.134/post.php

get: curl_sample$(OUT)
	$(call print_get, "http://papercom.fr")
	@./$< GET http://papercom.fr
	$(call print_get, "http://papercom.org")
	@./$< GET http://papercom.org
	$(call print_get, "http://google.com")
	@./$< GET http://google.com
	$(call print_get, "http://nitlanguage.org")
	@./$< GET http://nitlanguage.org
	$(call print_get, "http://nitlanguage.coom")
	@./$< GET http://nitlanguage.coom
	$(call print_get, "http://data.nantes.fr/api/publication/NB_ANNUEL_MARIAGES_NANTES/")
	@./$< GET http://data.nantes.fr/api/publication/NB_ANNUEL_MARIAGES_NANTES/NOMBRE_MARIAGES_NANTES_STBL/content

dl: curl_sample$(OUT)
	$(call print_dl, "http://papercom.fr/php.zip")
	@./$< GET_FILE http://papercom.fr/php.zip
	$(call print_dl, "http://nitlanguage.org/index.html")
	@./$< GET_FILE http://nitlanguage.org/index.html
	$(call print_dl, "http://images.wikia.com/uncyclopedia/images/3/33/Chimpanzee-picture.jpg")
	@./$< GET_FILE http://images.wikia.com/uncyclopedia/images/3/33/Chimpanzee-picture.jpg
	$(call print_dl, "http://papercom.fr/share/f/sh-mv-hackhours_video.zip")
	@./$< GET_FILE http://papercom.fr/share/f/sh-mv-hackhours_video.zip

clean-dl:
	@rm -f *$(OUT) php.zip index.html Chimpanzee-picture.jpg sh-mv-hackhours_video.zip
	@clear
	@echo "Clean dl done."

clean:
	@rm -f *$(OUT)
	@clear
	@echo "Clean done."
