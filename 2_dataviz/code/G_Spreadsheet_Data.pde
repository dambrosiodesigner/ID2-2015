// -
// G_Spreadsheet_Data 0.1 [JSON / Public url]
// © Daniele @ Fupete for the course ID2 @ UnirSM  
// github.com/fupete — github.com/Fupete/ID2-2015
// Educational purpose, MIT License, march 2015, San Marino
// —
// Load and parse JSON data from a public Google Spreadsheet Url
// Collect columns contents in List arrays (A_values, B_values, ...) 
// and column titles in String variables (A_title, B_title, ...)
// Credits to Jer Thorp on why connect G_Spreadsheet to Processing http://goo.gl/MQNsxr
// —


// holders for title/List values <<<< modify to your needs! <<<<
String A_title, B_title; // < holders for column titles, first row, ex. title will be the content from A1, B1, ...
IntList A_values = new IntList(); // < column A, integers, ages
StringList B_values = new StringList(); // < column B, strings, names


void setup() {

  // load&parse data
  String url = "https://spreadsheets.google.com/feeds/cells/1N3nAcoJcDD-fhFWUvuKv4muI6jbxHG8y_TdEI-DgJSI/od6/public/basic?alt=json"; // < the spreadsheet must be published and available to a public url.
  load_G_Spreadsheet(url);
  
  // are they loaded&parsed?
  println (A_title);  println (A_values);  // < column A, integers, ages
  println (B_title);  println (B_values);  // < column B, strings, names
  
  
  // Giuseppe
  table(A_title, B_title, A_values, B_values);
  drawTable(A_title, B_title, A_values, B_values);
  
  } 


void draw() {
  
  // do things with your data
  
}




// function by Giuseppe
// writing and return a table 
// saves the table in the folder data with a csv format

Table table;

Table table (String Acol, String Bcol, IntList A, StringList B) {

  table = new Table();  // create a table

    // add new column and insert the name 
  table.addColumn(Acol);
  table.addColumn(Bcol);

  for (int i = 0; i < A.size (); i++) {
    TableRow newRow = table.addRow();  // add a row
    newRow.setInt(Acol, A.get(i));     // insert value in a Acol
    newRow.setString(Bcol, B.get(i));  // insert value in Bcol
  }

  saveTable(table, "data/table.csv");

  return table;
}


// Draw a simple table in the sketch
void drawTable (String Acol, String Bcol, IntList A, StringList B) {
  int distance = 0;
  fill(0);
  text(Acol, 0, 10);
  text(Bcol, 30, 10 );
  line (0, 14, 100, 14);
  for (int i =0; i < A.size (); i++ ) {
    distance += 11;
    text(A.get(i), 0, 15+i+distance );
    text(B.get(i), 30, 15+i+distance );
  }
}






void load_G_Spreadsheet(String url) {
  
  JSONObject G_Spreadsheet_data = null;
  
  try 
    { G_Spreadsheet_data = loadJSONObject(url); } 
  catch(Exception el) 
    { println("Error loading JSON"); exit(); }
  
  if (G_Spreadsheet_data == null) 
    { println("No data"); exit(); } 
  else 
    parse_G_Spreadsheet_JSON(G_Spreadsheet_data); // < this start the magic 

} 


void parse_G_Spreadsheet_JSON(JSONObject jdata) {

  JSONObject feed = jdata.getJSONObject("feed");
  JSONArray entries = feed.getJSONArray("entry");
  
  for (int i = 0; i < entries.size(); i++) {
    JSONObject entry = entries.getJSONObject(i);
    JSONObject entry_title = entry.getJSONObject("title");
    JSONObject entry_value = entry.getJSONObject("content");
    
    // cell content index
    String index = entry_title.getString("$t");
    char current_column = index.charAt(0); // < 'empiric' but works :)
    
    // cell content value
    String value = entry_value.getString("$t");
  
    // fill the right title/List values <<<< modify to your needs! <<<<
    if (index.equals("A1") == true) { A_title = value; } else
    if (index.equals("B1") == true) { B_title = value; } else 
    if (current_column == 'A') { A_values.append(int(value)); } else
    if (current_column == 'B') { B_values.append(value); }
  } 

} 
