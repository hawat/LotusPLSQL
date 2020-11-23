# LotusPLSQL
 

In some – usually rare (which means „do something ASAP”) – moments i was asked to do something with the data stored inside lotus notes database, somewhere on domino server. Internet has many sources of knowledge how to get data form and to domino server – as long you are on windows machine, and use some less elegant language like visual basic. Well, can be done this way – or my way. I don’t like compromises and unnecessary complications. It was simple to me, that all I really need is a oracle database which will process information coming from lotus, and then store it in the vast jungle of tables.Oracle has java stored procedures, and lotus notes client comes as java application. Brilliant combination. First step was to find where in the world is Carmen jar file containing required functionality. The answer: NCSO.jar, this file is hidden inside lotus notes client directory, so simple search will reveal path to it.

All one must do to force it to work as personal servant is to load it to oracle database. It’s as simple as:


	loadjava  -user sa/??@?????.your.tns -genmissing  -resolve -verbose NCSO.jar

Ready and kicking? We will put some raw source code to oracle, to make our fresh jar usable - execute hwt_lotus_connector.sql

If you encounter some kind of nasty security exception this:


	call dbms_java.grant_permission('SA', 'SYS:java.net.SocketPermission', '*', 'connect,resolve');

should send them to grave for good.

How to live with it? It’s elementary dear Watson! You could do some magic inside almost unarmed ;) plsql:

    set serveroutput on size 999999
    declare 
    --TYPE hwt_ll_arr AS TABLE OF  VARCHAR2(4000);
    dta1 hwt_ll_arr:=hwt_ll_arr('field name');
    begin
    dta1.extend(1);
    dta1(2):='Description';

    for somme in (select * from table(hwt_lotusdoc('domino login','and password','database_you_want.nsf','your/domino','what_to_search = value',dta1))) loop
    dbms_output.put_line(somme.NoteID||' - - '|| somme.key||' - - '||somme.lvalue);
    end loop;
    end;
    /

Or, more strange and fancy – put the same magic inside simple sql query!:

    select * from table(hwt_lotusdoc('your name nad surename','SOME PASSWORD','database.nsf','your/lotus','what = value',hwt_ll_arr('field you want to search')))

Final words: this example code is nothing more than example, not real implementation. It lacks many quirks and whistles that any production grade code should have, so – use it, explore, and extend!
