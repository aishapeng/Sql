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
    --get author id
    SELECT aid INTO v_aid
    FROM author
    WHERE UPPER(name) = UPPER(p_name);

    --open publication cursor to get author publications
    IF NOT cur_publicationList%ISOPEN THEN
        OPEN cur_publicationList(v_aid);
    END IF;

    --process publication cursor for details
    LOOP
        --get publication id
        FETCH cur_publicationList INTO v_pubid;

        --check the cursor
        EXIT WHEN cur_publicationList%NOTFOUND;

        --print publication id
        DBMS_OUTPUT.PUT_LINE('Pubid: '|| v_pubid);

        --get publication type
        --check if type article
        IF v_found = 0 THEN
            --open article cursor to check if publication id exist in it
            IF NOT cur_article%ISOPEN THEN
                OPEN cur_article(v_pubid);
            END IF;

            --process article cursor
            LOOP
                FETCH cur_article INTO v_article;

                --check if publication id exist in article table
                EXIT WHEN cur_article%NOTFOUND;

                --if found
                v_type := 'Article';
                v_count_article := v_count_article+1;
                v_found := 1;
            END LOOP;

            --close the cursor
            CLOSE cur_article;

        --check if type book
        ELSIF v_found = 0 THEN
            --open book cursor to check if publication id exist in it
            IF NOT cur_book%ISOPEN THEN
                OPEN cur_book(v_pubid);
            END IF;

            --process book cursor
            LOOP
                FETCH cur_book INTO v_book;

                --check if publication id exist in article table
                EXIT WHEN cur_book%NOTFOUND;

                --if found
                v_type := 'Book';
                v_count_book := v_count_book+1;
                v_found := 1;
            END LOOP;

            --close the cursor
            CLOSE cur_book;

        --check if type journal
        ELSIF v_found = 0 THEN
            --open journal cursor to check if publication id exist in it
            IF NOT cur_journal%ISOPEN THEN
                OPEN cur_journal(v_pubid);
            END IF;

            --process book cursor
            LOOP
                FETCH cur_journal INTO v_journal;

                --check if publication id exist in article table
                EXIT WHEN cur_journal%NOTFOUND;

                --if found
                v_type := 'Journal';
                v_count_journal := v_count_journal+1;
                v_found := 1;
            END LOOP;

            --close the cursor
            CLOSE cur_journal;

        --check if type proceedings
        ELSIF v_found = 0 THEN
            --open proceedings cursor to check if publication id exist in it
            IF NOT cur_proceedings%ISOPEN THEN
                OPEN cur_proceedings(v_pubid);
            END IF;

            --process proceedings cursor
            LOOP
                FETCH cur_proceedings INTO v_proceedings;

                --check if publication id exist in article table
                EXIT WHEN cur_proceedings%NOTFOUND;

                --if found
                v_type := 'Proceedings';
                v_count_proceedings := v_count_proceedings+1;
                v_found := 1;
            END LOOP;

            --close the cursor
            CLOSE cur_proceedings;
        END IF;
        v_found := 0;

    --print authors
    DBMS_OUTPUT.PUT('Authors: ');
    FOR v_rec_author IN cur_author(v_aid) LOOP
        DBMS_OUTPUT.PUT_LINE(v_rec_author.name);
    END LOOP;

    --print title
    SELECT title INTO v_title 
    FROM publication WHERE v_pubid=pubid;

    --print publication details
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
    
    --print summary
    DBMS_OUTPUT.PUT_LINE('Proceedings: '||v_count_proceedings);   
    DBMS_OUTPUT.PUT_LINE('Journal: '||v_count_journal); 
    DBMS_OUTPUT.PUT_LINE('Article: '||v_count_article); 
    DBMS_OUTPUT.PUT_LINE('Book: '||v_count_book); 
    DBMS_OUTPUT.PUT_LINE('Total Publication: '||cur_publicationList%ROWCOUNT); 

    --close publication cursor
    CLOSE cur_publicationList;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('This author has no publication.');
     WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code = #'|| SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Msg = '|| SQLERRM); 
END;
/