# Twelve-tone Utilities

A set of two small programs to assist in the process of writing a musical composition using the twelve-tone technique.

The program `Gen` generates a twelve-tone row, with the order of the intervals chosen at random, ready to be used as the prime form in a composition.

If you run the program you'll get an output like:

    $ ./Gen
    G  D  E  Eb Ab C  Bb F  A  Gb B  Db

Note that all flats are used for accidentals. Also the `Grid ` program will expect that all accidentals are entered as flats as well.

The program `Grid` takes as an argument a twelve-tone row and generates the twelve-tone matrix with the original row (prime form), inverted, retrograde, and inverted retrograde forms of the row in all its transpositions.

Running the program with the row from the previous example with the following command:

    $ ./Grid  G  D  E  Eb Ab C  Bb F  A  Gb B  Db

will result in the output:

    G  D  E  Eb Ab C  Bb F  A  Gb B  Db
    C  G  A  Ab Db F  Eb Bb D  B  E  Gb
    Bb F  G  Gb B  Eb Db Ab C  A  D  E 
    B  Gb Ab G  C  E  D  A  Db Bb Eb F 
    Gb Db Eb D  G  B  A  E  Ab F  Bb C 
    D  A  B  Bb Eb G  F  C  E  Db Gb Ab
    E  B  Db C  F  A  G  D  Gb Eb Ab Bb
    A  E  Gb F  Bb D  C  G  B  Ab Db Eb
    F  C  D  Db Gb Bb Ab Eb G  E  A  B 
    Ab Eb F  E  A  Db B  Gb Bb G  C  D 
    Eb Bb C  B  E  Ab Gb Db F  D  G  A 
    Db Ab Bb A  D  Gb E  B  Eb C  F  G 


where as expected it shows reading from left to right the original row in all transpositions, from top to bottom the inversion of the row, from right to left the retrograde of the row and from bottom to top the inverted retrograde.

Finally, the two can be conveniently chained to generate the original row and matrix from it with the following command:

    $ ./Grid $(./Gen)
