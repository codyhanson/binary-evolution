#define	textColor		"FF"
#define	backgndColor	"FE"
#define	charHt			5
#define	charWidth		6		// Include 1-pixel spacing after

#include "stdlib.h"
#include "stdio.h"
#include "unistd.h"
#include "string.h"
#include "math.h"

int fbLen;	// Width of the frame buffer
int len;	// Length of text to convert

int getPixelVal(char ch, int i, int j);

// usage: ./generate_text <output_file> "text to convert"
int main(int argc, char** argv) {

	int numLines = 1;

	if (argc != 4) {
		printf("Usage:	./generate_text <output_file> <width of FB> \"text to convert\"\n");
		exit(0);
	}

	FILE* file;
	file = fopen(argv[1], "w");

	fbLen = atoi(argv[2]);
	len = charWidth*strlen(argv[3]);

	int numCharsPerLine = (fbLen/charWidth);
	if(len > fbLen) {
		numLines = (len/fbLen) + ((len%fbLen) ? 1 : 0);
	}
	printf("Number of lines: %d/%d = %d\n", len,fbLen, numLines);
	printf("numCharsPerLine = %d\n", numCharsPerLine);

	char *str = argv[3];
	char *substr = malloc(numCharsPerLine*sizeof(char));
	char ch;
	printf("str = '%s' -----  j < %d\n", str,fbLen);


	int line,i,j,numChars = numCharsPerLine;
	int thisPixel;	// 0 - background, 1 - part of text
	for(line = 0; line < numLines; line++) {
		// numChars gets <min> of the two
		numChars = (numCharsPerLine > len) ? len : numCharsPerLine;
		strncpy(substr, str+(line*numCharsPerLine),numChars);

//		printf("str-'%s';       substr-'%s'\n", str, substr);

		// Decrement remaining length of str <len>
		len -= numChars;

		// Loop through <charHt+1> rows
		for(i=0; i <= charHt; i++) {
			// Loop through the row
			for(j=0; j < fbLen; j++) {
				if(i == 0 || j > numChars*charWidth) {
					thisPixel = 0;
				} else {
					ch = substr[j/charWidth];
					thisPixel = getPixelVal(ch, i-1, j%charWidth);
				}

//				printf("(%d,%d,%d):'%c' = %d\n", line,i,j,ch,thisPixel);

				// Print to the hex file
				fprintf(file, "%s ", thisPixel ? textColor : backgndColor);
			}//j-loop
			fprintf(file, "\n");
		}//i-loop
	}//line-loop

	fclose(file);
	exit(0);
} //main()

