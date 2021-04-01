CREATE OR REPLACE PROCEDURE print_publication 
(p_name VARCHAR2) AS
    v_aid VARCHAR2(38);
    v_pubid CHAR(10);
    v_name VARCHAR2(22);
    v_type CHAR(20);
    v_title CHAR(70);
    v_year NUMBER(38);

    v_count_proceedings NUMBER := 0;
    v_count_journal NUMBER := 0;
    v_count_article NUMBER := 0;
    v_count_book NUMBER := 0;
    v_count_author NUMBER := 0;
    v_total_count NUMBER := 0;
    v_found NUMBER := 0;
    v_found_article NUMBER := 0;

    TYPE rec_pubid IS RECORD(
        pubid CHAR(10),
        type CHAR(20),
        year NUMBER(38)
    );  
    rec_pubid1 rec_pubid;
    TYPE pubid_table IS TABLE OF rec_pubid;
    pubid_table1 pubid_table := pubid_table(); 
    temp rec_pubid;

    TYPE name_table IS TABLE OF VARCHAR2(22);
    name_table1 name_table := name_table();
    idx INTEGER;

    TYPE sort_table IS TABLE OF VARCHAR2(22) INDEX BY VARCHAR2(22);
    sort_table1 sort_table;
    idx_name VARCHAR2(22);

    v_proceedings proceedings%ROWTYPE;
    v_article article%ROWTYPE;
    v_book book%ROWTYPE;
    v_journal journal%ROWTYPE;

    e_noauthor EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_noauthor, -20000);
    e_nopublication EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nopublication, -20001);

    CURSOR cur_author_id1(p_name VARCHAR2) IS
        SELECT aid
        FROM author
        WHERE UPPER(name) = UPPER(p_name);

    CURSOR cur_wrote(p_aid VARCHAR2) IS
        SELECT pubid
        FROM wrote
        WHERE aid = p_aid;

    CURSOR cur_proceedings(p_pubid CHAR) IS
        SELECT * FROM proceedings
        WHERE pubid = p_pubid;

    CURSOR cur_book(p_pubid CHAR) IS
        SELECT * FROM book
        WHERE pubid = p_pubid;
    
    CURSOR cur_journal(p_pubid CHAR) IS
        SELECT * FROM journal
        WHERE pubid = p_pubid;

    CURSOR cur_article(p_pubid CHAR) IS
        SELECT * FROM article
        WHERE pubid = p_pubid;

    CURSOR cur_author_id2(p_pubid CHAR) IS 
        SELECT aid FROM wrote 
        WHERE pubid = p_pubid;

    CURSOR cur_author_name(p_aid VARCHAR2) IS 
        SELECT name FROM author 
        WHERE aid = p_aid;

    CURSOR cur_title(p_pubid CHAR) IS 
        SELECT title FROM publication 
        WHERE pubid = p_pubid;

