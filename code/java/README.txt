1. Iz direktorija "karkkainen-sanders/code/java" potrebno je preuzeti datoteku "Bioinformatika.jar"
2. Program se pokrece upisom u komandnu liniju: java -jar "C:\...\Bioinformatika.jar" "C:\...\input.txt" "C:\...\output.txt"
U datoteci "input.txt" nalazi se originalni niz cije se sufiksno polje racuna, dok ce se u datoteci "output.txt" nalaziti rezultat.
Ukoliko izlazna datoteka ne postoji, sama ce se stvoriti.


Za svaku metodu napravljeni su jUnit testovi.
Testovi se iz komandne linije pokrecu: java -cp "bin/;lib/junit-4.10.jar" org.junit.runner.JUnitCore Tests
