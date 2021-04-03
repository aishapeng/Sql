CREATE OR REPLACE PROCEDURE print_article (p_pubid CHAR) AS
   CURSOR print_article_cur (p_pubid CHAR) IS
        SELECT pubid, title, type, detail1, detail2, detail3
		FROM publication_master
        WHERE type = 'Article'
		AND TRIM(detail1) = UPPER(p_pubid)
		ORDER BY CAST(detail2 AS INT) ASC;
		
	article_rec print_article_cur%rowtype;
	v_found NUMBER := 0;

	e_nopublication EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nopublication, -20000);	
   
BEGIN 
   
	IF NOT print_article_cur%ISOPEN THEN
        OPEN print_article_cur(p_pubid);
    END IF;   
	
	LOOP
        FETCH print_article_cur INTO article_rec;
        EXIT WHEN print_article_cur%NOTFOUND;
    END LOOP;
    IF print_article_cur%ROWCOUNT > 0 THEN
            v_found := 1;
            DBMS_OUTPUT.PUT_LINE('PUBID        TITLE                                                                 TYPE          APPEARS IN   START PAGE    END PAGE');
            DBMS_OUTPUT.PUT_LINE('-----------  -------------------------------------------------------------------   ----------   ------------  -----------   ----------');
    END IF;
    CLOSE print_article_cur;

    IF v_found = 1 THEN
        IF NOT print_article_cur%ISOPEN THEN
            OPEN print_article_cur(p_pubid);
        END IF;
        LOOP
            FETCH print_article_cur INTO article_rec;
            EXIT WHEN print_article_cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(article_rec.pubid||'   '||article_rec.title||article_rec.type||'       '||article_rec.detail1||'        '||article_rec.detail2||'		'||article_rec.detail3);
        END LOOP;
        CLOSE print_article_cur;
        DBMS_OUTPUT.NEW_LINE;
    END IF;
    v_found := 0;

EXCEPTION
	WHEN e_nopublication THEN
        DBMS_OUTPUT.PUT_LINE('Error: No publication.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code = #'|| SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Msg = '|| SQLERRM); 
END; 
/
SET SERVEROUTPUT ON;
SET LINESIZE 200;