int getPixelVal(char ch, int i, int j) {
	int val;
	int charMap[5][6] = {{0,0,0,0,0,0}, {0,0,0,0,0,0}, {0,0,0,0,0,0}, {0,0,0,0,0,0}, {0,0,0,0,0,0}};

	// Case statement to fill the character mapping
	switch(ch) {
		// Letters
		case 'a' : case 'A' :
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][3] = 1;
			break;
		case 'b' : case 'B' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][1] = charMap[4][2] = 1;
			break;
		case 'c' : case 'C' :
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case 'd' : case 'D' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][1] = charMap[4][2] = 1;
			break;
		case 'e' : case 'E' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][0] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case 'f' : case 'F' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][0] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = 1;
			charMap[4][0] = 1;
			break;
		case 'g' : case 'G' :
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = 1;
			charMap[2][0] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case 'h' : case 'H' :
			charMap[0][0] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][3] = 1;
			break;
		case 'i' : case 'I' :
			charMap[0][1] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = 1;
			charMap[3][1] = 1;
			charMap[4][1] = 1;
			break;
		case 'j' : case 'J' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][2] = 1;
			charMap[2][2] = 1;
			charMap[3][0] = charMap[3][2] = 1;
			charMap[4][1] = 1;
			break;
		case 'k' : case 'K' :
			charMap[0][0] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][3] = 1;
			break;
		case 'l' : case 'L' :
			charMap[0][0] = 1;
			charMap[1][0] = 1;
			charMap[2][0] = 1;
			charMap[3][0] = 1;
			charMap[4][0] = charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case 'm' : case 'M' :
			charMap[0][1] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][2] = charMap[1][4] = 1;
			charMap[2][0] = charMap[2][2] = charMap[2][4] = 1;
			charMap[3][0] = charMap[3][2] = charMap[3][4] = 1;
			charMap[4][0] = charMap[4][2] = charMap[4][4] = 1;
			break;
		case 'n' : case 'N' :
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][3] = 1;
			break;
		case 'o' : case 'O' :
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case 'p' : case 'P' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][1] = charMap[3][2] = 1;
			charMap[4][0] = 1;
			break;
		case 'q' : case 'Q' :
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = charMap[4][4] = 1;
			break;
		case 'r' : case 'R' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][3] = 1;
			break;
		case 's' : case 'S' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][0] = 1;
			charMap[2][1] = charMap[2][2] = 1;
			charMap[3][3] = 1;
			charMap[4][0] = charMap[4][1] = charMap[4][2] = 1;
			break;
		case 't' : case 'T' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = 1;
			charMap[3][1] = 1;
			charMap[4][1] = 1;
			break;
		case 'u' : case 'U' :
			charMap[0][0] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case 'v' : case 'V' :
			charMap[0][0] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][2] = 1;
			charMap[4][1] = 1;
			break;
		case 'w' : case 'W' :
			charMap[0][0] = charMap[0][4] = 1;
			charMap[1][0] = charMap[1][2] = charMap[1][4] = 1;
			charMap[2][0] = charMap[2][2] = charMap[2][4] = 1;
			charMap[3][0] = charMap[3][2] = charMap[3][4] = 1;
			charMap[4][1] = charMap[4][3] = 1;
			break;
		case 'x' : case 'X' :
			charMap[0][0] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][0] = charMap[4][3] = 1;
			break;
		case 'y' : case 'Y' :
			charMap[0][0] = charMap[0][2] = 1;
			charMap[1][0] = charMap[1][2] = 1;
			charMap[2][1] = 1;
			charMap[3][1] = 1;
			charMap[4][1] = 1;
			break;
		case 'z' : case 'Z' :
			charMap[0][0] = charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][3] = 1;
			charMap[2][2] = 1;
			charMap[3][1] = 1;
			charMap[4][0] = charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;

		// Numbers
		case '1' :
			charMap[0][2] = 1;
			charMap[1][1] = charMap[1][2] = 1;
			charMap[2][2] = 1;
			charMap[3][2] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case '2' :
			charMap[0][2] = charMap[0][3] = 1;
			charMap[1][1] = charMap[1][4] = 1;
			charMap[2][3] = 1;
			charMap[3][2] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = charMap[4][4] = 1;
			break;
		case '3' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][3] = 1;
			charMap[2][2] = 1;
			charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case '4' :
			charMap[0][3] = 1;
			charMap[1][2] = charMap[1][3] = 1;
			charMap[2][1] = charMap[2][3] = 1;
			charMap[3][1] = charMap[3][2] = charMap[3][3] = charMap[3][4] = 1;
			charMap[4][3] = 1;
			break;
		case '5' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case '6' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][1] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case '7' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = charMap[0][4] = 1;
			charMap[1][4] = 1;
			charMap[2][3] = 1;
			charMap[3][2] = 1;
			charMap[4][2] = 1;
			break;
		case '8' :
			charMap[0][2] = charMap[0][3] = 1;
			charMap[1][1] = charMap[1][4] = 1;
			charMap[2][2] = charMap[2][3] = 1;
			charMap[3][1] = charMap[3][4] = 1;
			charMap[4][2] = charMap[4][3] = 1;
			break;
		case '9' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = charMap[0][4] = 1;
			charMap[1][1] = charMap[1][4] = 1;
			charMap[2][2] = charMap[2][3] = charMap[2][4] = 1;
			charMap[3][4] = 1;
			charMap[4][4] = 1;
			break;
		case '0' :
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][1] = charMap[1][3] = 1;
			charMap[2][1] = charMap[2][3] = 1;
			charMap[3][1] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;

		// Special characters
		case '-' : 
			charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			break;
		case '_' : 
			charMap[4][0] = charMap[4][1] = charMap[4][2] = charMap[4][3] = charMap[4][4] = 1;
			break;
		case '=' : 
			charMap[1][1] = charMap[1][2] = charMap[1][3] = 1;
			charMap[3][1] = charMap[3][2] = charMap[3][3] = 1;
			break;
		case '+' : 
			charMap[1][2] = 1;
			charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][2] = 1;
			break;
		case ',' : 
			charMap[3][2] = 1;
			charMap[4][1] = 1;
			break;
		case '.' : 
			charMap[3][2] = 1;
			break;
		case '/' : 
			charMap[0][4] = 1;
			charMap[1][3] = 1;
			charMap[2][2] = 1;
			charMap[3][1] = 1;
			charMap[4][0] = 1;
			break;
		case '?' : 
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][3] = 1;
			charMap[2][2] = 1;

			charMap[4][2] = 1;
			break;
		case ';' : 
			charMap[1][2] = 1;
			charMap[3][2] = 1;
			charMap[4][1] = 1;
			break;
		case ':' : 
			charMap[1][1] = 1;
			charMap[3][1] = 1;
			break;
		case '|' : 
			charMap[0][1] = 1;
			charMap[1][1] = 1;
			charMap[3][1] = 1;
			charMap[4][1] = 1;
			break;
		case '\'' : 
			charMap[0][0] = charMap[0][1] = 1;
			charMap[1][1] = 1;
			charMap[2][0] = 1;
			break;
		case '"' : 
			charMap[0][0] = charMap[0][1] = charMap[0][3] = charMap[0][4] = 1;
			charMap[1][1] = charMap[1][4] = 1;
			charMap[2][0] = charMap[2][3] = 1;
			break;
		case '\\' : 
			charMap[0][0] = 1;
			charMap[1][1] = 1;
			charMap[2][2] = 1;
			charMap[3][3] = 1;
			charMap[4][4] = 1;
			break;
		case '[' : 
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = 1;
			charMap[3][1] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case ']' : 
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][2] = 1;
			charMap[2][2] = 1;
			charMap[3][2] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case '{' : 
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][1] = 1;
			charMap[2][0] = 1;
			charMap[3][1] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case '}' : 
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][2] = 1;
			charMap[2][3] = 1;
			charMap[3][2] = 1;
			charMap[4][1] = charMap[4][2] = 1;
			break;
		case '!' : 
			charMap[0][1] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = 1;
			charMap[4][1] = 1;
			break;
		case '@' : 
			charMap[0][1] = charMap[0][2] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][4] = 1;
			charMap[2][0] = charMap[2][2] = charMap[2][3] = charMap[2][4] = 1;
			charMap[3][0] = charMap[3][2] = charMap[3][4] = 1;
			charMap[4][2] = charMap[4][3] = 1;
			break;
		case '#' : 
			charMap[0][1] = charMap[0][3] = 1;
			charMap[1][0] = charMap[1][1] = charMap[1][2] = charMap[1][3] = charMap[1][4] = 1;
			charMap[2][1] = charMap[2][3] = 1;
			charMap[3][0] = charMap[3][1] = charMap[3][2] = charMap[3][3] = charMap[3][4] = 1;
			charMap[4][1] = charMap[4][3] = 1;
			break;
		case '$' : 
			charMap[0][1] = charMap[0][2] = charMap[0][3] = charMap[0][4] = 1;
			charMap[1][0] = charMap[1][2] = 1;
			charMap[2][1] = charMap[2][2] = charMap[2][3] = 1;
			charMap[3][2] = charMap[3][4] = 1;
			charMap[4][0] = charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case '%' : 
			charMap[0][0] = charMap[0][1] = charMap[0][4] = 1;
			charMap[1][0] = charMap[1][1] = charMap[1][3] = 1;
			charMap[2][2] = 1;
			charMap[3][1] = charMap[3][3] = charMap[3][4] = 1;
			charMap[4][0] = charMap[4][3] = charMap[4][4] = 1;
			break;
		case '^' : 
			charMap[0][2] = 1;
			charMap[1][1] = charMap[1][3] = 1;
			charMap[2][0] = charMap[2][4] = 1;
			break;
		case '&' : 
			charMap[0][1] = charMap[0][2] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = charMap[2][2] = 1;
			charMap[3][0] = charMap[3][3] = 1;
			charMap[4][1] = charMap[4][2] = charMap[4][3] = 1;
			break;
		case '*' : 
			charMap[0][2] = 1;
			charMap[1][1] = charMap[1][2] = charMap[1][3] = 1;
			charMap[2][2] = 1;
			charMap[3][1] = charMap[3][3] = 1;
			break;
		case '(' : 
			charMap[0][2] = 1;
			charMap[1][1] = 1;
			charMap[2][1] = 1;
			charMap[3][1] = 1;
			charMap[4][2] = 1;
			break;
		case ')' : 
			charMap[0][1] = 1;
			charMap[1][2] = 1;
			charMap[2][2] = 1;
			charMap[3][2] = 1;
			charMap[4][1] = 1;
			break;
		case '`' : 
			charMap[0][1] = 1;
			charMap[1][2] = 1;
			break;
		case '~' : 
			charMap[0][1] = charMap[0][2] = charMap[0][4] = 1;
			charMap[1][0] = charMap[1][3] = 1;
			break;
	} //switch(ch)

	val = charMap[i][j];
	//if(val) printf("----	'%c':[%d][%d]\n",ch,i,j);

	return val;

} //getPixelVal()

