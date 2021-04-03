drop table Publication_master;

CREATE TABLE publication_master(
    pubid CHAR(10),
    title VARCHAR2(70),
    type VARCHAR2(20), 
    detail1 VARCHAR2(50),
    detail2 VARCHAR2(50),
    detail3 VARCHAR2(50),
    detail4 VARCHAR2(50),
    FOREIGN KEY (pubid) REFERENCES publication(pubid),
    CONSTRAINT exist_record UNIQUE(pubid)
);

CREATE OR REPLACE PROCEDURE merge_publication AS 
    v_pubid VARCHAR2(10);
    v_title VARCHAR2(70);
    v_type VARCHAR2(20);
    v_year NUMBER;
    v_volume NUMBER;
    v_num NUMBER;
    v_publisher VARCHAR2(50);
    v_appearsin VARCHAR2(15);
    v_startpage NUMBER;
    v_endpage NUMBER;

    v_found NUMBER := 0;
    v_missing NUMBER := 0;
    v_total NUMBER := 0;
    v_counter_proceedings NUMBER := 0;
    v_counter_journal NUMBER := 0;
    v_counter_book NUMBER := 0;
    v_counter_article NUMBER := 0;

    TYPE missing_table IS TABLE OF VARCHAR2(10);
    missing_table1 missing_table := missing_table();

    CURSOR cur_publication IS
        SELECT * 
        FROM publication;

    CURSOR cur_proceedings(p_pubid CHAR) IS
        SELECT year
        FROM proceedings
        WHERE pubid = p_pubid;

    CURSOR cur_journal(p_pubid CHAR) IS
        SELECT volume, num, year 
        FROM journal
        WHERE pubid = p_pubid;

    CURSOR cur_book(p_pubid CHAR) IS
        SELECT publisher, year 
        FROM book
        WHERE pubid = p_pubid;

    CURSOR cur_article(p_pubid CHAR) IS
        SELECT appearsin, startpage, endpage  
        FROM article
        WHERE pubid = p_pubid;

    CURSOR cur_print_proceedings IS
        SELECT pubid, title, type, detail1 
        FROM publication_master
        WHERE type = 'Proceedings';

    CURSOR cur_print_journal IS
        SELECT pubid, title, type, detail1, detail2, detail3 
        FROM publication_master
        WHERE type = 'Journal';

    CURSOR cur_print_book IS
        SELECT pubid, title, type, detail1, detail2
        FROM publication_master
        WHERE type = 'Book';
    
    CURSOR cur_print_article IS
        SELECT pubid, title, type, detail1, detail2, detail3 
        FROM publication_master
        WHERE type = 'Article';

