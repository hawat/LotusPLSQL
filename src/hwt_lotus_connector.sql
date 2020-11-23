CREATE OR REPLACE TYPE hwt_lot_kval AS OBJECT ( NoteID Varchar2(512),key Varchar2(512), lValue varchar2(4000) );
/
CREATE OR REPLACE TYPE hwt_lot_kval_TABLE AS TABLE OF hwt_lot_kval;
/
CREATE OR REPLACE TYPE hwt_ll_arr AS TABLE OF  VARCHAR2(4000);
/

java source named "hwt_lotus_connector"
as

import java.sql.*;
import java.io.*;
import oracle.jdbc.*;
import oracle.sql.*;
import lotus.domino.* ;
import java.util.Vector;
import java.util.Enumeration;

public class hwt_lotus_connector
{
static String host = "network.address.of.domino.sewer:63148" ; // server address, it must have running DIIOP connector
//static String SdominoName = "domino/name" ; 
private static DocumentCollection queryLotus(String user, String password, String database, String dominoName , String lquery) throws java.sql.SQLException, NotesException
{
 
   Session s = NotesFactory.createSession(host,user,password) ;

         Database db = s.getDatabase(dominoName, database );
 if(!db.isOpen()){
  db.open();
 }
 return db.search(lquery);
}

public static oracle.sql.ARRAY getDocuments(String user, String password, String database,String dominoName, String query, ARRAY lkeys) throws java.sql.SQLException, NotesException
{
Connection conn = new OracleDriver().defaultConnection();
String[] data_in = (String[]) lkeys.getArray(); 
DocumentCollection dc = queryLotus( user, password, database,dominoName, query);
int doccount = dc.getCount();
int keyscount = data_in.length;
int obj_id = 0;
String NoteID = "";
ArrayDescriptor arraydesc = ArrayDescriptor.createDescriptor ("HWT_LOT_KVAL_TABLE", conn);
STRUCT[] idsArray = new STRUCT[doccount*keyscount];
StructDescriptor itemDescriptor = StructDescriptor.createDescriptor("HWT_LOT_KVAL",conn);
STRUCT itemObject1;

Document  doc = dc.getFirstDocument();

for (int i = 0; i<doccount;i++)
{
NoteID = doc.getNoteID();
for (int ii = 0; ii<keyscount; ii++, obj_id++)
{
Object[] itemAtributes = new Object[] {NoteID,new String(data_in[ii]), new String(doc.getItemValueString(data_in[ii]))};

itemObject1 = new STRUCT(itemDescriptor,conn,itemAtributes);
idsArray[obj_id]=itemObject1;
}
doc = dc.getNextDocument(); 
}

ARRAY myArray = new ARRAY(arraydesc, conn, idsArray);
return myArray;
}
}
/
show errors;

create or replace FUNCTION hwt_lotusdoc(user varchar2,password varchar2, database varchar2,dominoname varchar2, query varchar2 , sta hwt_ll_arr )
 RETURN hwt_lot_kval_TABLE
AS
 LANGUAGE JAVA
 NAME 'hwt_lotus_connector.getDocuments(java.lang.String, java.lang.String, java.lang.String,java.lang.String,java.lang.String ,oracle.sql.ARRAY) return oracle.sql.ARRAY';
/
show errors