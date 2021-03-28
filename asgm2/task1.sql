CREATE OR REPLACE PROCEDURE print_publication 
(p_name VARCHAR2) AS
    v_aid VARCHAR2(38);
    v_pubid CHAR(10);
    v_type CHAR(20);
    v_title CHAR(70);
    v_found CHAR(1) := 0;

    v_count_proceedings NUMBER := 0;
    v_count_journal NUMBER := 0;
    v_count_article NUMBER := 0;
    v_count_book NUMBER := 0;

    v_proceedings proceedings%ROWTYPE;
    v_article article%ROWTYPE;
    v_book book%ROWTYPE;
    v_journal journal%ROWTYPE;

    CURSOR cur_publicationList(p_aid VARCHAR2) IS
        SELECT pubid FROM wrote
        WHERE aid = p_aid;

    CURSOR cur_proceedings(v_pubid CHAR) IS
        SELECT * FROM proceedings
        WHERE pubid = v_pubid;

    CURSOR cur_book(v_pubid CHAR) IS
        SELECT * FROM book
        WHERE pubid = v_pubid;

    CURSOR cur_journal(v_pubid CHAR) IS
        SELECT * FROM journal
        WHERE pubid = v_pubid;

    CURSOR cur_article(v_pubid CHAR) IS
        SELECT * FROM article
        WHERE pubid = v_pubid;
    
    CURSOR cur_author(p_aid VARCHAR2) IS 
        SELECT name FROM author 
        WHERE aid = p_aid
        ORDER BY name ASC;

BEGIN
    SELECT aid INTO v_aid
    FROM author
    WHERE UPPER(name) = UPPER(p_name);

    FOR v_rec IN cur_publicationList(v_aid) LOOP
        --pubid
        DBMS_OUTPUT.PUT_LINE('Pubid: '|| v_rec.pubid);
        
        --type
        IF v_found = 0 THEN
            FOR v_rec_article IN cur_article(v_rec.pubid) LOOP
                v_type := 'Article';
                v_article.appearsin := v_rec_article.appearsin;
                v_article.startpage := v_rec_article.startpage;
                v_article.endpage := v_rec_article.endpage;
                v_count_article := v_count_article+1;
                v_found := 1;
            END LOOP;
        ELSIF v_found = 0 THEN
            FOR v_rec_book IN cur_book(v_rec.pubid) LOOP
                v_type := 'Book';
                v_book.publisher := v_rec_book.publisher;
                v_book.year := v_rec_book.year;
                v_count_book := v_count_book+1;
                v_found := 1;
            END LOOP;
        ELSIF v_found = 0 THEN
            FOR v_rec_journal IN cur_journal(v_rec.pubid) LOOP
                v_type := 'Journal';
                v_journal.volume := v_rec_journal.volume;
                v_journal.num := v_rec_journal.num;
                v_journal.year := v_rec_journal.year;
                v_count_journal := v_count_journal+1;
                v_found := 1;
            END LOOP;
        ELSIF v_found = 0 THEN
            FOR v_rec_proceedings IN cur_proceedings(v_rec.pubid) LOOP
                v_type := 'Proceedings';
                v_proceedings.year := v_rec_proceedings.year;
                v_count_proceedings := v_count_proceedings+1;
                v_found := 1;
            END LOOP;
        END IF;
        v_found := 0;

        --authors
        DBMS_OUTPUT.PUT('Authors: ');
        FOR v_rec_author IN cur_author(v_aid) LOOP
            DBMS_OUTPUT.PUT_LINE(v_rec_author.name);
        END LOOP;

        --title
        SELECT title INTO v_title 
        FROM publication WHERE v_rec.pubid=pubid;

        --publication details
        CASE v_type
            WHEN 'Article' THEN
                DBMS_OUTPUT.PUT_LINE('Appears In: '|| v_article.appearsin);
                DBMS_OUTPUT.PUT_LINE('Start Page: '||v_article.startpage);
                DBMS_OUTPUT.PUT_LINE('End Page: '||v_article.endpage);
            WHEN 'Book' THEN
                DBMS_OUTPUT.PUT_LINE('Publisher: '|| v_book.publisher);
                DBMS_OUTPUT.PUT_LINE('Year: '||v_book.year);   
            WHEN 'Journal' THEN
                DBMS_OUTPUT.PUT_LINE('Volume: '|| v_journal.volume);
                DBMS_OUTPUT.PUT_LINE('Number: '||v_journal.num);   
                DBMS_OUTPUT.PUT_LINE('Year: '|| v_journal.year);
             WHEN 'Proceedings' THEN
                DBMS_OUTPUT.PUT_LINE('Year: '||v_proceedings.year);   
        END CASE;

        DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    END LOOP;
    
    --summary
    DBMS_OUTPUT.PUT_LINE('Proceedings: '||v_count_proceedings);   
    DBMS_OUTPUT.PUT_LINE('Journal: '||v_count_journal); 
    DBMS_OUTPUT.PUT_LINE('Article: '||v_count_article); 
    DBMS_OUTPUT.PUT_LINE('Book: '||v_count_book); 
    DBMS_OUTPUT.PUT_LINE('Total Publication: '||cur_publicationList%ROWCOUNT); 

--EXCEPTION
    --  WHEN OTHERS THEN
    --     DBMS_OUTPUT.PUT_LINE('Error Code = #'|| SQLCODE);
    --     DBMS_OUTPUT.PUT_LINE('Error Msg = '|| SQLERRM); 
END;
/