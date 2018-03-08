# MyTranslate

Translate phpBB3 Arcade games listings to english from Hungarian. Uses the Google translate API to do the translation.

---

On Ubuntu Install this module:

        apt-get install libssl-dev


Then run cpan and install:

        WWW::Google::Translate
        DBI




You wil then need to get a Google translation key and paste it into:

        /root/.translate_key



Then edit mytranslate.pl and make the required settings at the top


Then run ./mytranslate.pl and it should start up.

It will display easch listing from your database and give you a choice to act on that listing. Your choices are:


        q - quit processing and return to command prompt
        a - accept this entry and all further entries
        y - accept this entry but keep asking for  later records
        n - (or just enter) - skip this entry, do not translate it


**Note:** Do not run this twice on the same entry, that is do not accept it twice or use the "all" option or you will seem some extra garbage at the start of the translation if it is not in Hungarian format. Press enter or "n" to skip that line and go to the next entry.
