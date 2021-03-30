CREATE OR REPLACE PROCEDURE print_publication 
(p_name VARCHAR2) AS
    v_aid VARCHAR2(38);
    v_pubid CHAR(10);
    v_name VARCHAR2(22);
    v_type CHAR(20);
    v_title CHAR(70);

    v_count_proceedings NUMBER := 0;
    v_count_journal NUMBER := 0;
    v_count_article NUMBER := 0;
    v_count_book NUMBER := 0;
    v_count_author NUMBER := 0;
    v_found NUMBER := 0;

    v_proceedings proceedings%ROWTYPE;
    v_article article%ROWTYPE;
    v_book book%ROWTYPE;
    v_journal journal%ROWTYPE;

    e_noauthor EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_noauthor, -20000);
    e_nopublication EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nopublication, -20001);

    CURSOR cur_authorid(p_name VARCHAR2) IS
        SELECT aid
        FROM author
        WHERE UPPER(name) = UPPER(p_name);

    CURSOR cur_publicationList(p_aid VARCHAR2) IS
        SELECT DISTINCT w.pubid, 
        CASE 
            WHEN w.pubid = p.pubid THEN 'Proceedings'
            WHEN w.pubid = b.pubid THEN 'Book'
            WHEN w.pubid = j.pubid THEN 'Journal'
            WHEN w.pubid = a.pubid THEN 'Article'
        END type
        FROM wrote w, proceedings p, book b, journal j, article a
        WHERE w.aid = p_aid
        AND(
            w.pubid = p.pubid OR
            w.pubid = b.pubid OR
            w.pubid = j.pubid OR
            w.pubid = a.pubid
        );

    CURSOR cur_proceedings(p_pubid CHAR) IS
        SELECT * FROM proceedings
        WHERE pubid = p_pubid
        ORDER BY year ASC;

    CURSOR cur_book(p_pubid CHAR) IS
        SELECT * FROM book
        WHERE pubid = p_pubid
        ORDER BY year ASC;

    CURSOR cur_journal(p_pubid CHAR) IS
        SELECT * FROM journal
        WHERE pubid = p_pubid
        ORDER BY year ASC;

    CURSOR cur_article(p_pubid CHAR) IS
        SELECT * FROM article
        WHERE pubid = p_pubid;

    CURSOR cur_author_name(p_pubid CHAR) IS 
        SELECT name FROM author a, wrote w
        WHERE a.aid = w.aid
        AND w.pubid = p_pubid
        ORDER BY name;

    CURSOR cur_title(p_pubid CHAR) IS 
        SELECT title FROM publication 
        WHERE pubid = p_pubid;