BEGIN
    --Get author id--
    IF NOT cur_author_id1%ISOPEN THEN
        OPEN cur_author_id1(p_name);
    END IF;
    LOOP
        FETCH cur_author_id1 INTO v_aid;
        EXIT WHEN cur_author_id1%NOTFOUND;
    END LOOP;
    --Raise excpetion if no author found
    IF cur_author_id1%ROWCOUNT = 0 THEN
        RAISE e_noauthor;
    END IF;
    CLOSE cur_author_id1;

    --Get publication list--
    IF NOT cur_wrote%ISOPEN THEN
        OPEN cur_wrote(v_aid);
    END IF;
    LOOP
        FETCH cur_wrote INTO v_pubid;
        EXIT WHEN cur_wrote%NOTFOUND;
        --Add publication details into table
        IF v_found = 0 THEN
            --Get article details
            IF NOT cur_article%ISOPEN THEN
                OPEN cur_article(v_pubid);
            END IF;
            LOOP
                FETCH cur_article INTO v_article;
                EXIT WHEN cur_article%NOTFOUND;
                v_count_article := v_count_article+1;

                --Check if appears in book
                IF v_found_article = 0 THEN
                    IF NOT cur_book%ISOPEN THEN
                        OPEN cur_book(v_article.appearsin);
                    END IF;
                    LOOP
                        FETCH cur_book INTO v_book;
                        EXIT WHEN cur_book%NOTFOUND;
                        rec_pubid1.pubid := v_pubid;
                        rec_pubid1.year := v_book.year;
                        rec_pubid1.type := 'Article';
                        pubid_table1.EXTEND;
                        pubid_table1(pubid_table1.LAST) := rec_pubid1;
                        v_found_article := 1;
                        DBMS_OUTPUT.PUT_LINE(pubid_table1(pubid_table1.LAST).pubid);
                    END LOOP;
                    CLOSE cur_book;
                END IF;  

                --Check if appears in journal
                IF v_found_article = 0 THEN
                    IF NOT cur_journal%ISOPEN THEN
                        OPEN cur_journal(v_article.appearsin);
                    END IF;
                    LOOP
                        FETCH cur_journal INTO v_journal;
                        EXIT WHEN cur_journal%NOTFOUND;
                        rec_pubid1.pubid := v_pubid;
                        rec_pubid1.year := v_journal.year;
                        rec_pubid1.type := 'Article';
                        pubid_table1.EXTEND;
                        pubid_table1(pubid_table1.LAST) := rec_pubid1;
                        v_found_article := 1;
                    END LOOP;
                    CLOSE cur_journal;
                END IF;

                --Check if appears in proceedings
                IF v_found_article = 0 THEN
                    IF NOT cur_proceedings%ISOPEN THEN
                        OPEN cur_proceedings(v_article.appearsin);
                    END IF;
                    LOOP
                        FETCH cur_proceedings INTO v_proceedings;
                        EXIT WHEN cur_proceedings%NOTFOUND;
                        rec_pubid1.pubid := v_pubid;
                        rec_pubid1.year := v_proceedings.year;
                        rec_pubid1.type := 'Article';
                        pubid_table1.EXTEND;
                        pubid_table1(pubid_table1.LAST) := rec_pubid1;
                        v_found_article := 1;
                    END LOOP;
                    CLOSE cur_proceedings;
                END IF;

                v_found := 1;
                v_found_article := 0;

            END LOOP;            
            CLOSE cur_article;
        END IF;

        IF v_found = 0 THEN
            IF NOT cur_book%ISOPEN THEN
                OPEN cur_book(v_pubid);
            END IF;
            LOOP
                FETCH cur_book INTO v_book;
                EXIT WHEN cur_book%NOTFOUND;
                rec_pubid1.pubid := v_pubid;
                rec_pubid1.year := v_book.year;
                rec_pubid1.type := 'Book';
                pubid_table1.EXTEND;
                pubid_table1(pubid_table1.LAST) := rec_pubid1;
                v_count_book := v_count_book+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_book;
        END IF;

        IF v_found = 0 THEN
            IF NOT cur_journal%ISOPEN THEN
                OPEN cur_journal(v_pubid);
            END IF;
            LOOP
                FETCH cur_journal INTO v_journal;
                EXIT WHEN cur_journal%NOTFOUND;
                rec_pubid1.pubid := v_pubid;
                rec_pubid1.year := v_journal.year;
                rec_pubid1.type := 'Journal';
                pubid_table1.EXTEND;
                pubid_table1(pubid_table1.LAST) := rec_pubid1;
                v_count_journal := v_count_journal+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_journal;
        END IF;

        IF v_found = 0 THEN
            IF NOT cur_proceedings%ISOPEN THEN
                OPEN cur_proceedings(v_pubid);
            END IF;
            LOOP
                FETCH cur_proceedings INTO v_proceedings;
                EXIT WHEN cur_proceedings%NOTFOUND;
                rec_pubid1.pubid := v_pubid;
                rec_pubid1.year := v_proceedings.year;
                rec_pubid1.type := 'Proceedings';
                pubid_table1.EXTEND;
                pubid_table1(pubid_table1.LAST) := rec_pubid1;
                v_count_proceedings := v_count_proceedings+1;
                v_found := 1;
            END LOOP;
            CLOSE cur_proceedings; 
        END IF;

        v_found := 0;

    END LOOP;

    IF cur_wrote%ROWCOUNT = 0 THEN
        RAISE e_nopublication;
    ELSE 
        v_total_count := cur_wrote%ROWCOUNT;
    END IF;
    
    CLOSE cur_wrote;

    --Sort table with year
    FOR i IN pubid_table1.FIRST..pubid_table1.LAST-1 LOOP
        FOR j IN pubid_table1.FIRST..pubid_table1.LAST-1 LOOP
            IF pubid_table1(j).year > pubid_table1(j+1).year THEN
                temp := pubid_table1(j);
                pubid_table1(j) := pubid_table1(j+1);
                pubid_table1(j+1) := temp;
            END IF;
        END LOOP;
    END LOOP;

    --Print publication from sorted table
    FOR i IN pubid_table1.FIRST..pubid_table1.LAST LOOP
        --Print publication id
        DBMS_OUTPUT.PUT_LINE('Pubid: '|| pubid_table1(i).pubid);

        --Print publication type
        DBMS_OUTPUT.PUT_LINE('Type: '|| pubid_table1(i).type);

        --Get authors name into table
        DBMS_OUTPUT.PUT('Authors: ');
        --Get all authors who wrote this publication
        IF NOT cur_author_id2%ISOPEN THEN
            OPEN cur_author_id2(pubid_table1(i).pubid);
        END IF;
        LOOP
            FETCH cur_author_id2 INTO v_aid;
            EXIT WHEN cur_author_id2%NOTFOUND;
            --Get authors name
            IF NOT cur_author_name%ISOPEN THEN
                OPEN cur_author_name(v_aid);
            END IF;
            LOOP
                FETCH cur_author_name INTO v_name;
                EXIT WHEN cur_author_name%NOTFOUND;
                name_table1.EXTEND;
                name_table1(name_table1.LAST) := v_name;
            END LOOP;
            CLOSE cur_author_name;
        END LOOP;
        CLOSE cur_author_id2;

        --Sort author names in table
        idx := name_table1.FIRST;
        LOOP
            --sort_table is index by varchar2
            sort_table1(name_table1(idx)) := name_table1(idx);
            idx := name_table1.NEXT(idx);
            EXIT WHEN idx IS NULL;
        END LOOP;

        v_name := sort_table1.FIRST;
        LOOP
            DBMS_OUTPUT.PUT(v_name||'; ');
            v_name := sort_table1.NEXT(v_name);
            EXIT WHEN v_name IS NULL;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;

        --Print title
        IF NOT cur_title%ISOPEN THEN
            OPEN cur_title(pubid_table1(i).pubid);
        END IF;
        LOOP
            FETCH cur_title INTO v_title;
            EXIT WHEN cur_title%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Title: '|| v_title);
        END LOOP;
        CLOSE cur_title;

        --Print publication details
        CASE pubid_table1(i).type
            WHEN 'Article' THEN 
                --Get article details
                IF NOT cur_article%ISOPEN THEN
                    OPEN cur_article(pubid_table1(i).pubid);
                END IF;
                LOOP
                    FETCH cur_article INTO v_article;
                    EXIT WHEN cur_article%NOTFOUND;
                    IF v_found = 0 THEN
                        IF NOT cur_book%ISOPEN THEN
                            OPEN cur_book(v_article.appearsin);
                        END IF;
                        LOOP
                            FETCH cur_book INTO v_book;
                            EXIT WHEN cur_book%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE('Appears In Book: '|| v_article.appearsin);
                            DBMS_OUTPUT.PUT_LINE('Start Page: '|| v_article.startpage);
                            DBMS_OUTPUT.PUT_LINE('End Page: '|| v_article.endpage);
                            DBMS_OUTPUT.PUT_LINE('Publisher: '|| v_book.publisher);
                            DBMS_OUTPUT.PUT_LINE('Year: '|| v_book.year);
                            v_found := 1;
                        END LOOP;
                        CLOSE cur_book;
                    END IF;

                    IF v_found = 0 THEN
                        IF NOT cur_journal%ISOPEN THEN
                            OPEN cur_journal(v_article.appearsin);
                        END IF;
                        LOOP
                            FETCH cur_journal INTO v_journal;
                            EXIT WHEN cur_journal%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE('Appears In Journal: '|| v_article.appearsin);
                            DBMS_OUTPUT.PUT_LINE('Start Page: '|| v_article.startpage);
                            DBMS_OUTPUT.PUT_LINE('End Page: '|| v_article.endpage);
                            DBMS_OUTPUT.PUT_LINE('Volume: '|| v_journal.volume);
                            DBMS_OUTPUT.PUT_LINE('Number: '|| v_journal.num);
                            DBMS_OUTPUT.PUT_LINE('Year: '|| v_journal.year);
                            v_found := 1;
                        END LOOP;
                        CLOSE cur_journal;
                    END IF;

                    IF v_found = 0 THEN
                        IF NOT cur_proceedings%ISOPEN THEN
                            OPEN cur_proceedings(v_article.appearsin);
                        END IF;
                        LOOP
                            FETCH cur_proceedings INTO v_proceedings;
                            EXIT WHEN cur_proceedings%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE('Appears In Proceedings: '|| v_article.appearsin);
                            DBMS_OUTPUT.PUT_LINE('Start Page: '|| v_article.startpage);
                            DBMS_OUTPUT.PUT_LINE('End Page: '|| v_article.endpage);
                            DBMS_OUTPUT.PUT_LINE('Year: '|| v_proceedings.year);
                            v_found := 1;
                        END LOOP;
                        CLOSE cur_proceedings;
                    END IF;
                    v_found := 0;
                END LOOP;
                CLOSE cur_article;

            WHEN 'Book' THEN
                IF NOT cur_book%ISOPEN THEN
                    OPEN cur_book(pubid_table1(i).pubid);
                END IF;
                LOOP
                    FETCH cur_book INTO v_book;
                    EXIT WHEN cur_book%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('Publisher: '|| v_book.publisher);
                    DBMS_OUTPUT.PUT_LINE('Year: '||v_book.year);
                END LOOP;
                CLOSE cur_book;

            WHEN 'Journal' THEN
                IF NOT cur_journal%ISOPEN THEN
                    OPEN cur_journal(pubid_table1(i).pubid);
                END IF;
                LOOP
                    FETCH cur_journal INTO v_journal;
                    EXIT WHEN cur_journal%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('Volume: '|| v_journal.volume);
                    DBMS_OUTPUT.PUT_LINE('Number: '||v_journal.num);   
                    DBMS_OUTPUT.PUT_LINE('Year: '|| v_journal.year);
                END LOOP;
                CLOSE cur_journal;

            WHEN 'Proceedings' THEN
                IF NOT cur_proceedings%ISOPEN THEN
                    OPEN cur_proceedings(pubid_table1(i).pubid);
                END IF;
                LOOP
                    FETCH cur_proceedings INTO v_proceedings;
                    EXIT WHEN cur_proceedings%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('Year: '||v_proceedings.year);   
                END LOOP;
                CLOSE cur_proceedings;        
        END CASE;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    END LOOP;    
    
    --Print summary
    DBMS_OUTPUT.PUT_LINE('Proceedings: '||v_count_proceedings);   
    DBMS_OUTPUT.PUT_LINE('Journal: '||v_count_journal); 
    DBMS_OUTPUT.PUT_LINE('Article: '||v_count_article); 
    DBMS_OUTPUT.PUT_LINE('Book: '||v_count_book); 
    DBMS_OUTPUT.PUT_LINE('Total Publication: '||v_total_count); 

EXCEPTION
    WHEN e_noauthor THEN
        DBMS_OUTPUT.PUT_LINE('Error: Author does not exist in database.');
    WHEN e_nopublication THEN
        DBMS_OUTPUT.PUT_LINE('Error: Author has no publication.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code = #'|| SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Msg = '|| SQLERRM); 
END;
/