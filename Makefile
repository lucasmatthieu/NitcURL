CC = nitc

dl_color = \033[34m
get_color = \033[32m
no_color = \033[0m

print_get = @echo "\n\n\t${get_color}GET $(1)\n${no_color}"
print_dl = @echo "\n\n\t${dl_color}DL $(1)\n${no_color}"

all: 
	@$(CC) get_sample.nit
	@$(CC) dl_sample.nit

tests: get dl

get:all
	$(call print_get, "http://papercom.fr")
	@./get_sample http://papercom.fr
	$(call print_get, "http://papercom.org")
	@./get_sample http://papercom.org
	$(call print_get, "http://google.com")
	@./get_sample http://google.com
	$(call print_get, "http://nitlanguage.org")
	@./get_sample http://nitlanguage.org
	$(call print_get, "http://nitlanguage.coom")
	@./get_sample http://nitlanguage.coom
	$(call print_get, "http://data.nantes.fr/api/publication/NB_ANNUEL_MARIAGES_NANTES/")
	@./get_sample http://data.nantes.fr/api/publication/NB_ANNUEL_MARIAGES_NANTES/NOMBRE_MARIAGES_NANTES_STBL/content

dl:all
	$(call print_dl, "http://papercom.fr/php.zip")
	@./dl_sample http://papercom.fr/php.zip
	$(call print_dl, "http://nitlanguage.org/index.html")
	@./dl_sample http://nitlanguage.org/index.html
	$(call print_dl, "http://images.wikia.com/uncyclopedia/images/3/33/Chimpanzee-picture.jpg")
	@./dl_sample http://images.wikia.com/uncyclopedia/images/3/33/Chimpanzee-picture.jpg
	$(call print_dl, "http://papercom.fr/share/f/sh-mv-hackhours_video.zip")
	@./dl_sample http://papercom.fr/share/f/sh-mv-hackhours_video.zip
	
clean:
	@rm -f get_sample dl_sample php.zip index.html Chimpanzee-picture.jpg sh-mv-hackhours_video.zip
	@echo "Clean done."