BEGIN
    --Get author id--
    IF NOT cur_authorid%ISOPEN THEN
        OPEN cur_authorid(p_name);
    END IF;
    LOOP
        FETCH cur_authorid INTO v_aid;
        EXIT WHEN cur_authorid%NOTFOUND;
    END LOOP;
    --Raise excpetion if no author found
    IF cur_authorid%ROWCOUNT = 0 THEN
        RAISE e_noauthor;
    END IF;
    CLOSE cur_authorid;

    --Get publication list
    IF NOT cur_publicationList%ISOPEN THEN
        OPEN cur_publicationList(v_aid);
    END IF;
    LOOP
        FETCH cur_publicationList INTO v_pubid, v_type;
        EXIT WHEN cur_publicationList%NOTFOUND;
        --Print publication id
        DBMS_OUTPUT.PUT_LINE('Pubid: '|| v_pubid);
        --Print publication type
        DBMS_OUTPUT.PUT_LINE('Type: '|| v_type);

        --Get publication details accoding to type
        CASE v_type
            WHEN 'Article' THEN
                IF NOT cur_article%ISOPEN THEN
                    OPEN cur_article(v_pubid);
                END IF;
                LOOP
                    FETCH cur_article INTO v_article;
                    EXIT WHEN cur_article%NOTFOUND;
                    --Print article details
                    DBMS_OUTPUT.PUT_LINE('Appears In: '|| v_article.appearsin);
                    DBMS_OUTPUT.PUT_LINE('Start Page: '||v_article.startpage);
                    DBMS_OUTPUT.PUT_LINE('End Page: '||v_article.endpage);
                    --Get appears in publication details
                    --Check if appears in journal
                    IF v_found = 0 THEN
                        IF NOT cur_journal%ISOPEN THEN
                            OPEN cur_journal(v_article.appearsin);
                        END IF;
                        LOOP
                            FETCH cur_journal INTO v_journal;
                            EXIT WHEN cur_journal%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE('-------------APPEARS IN JOURNAL-------------');
                            DBMS_OUTPUT.PUT_LINE('Volume: '|| v_journal.volume);
                            DBMS_OUTPUT.PUT_LINE('Number: '||v_journal.num);   
                            DBMS_OUTPUT.PUT_LINE('Year: '|| v_journal.year);
                        END LOOP;
                        CLOSE cur_journal;
                    
                    --Check if appears in book
                    ELSIF v_found = 0 THEN
                        IF NOT cur_book%ISOPEN THEN
                            OPEN cur_book(v_article.appearsin);
                        END IF;
                        LOOP
                            FETCH cur_book INTO v_book;
                            EXIT WHEN cur_book%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE('-------------APPEARS IN BOOK-------------');
                            DBMS_OUTPUT.PUT_LINE('Publisher: '|| v_book.publisher);
                            DBMS_OUTPUT.PUT_LINE('Year: '||v_book.year);
                        END LOOP;
                        CLOSE cur_book;
                    
                    --Check if appears in proceedings
                    ELSE
                        IF NOT cur_proceedings%ISOPEN THEN
                            OPEN cur_proceedings(v_article.appearsin);
                        END IF;
                        LOOP
                            FETCH cur_proceedings INTO v_proceedings;
                            EXIT WHEN cur_proceedings%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE('-------------APPEARS IN PROCEEDINGS------------');
                            DBMS_OUTPUT.PUT_LINE('Year: '||v_proceedings.year);   
                        END LOOP;
                        CLOSE cur_proceedings;

                    END IF;
                    v_count_article := v_count_article+1;
                END LOOP;
                CLOSE cur_article;
            WHEN 'Book' THEN
                IF NOT cur_book%ISOPEN THEN
                    OPEN cur_book(v_pubid);
                END IF;
                LOOP
                    FETCH cur_book INTO v_book;
                    EXIT WHEN cur_book%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('Publisher: '|| v_book.publisher);
                    DBMS_OUTPUT.PUT_LINE('Year: '||v_book.year);
                    v_count_book := v_count_book+1;
                END LOOP;
                CLOSE cur_book;
            WHEN 'Journal' THEN
                IF NOT cur_journal%ISOPEN THEN
                    OPEN cur_journal(v_pubid);
                END IF;
                LOOP
                    FETCH cur_journal INTO v_journal;
                    EXIT WHEN cur_journal%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('Volume: '|| v_journal.volume);
                    DBMS_OUTPUT.PUT_LINE('Number: '||v_journal.num);   
                    DBMS_OUTPUT.PUT_LINE('Year: '|| v_journal.year);
                    v_count_journal := v_count_journal+1;
                END LOOP;
                CLOSE cur_journal;
            WHEN 'Proceedings' THEN
                IF NOT cur_proceedings%ISOPEN THEN
                    OPEN cur_proceedings(v_pubid);
                END IF;
                LOOP
                    FETCH cur_proceedings INTO v_proceedings;
                    EXIT WHEN cur_proceedings%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('Year: '||v_proceedings.year);   
                    v_count_proceedings := v_count_proceedings+1;
                END LOOP;
                CLOSE cur_proceedings;        
            END CASE;

        --Print authors name
        DBMS_OUTPUT.PUT('Authors: ');
        IF NOT cur_author_name%ISOPEN THEN
            OPEN cur_author_name(v_pubid);
        END IF;
        LOOP
            FETCH cur_author_name INTO v_name;
            EXIT WHEN cur_author_name%NOTFOUND;
            DBMS_OUTPUT.PUT(v_name||'; ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        CLOSE cur_author_name;

        --Print title
        IF NOT cur_title%ISOPEN THEN
            OPEN cur_title(v_pubid);
        END IF;
        LOOP
            FETCH cur_title INTO v_title;
            EXIT WHEN cur_title%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Title: '||v_title);
        END LOOP;

    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

    END LOOP;

    IF cur_publicationList%ROWCOUNT = 0 THEN
        RAISE e_nopublication;
    END IF;
    
    --Print summary
    DBMS_OUTPUT.PUT_LINE('Proceedings: '||v_count_proceedings);   
    DBMS_OUTPUT.PUT_LINE('Journal: '||v_count_journal); 
    DBMS_OUTPUT.PUT_LINE('Article: '||v_count_article); 
    DBMS_OUTPUT.PUT_LINE('Book: '||v_count_book); 
    DBMS_OUTPUT.PUT_LINE('Total Publication: '||cur_publicationList%ROWCOUNT); 

    CLOSE cur_publicationList;

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