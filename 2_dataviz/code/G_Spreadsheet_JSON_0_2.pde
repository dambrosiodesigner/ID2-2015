// -
// G_Spreadsheet_Data 0.2 [JSON / Public url]
// © Daniele @ Fupete for the course ID2 @ UnirSM  
// github.com/fupete — github.com/Fupete/ID2-2015
// Educational purpose, MIT License, march 2015, San Marino
// update by Giuseppe D'Ambrosio
// —
// Load and parse JSON data from a public Google Spreadsheet Url
// Collect columns contents in List arrays (A_values, B_values, ...) 
// and column titles in String variables (A_title, B_title, ...)
// Credits to Jer Thorp on why connect G_Spreadsheet to Processing http://goo.gl/MQNsxr
// —

// holders for title/List values <<<< modify to your needs! <<<<

String all_title[] = new String[100];  // titles  (first column value)
String row_string[][] = new String[100][1000]; // lines  [column][row]
float row_float[][]= new float[100][100]; // array used to convert a string list to numeric list
int  maxColumn=0; // max number of columns
int[] maxRow = new int[100];  // max number of rows for each column


void setup() {

  size(600, 600);
  /// old json test 2 columns (prof.) 
   // String url = "https://spreadsheets.google.com/feeds/cells/1N3nAcoJcDD-fhFWUvuKv4muI6jbxHG8y_TdEI-DgJSI/od6/public/basic?alt=json"; // < the spreadsheet must be published and available to a public url.

  // new json test 4 columns
  String url = "https://spreadsheets.google.com/feeds/cells/1M7j4-Fed5rOC_vi4M-ckvIACYet8kMIlk8Ka8bXkyDM/od6/public/basic?alt=json"; // < the spreadsheet must be published and available to a public url.

  // Patched function to load tables with an unlimited number of columns, the function return matrix size (num of column and num of row)
  // Note: null values are not loaded because it loads the data in lists format
  // while in the case of a matrix format enter a value (0 or null) in the worksheet google spreadsheets
  load_G_Spreadsheet(url);

  // creates a table with exel file (CSV format) in the data folder (data/table.csv)
  table (all_title, row_string, maxColumn, maxRow);

  // print the json in compiler
  printTable (all_title, row_string, maxColumn, maxRow);

  // draw table in the sketch, the first two values are the (x,y) position of the table
  drawTable (20, 20, all_title, row_string, maxColumn, maxRow);

  // Note: The table is all composed of string data,
  // In the case of a numeric column, you can use this function
  // to get an array of decimal numbers (convert string array to decimal array)
  convertToFloat (row_string, maxRow, row_float, 2 /* <- num column to convert */);
} 


void draw() {
  // do things with your data
}




Table table; 
// creates a table with exel file (CSV format) in the data folder
Table table (String all_title[], String row_string[][], int maxColumn, int[] maxRow) {

  table = new Table();  // create a table


    for (int i = 0; i < maxColumn; i++) { // add new column and insert the name 
    table.addColumn(all_title[i]);
  }

  // bestHighCol is the number of rows in the longer column
  int bestHighCol = maxRow [0];

  for (int i = 1; i < bestHighCol; i++) {   // calculating bestHighCol
    if (maxRow [i]>bestHighCol) {
      bestHighCol=maxRow [i];
    }
  }

  for (int i = 1; i < bestHighCol; i++) {
    TableRow newRow = table.addRow();  // add a row 
    for (int j = 0; j < maxColumn; j++) {
      newRow.setString(all_title[j], row_string[j][i]);  // inserts the value in the line (row)
    }
  }

  saveTable(table, "data/table.csv");
  return table; // save and return table format in processing sketch
}

// draw simple table in sketch
void drawTable (int x, int y, String all_title[], String row_string[][], int maxColumn, int[] maxRow) {
  int distance_X = 0;
  int distance_Y = 0;
  translate(x, y);
  // bestHighCol is the number of rows in the longer column
  int bestHighCol = maxRow [0];
  for (int i = 1; i < bestHighCol; i++) {   // calculating bestHighCol
    if (maxRow [i]>bestHighCol) {
      bestHighCol=maxRow [i];
    }
  }
  rect(0, -4, 130*(maxColumn), (bestHighCol-1)*35); // border

  for (int i =0; i<maxColumn; i++) {
    fill(0);
    text (all_title[i], distance_X+4, distance_Y+15 ); // vertical lines
    line(distance_X, -4, distance_X, ((bestHighCol-1)*35)-4) ; // title 1 row
    for (int j = 1; j < maxRow[i]; j++) {
      text (row_string[i][j], distance_X +4, distance_Y, distance_X+104, distance_Y ); // lists 
      line(0, distance_Y-4, 130*(maxColumn), distance_Y-4); // horizontal lines
      distance_Y+=35;
    }
    distance_X+=130;
    distance_Y=0;
  }
}

void printTable (String all_title[], String row_string[][], int maxColumn, int[] maxRow) {

  for (int i =0; i<maxColumn; i++) { // print the json
    println (all_title[i]+":");
    println (); 
    for (int j = 1; j < maxRow[i]; j++) {
      print ("["+row_string[i][j]+"]  ");
    }
    println ();  
    println ();
  }
}

/// function to rapid convert the string list in deciman numbers list
void convertToFloat (String row_string[][], int[] maxRow, float row_float[][], int col) {
  for (int i = 1; i < maxRow[col]; i++) {
    row_float[col][i]= int (row_string[col][i]);
  }
}


void load_G_Spreadsheet(String url) {

  JSONObject G_Spreadsheet_data = null;

  try 
  { 
    G_Spreadsheet_data = loadJSONObject(url);
  } 
  catch(Exception el) 
  { 
    println("Error loading JSON"); 
    exit();
  }

  if (G_Spreadsheet_data == null) 
  { 
    println("No data"); 
    exit();
  } else 
    parse_G_Spreadsheet_JSON(G_Spreadsheet_data); // < this start the magic
} 

void parse_G_Spreadsheet_JSON(JSONObject jdata) {

  JSONObject feed = jdata.getJSONObject("feed");
  JSONArray entries = feed.getJSONArray("entry");

  for (int i = 0; i < entries.size (); i++) {
    JSONObject entry = entries.getJSONObject(i);
    JSONObject entry_title = entry.getJSONObject("title");
    JSONObject entry_value = entry.getJSONObject("content");

    // cell content index
    String index = entry_title.getString("$t");
    char current_column = index.charAt(0); // < 'empiric' but works :)

    // cell content value
    String value = entry_value.getString("$t");



    /** start patched function **/

    // String used to process the json
    String str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    // search the max number of column
    for (int r= 0; r<str.length (); r++ ) {
      if ( index.indexOf(str.charAt(r)+str(1)) == 0) {  
        maxColumn=r+1;  // Count the number of columns until it finds more
      }
    }

    for (int j= 0; j< maxColumn; j++ ) {

      // search the title of the column and inserts it in the all_title array [j] according to its location j
      // ecample column 1 (j=1) ... column n (j=n)
      if (index.equals(str.charAt(j)+str(1)) == true) { 
        all_title[j]=value;
      }

      // search all the line (row) of a  specific column [j] 
      if (current_column == str.charAt(j)) { 
        row_string[j][maxRow[j]]=value;       //  maxRow is the number of rows for each column
        maxRow[j]++;
      }
    }
    /* end */
  }
} 