BEGIN
    --Get all publication id--
    IF NOT cur_publication%ISOPEN THEN
        OPEN cur_publication;
    END IF;
    LOOP
        FETCH cur_publication INTO v_pubid, v_title;
        EXIT WHEN cur_publication%NOTFOUND;
        v_found := 0;

        --Insert proceedings details-- 
        IF v_found = 0 THEN
            IF NOT cur_proceedings%ISOPEN THEN
                OPEN cur_proceedings(v_pubid);
            END IF;
            LOOP
                FETCH cur_proceedings INTO v_year;
                EXIT WHEN cur_proceedings%NOTFOUND;
                INSERT INTO publication_master(pubid, title, type, detail1) 
                    VALUES(v_pubid, v_title, 'Proceedings', v_year);
                v_counter_proceedings := v_counter_proceedings+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_proceedings;
        END IF;

        --Insert journal details--
        IF v_found = 0 THEN
            IF NOT cur_journal%ISOPEN THEN
                OPEN cur_journal(v_pubid);
            END IF;
            LOOP
                FETCH cur_journal INTO v_volume, v_num, v_year;
                EXIT WHEN cur_journal%NOTFOUND;
                INSERT INTO publication_master(pubid, title, type, detail1, detail2, detail3) 
                    VALUES(v_pubid, v_title, 'Journal', v_volume, v_num, v_year);
                v_counter_journal := v_counter_journal+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_journal;
        END IF;

        --Insert book details--
        IF v_found = 0 THEN
            IF NOT cur_book%ISOPEN THEN
                OPEN cur_book(v_pubid);
            END IF;
            LOOP
                FETCH cur_book INTO v_publisher, v_year;
                EXIT WHEN cur_book%NOTFOUND;
                INSERT INTO publication_master(pubid, title, type, detail1, detail2) 
                    VALUES(v_pubid, v_title, 'Book', v_publisher, v_year);
                v_counter_book := v_counter_book+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_book;
        END IF;

        --Insert article details--
        IF v_found = 0 THEN
            IF NOT cur_article%ISOPEN THEN
                OPEN cur_article(v_pubid);
            END IF;
            LOOP
                FETCH cur_article INTO v_appearsin, v_startpage, v_endpage;
                EXIT WHEN cur_article%NOTFOUND;
                INSERT INTO publication_master(pubid, title, type, detail1, detail2, detail3) 
                    VALUES(v_pubid, v_title, 'Article', v_appearsin, v_startpage, v_endpage);
                v_counter_article := v_counter_article+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_article;
        END IF;

        --Check missing publication--
        IF v_found = 0 THEN
            missing_table1.EXTEND;
            missing_table1(missing_table1.LAST) := v_pubid;
            v_missing := v_missing+1;
        END IF;

    END LOOP;
    CLOSE cur_publication;

    --Print total successful insertion--
    v_total := v_counter_proceedings + v_counter_book + v_counter_journal + v_counter_article;
    DBMS_OUTPUT.NEW_LINE;
	DBMS_OUTPUT.PUT_LINE('=============================================================');
    DBMS_OUTPUT.PUT_LINE('Total: '||v_total||' new records posted into publication_master table.');
    DBMS_OUTPUT.PUT_LINE('=============================================================');
    DBMS_OUTPUT.PUT_LINE('Proceedings	: '||v_counter_proceedings);
    DBMS_OUTPUT.PUT_LINE('Journal		: '||v_counter_journal);
    DBMS_OUTPUT.PUT_LINE('Book		: '||v_counter_book);
    DBMS_OUTPUT.PUT_LINE('Article		: '||v_counter_article);
	DBMS_OUTPUT.PUT_LINE('--------------------');
    DBMS_OUTPUT.NEW_LINE;

    --Print if any missing publication--
    IF v_missing > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Insert Fail: '||v_missing||' publication(s) with missing details.');
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------');
        FOR i IN missing_table1.FIRST..missing_table1.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('Missing Pubid '||i||': '||missing_table1(i));
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END IF;

    --Print all posted proceedings--
    IF NOT cur_print_proceedings%ISOPEN THEN
        OPEN cur_print_proceedings;
    END IF;
    
    LOOP
        FETCH cur_print_proceedings INTO v_pubid, v_title, v_type, v_year;
        EXIT WHEN cur_print_proceedings%NOTFOUND;
    END LOOP;
    IF cur_print_proceedings%ROWCOUNT > 0 THEN
            v_found := 1;
            DBMS_OUTPUT.PUT_LINE('PUBID        TITLE                                                                 TYPE                YEAR');
            DBMS_OUTPUT.PUT_LINE('--------     -------------------------------------------------------------------   -----------------   --------');
    END IF;
    CLOSE cur_print_proceedings;

    IF v_found = 1 THEN
        IF NOT cur_print_proceedings%ISOPEN THEN
            OPEN cur_print_proceedings;
        END IF;
        LOOP
            FETCH cur_print_proceedings INTO v_pubid, v_title, v_type, v_year;
            EXIT WHEN cur_print_proceedings%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_pubid||'   '||v_title||v_type||'          '||v_year);
        END LOOP;
        CLOSE cur_print_proceedings;
        DBMS_OUTPUT.PUT_LINE(chr(10));
    END IF;
    v_found := 0;

    --Print all posted journal--
    IF NOT cur_print_journal%ISOPEN THEN
        OPEN cur_print_journal;
    END IF;
    LOOP
        FETCH cur_print_journal INTO v_pubid, v_title, v_type, v_volume, v_num, v_year;
        EXIT WHEN cur_print_journal%NOTFOUND;
    END LOOP;
    IF cur_print_journal%ROWCOUNT > 0 THEN
            v_found := 1;
            DBMS_OUTPUT.PUT_LINE('PUBID        TITLE                                                                 TYPE                VOLUME   NUM   YEAR');
            DBMS_OUTPUT.PUT_LINE('---------    -------------------------------------------------------------------   -----------------   -------  ------  -------');

    END IF;
    CLOSE cur_print_journal;

    IF v_found = 1 THEN
        IF NOT cur_print_journal%ISOPEN THEN
            OPEN cur_print_journal;
        END IF;
        LOOP
            FETCH cur_print_journal INTO v_pubid, v_title, v_type, v_volume, v_num, v_year;
            EXIT WHEN cur_print_journal%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_pubid||'   '||v_title||v_type||'		'||v_volume||'	'||v_num||'	'||v_year);
        END LOOP;
        CLOSE cur_print_journal;
        DBMS_OUTPUT.PUT_LINE(chr(10));
    END IF;
    v_found := 0;

    --Print all posted book--
    IF NOT cur_print_book%ISOPEN THEN
        OPEN cur_print_book;
    END IF;
    LOOP
        FETCH cur_print_book INTO v_pubid, v_title, v_type, v_publisher, v_year;
        EXIT WHEN cur_print_book%NOTFOUND;
    END LOOP;
    IF cur_print_book%ROWCOUNT > 0 THEN
            v_found := 1;
            DBMS_OUTPUT.PUT_LINE('PUBID        TITLE                                                                 TYPE                PUBLISHER                                         YEAR');
            DBMS_OUTPUT.PUT_LINE('---------    -------------------------------------------------------------------   -----------------   -----------------------------------------      --------');
    END IF;
    CLOSE cur_print_book;

    IF v_found = 1 THEN
        IF NOT cur_print_book%ISOPEN THEN
            OPEN cur_print_book;
        END IF;
        LOOP
            FETCH cur_print_book INTO v_pubid, v_title, v_type, v_publisher, v_year;
            EXIT WHEN cur_print_book%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_pubid||'   '||v_title||v_type||'                '||v_publisher||v_year);
        END LOOP;
        CLOSE cur_print_book;
        DBMS_OUTPUT.PUT_LINE(chr(10));
    END IF;
    v_found := 0;

     --Print all posted article--
    IF NOT cur_print_article%ISOPEN THEN
        OPEN cur_print_article;
    END IF;
    LOOP
        FETCH cur_print_article INTO v_pubid, v_title, v_type, v_appearsin, v_startpage, v_endpage;
        EXIT WHEN cur_print_article%NOTFOUND;
    END LOOP;
    IF cur_print_article%ROWCOUNT > 0 THEN
            v_found := 1;
            DBMS_OUTPUT.PUT_LINE('PUBID        TITLE                                                                  TYPE        APPEARS IN   START PAGE     END PAGE');
            DBMS_OUTPUT.PUT_LINE('-----------  -------------------------------------------------------------------   ----------   -----------  -----------   ----------');
    END IF;
    CLOSE cur_print_article;

    IF v_found = 1 THEN
        IF NOT cur_print_article%ISOPEN THEN
            OPEN cur_print_article;
        END IF;
        LOOP
            FETCH cur_print_article INTO v_pubid, v_title, v_type, v_appearsin, v_startpage, v_endpage;
            EXIT WHEN cur_print_article%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_pubid||'   '||v_title||v_type||'      '||v_appearsin||'	  '||v_startpage||'		'||v_endpage);
        END LOOP;
        CLOSE cur_print_article;
        DBMS_OUTPUT.PUT_LINE(chr(10));
    END IF;
    v_found := 0;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code = #'|| SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Msg = '|| SQLERRM); 
END;
/