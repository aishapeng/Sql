CREATE TABLE publication_master(
    pubid CHAR(10),
    title CHAR(70),
    year NUMBER(38),
    volume NUMBER(38),
    num NUMBER(38),
    publisher CHAR(50),
    appearsin CHAR(10),
    startpage NUMBER(38),
    endpage NUMBER(38),
    type CHAR(20)
);

CREATE OR REPLACE PROCEDURE merge_publication AS 
    v_pubid CHAR(10);
    v_title CHAR(70);
    v_year NUMBER(38);
    v_volume NUMBER(38);
    v_num NUMBER(38);
    v_publisher CHAR(50);
    v_appearsin CHAR(10);
    v_startpage NUMBER(38);
    v_endpage NUMBER(38);
    v_found NUMBER := 0;

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

BEGIN
    --Get all publication id--
    IF NOT cur_publication%ISOPEN THEN
        OPEN cur_publication;
    END IF;
    LOOP
        FETCH cur_publication INTO v_pubid, v_title;
        EXIT WHEN cur_publication%NOTFOUND;
        
        --Insert proceedings details-- 
        IF v_found = 0 THEN
            IF NOT cur_proceedings%ISOPEN THEN
                OPEN cur_proceedings(v_pubid);
            END IF;
            LOOP
                FETCH cur_proceedings INTO v_year;
                EXIT WHEN cur_proceedings%NOTFOUND;
                INSERT INTO publication_master(pubid, title, year, type) 
                    VALUES(v_pubid, v_title, v_year, 'Proceedings');
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
                INSERT INTO publication_master(pubid, title, volume, num, year, type) 
                    VALUES(v_pubid, v_title, v_volume, v_num, v_year, 'Journal');
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
                INSERT INTO publication_master(pubid, title, publisher, year, type) 
                    VALUES(v_pubid, v_title, v_publisher, v_year, 'Book');
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
                INSERT INTO publication_master(pubid, title, appearsin, startpage, endpage, type) 
                    VALUES(v_pubid, v_title, v_appearsin, v_startpage, v_endpage, 'Article');
            v_found := 1;
            END LOOP;
            CLOSE cur_article;
        END IF;
        v_found := 0;

    END LOOP;
    CLOSE cur_publication;
END;
/
