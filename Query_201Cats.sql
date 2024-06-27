-- Users
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL,
    facebook_login VARCHAR(255) NOT NULL UNIQUE
);


-- Videos
CREATE TABLE Videos (
    video_id INTEGER PRIMARY KEY,
    video_title VARCHAR(255) NOT NULL
);


-- Watches
CREATE TABLE Watches (
    watch_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    watch_timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id)
);


-- Likes
CREATE TABLE Likes (
    like_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    like_timestamp TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id),
        UNIQUE (user_id, video_id)
);


-- Logins
CREATE TABLE Logins (
    login_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    login_timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


-- Suggested Videos
CREATE TABLE SuggestedVideos (
    suggestion_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    FOREIGN KEY (login_id) REFERENCES Logins(login_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id),
        UNIQUE (login_id, video_id)
);


-- Friends
CREATE TABLE Friendships (
    friendship_id INTEGER PRIMARY KEY,
    user_id1 INTEGER NOT NULL,
    user_id2 INTEGER NOT NULL,
    FOREIGN KEY (user_id1) REFERENCES Users(user_id),
    FOREIGN KEY (user_id2) REFERENCES Users(user_id),
        UNIQUE (user_id1, user_id2)
);



-- ANSWERS

-- # 1- Option “Overall Likes” 
-- The Top-10 cat videos are the ones
-- that have collected the highest numbers of likes, overall.


-- table for the videos that liked or watched by X

WITH LikedOrWatched_x AS(
    SELECT 
        video_id
    FROM 
        Users u 
    JOIN Likes l 
        ON u.user_id = l.user_id 
    WHERE u.user_name = 'X'

    UNION 
                
    SELECT 
        w.video_id
    FROM 
        Users u2
    JOIN Watches w 
        ON u2.user_id = w.user_id
    WHERE u2.user_name = 'X')
                
SELECT
    v.video_id,
    v.video_title,
    COUNT(l.like_id) as likes_count
FROM
    Videos v
JOIN
    Likes l ON v.video_id = l.video_id
WHERE
    NOT EXISTS (
        SELECT *
        FROM LikedOrWatched_x lw
        WHERE lw.video_id = v.video_id
    )
GROUP BY
    v.video_id, v.video_title
ORDER BY
    likes_count DESC
LIMIT 10;



-- #2- Option “Friend Likes”:
-- The Top-10 cat videos are the ones
-- that have collected the highest numbers of likes from the friends of X.


-- table for the videos that liked or watched by X

WITH LikedOrWatched_x AS(
    SELECT 
        video_id
    FROM 
        Users u 
    JOIN Likes l 
        ON u.user_id = l.user_id 
    WHERE u.user_name = 'X'

    UNION 
                
    SELECT 
        w.video_id
    FROM 
        Users u2
    JOIN Watches w 
        ON u2.user_id = w.user_id
    WHERE u2.user_name = 'X'),


-- table for X's friends by entering the user's name

x_friends AS (
        SELECT *
        FROM 
            Friendships fsh 
        JOIN Users u 
            ON u.user_id = fsh.user_id1
        WHERE u.user_name = 'X')


SELECT 
    v.video_id, 
    v.video_title, 
    COUNT(l.like_id) as likes_count
FROM  
    x_friends 
JOIN Likes l 
    ON x_friends.user_id2 = l.user_id 
JOIN Videos v 
    ON v.video_id = l.video_id
WHERE
    NOT EXISTS (
        SELECT *
        FROM 
            LikedOrWatched_x lw
        WHERE lw.video_id = v.video_id) 
GROUP BY v.video_id
ORDER BY COUNT(l.like_id) DESC
LIMIT 10;




-- #3- Option “Friends-of-Friends Likes”:
-- The Top-10 cat videos are the ones
-- that have collected the highest numbers of likes
-- from friends and friends-of-friends.


-- table for the videos that liked or watched by X

WITH LikedOrWatched_x AS(
    SELECT 
        video_id
    FROM 
        Users u 
    JOIN Likes l 
        ON u.user_id = l.user_id 
    WHERE u.user_name = 'X'

    UNION 
                
    SELECT 
        w.video_id
    FROM 
        Users u2
    JOIN Watches w 
        ON u2.user_id = w.user_id
    WHERE u2.user_name = 'X'),


-- table for finding X's friends
x_friends AS (
    SELECT 
        user_id2 AS x_f, 
        user_id1
    FROM 
        Friendships fsh 
    JOIN Users u 
        ON u.user_id = fsh.user_id1
    WHERE u.user_name = 'X'), 


-- table for finding friends of X’s friends        
        friends_of_friends  AS (
        SELECT *
        FROM 
            Friendships fsh 
        JOIN x_friends xf 
            ON xf.x_f = fsh.user_id1 
        JOIN Likes l 
        ON xf.x_f = l.user_id)


SELECT 
    v.video_id, 
    v.video_title, 
    COUNT (DISTINCT(l.like_id)) as likes_count_3
FROM 
    friends_of_friends ff,
    x_friends, 
    Likes l
JOIN Videos v 
    ON v.video_id = l.video_id
WHERE 
    (l.user_id = ff.user_id2 OR l.user_id = ff.x_f) 
    AND ff.user_id2 <> x_friends.user_id1
    AND NOT EXISTS (
        SELECT *
        FROM 
            LikedOrWatched_x lw
        WHERE lw.video_id = v.video_id) 
GROUP BY v.video_id
ORDER BY COUNT (DISTINCT(l.like_id)) DESC
LIMIT 10;




-- #4- Option “My kind of cats”:
-- The Top-10 cat videos are the ones
-- that have collected the most likes 
-- from users who have liked at least one cat video
-- that was liked by X.


WITH LikedOrWatched_x AS(
    SELECT 
        video_id
    FROM 
        Users u 
    JOIN Likes l 
        ON u.user_id = l.user_id 
    WHERE u.user_name = 'X'

    UNION 
                
    SELECT 
        w.video_id
    FROM 
        Users u2
    JOIN Watches w 
        ON u2.user_id = w.user_id
    WHERE u2.user_name = 'X'),

-- table of videos which user X liked. 
x_likes AS (
    SELECT 
        l.video_id AS x_videos,
        l.user_id AS x_id
        FROM 
            Users u 
        JOIN Likes l 
            ON l.user_id = u.user_id
        WHERE u.user_name = 'X'),
                                 
-- table of users who share at least one mutual like with user X.
mutual_users AS (
    SELECT 
        DISTINCT(l.user_id) AS mutual
    FROM Likes l 
    JOIN x_likes 
        ON l.video_id = x_likes.x_videos)
                                 
SELECT 
    v.video_id,
    v.video_title, 
    COUNT (DISTINCT(l.like_id)) as likes_count_4
FROM 
    mutual_users AS mu, 
    Likes l
JOIN Videos v 
    ON v.video_id = l.video_id
WHERE l.user_id = mu.mutual
AND NOT EXISTS (
        SELECT *
        FROM 
            LikedOrWatched_x lw
        WHERE lw.video_id = v.video_id)
GROUP BY v.video_id
ORDER BY COUNT(DISTINCT(l.like_id)) DESC
LIMIT 10;


-- #5 - Option “My kind of cats
-- with preference (to cat aficionados that have the same tastes)”

WITH

-- table for the videos that liked or watched by X
LikedOrWatched_x AS (
  (
    SELECT video_id
    FROM
          Users u 
      JOIN Likes l 
            ON u.user_id = l.user_id 
    WHERE u.user_name = 'X'
  )
  UNION
  (
        SELECT w.video_id
        FROM Users u2
          JOIN Watches w 
            ON u2.user_id = w.user_id
        WHERE u2.user_name = 'X'
  )
),

-- table for creating vector of likes for each user
Vectors AS (
  SELECT
    u.user_id,
        v.video_id,
        CASE WHEN l.like_id IS NULL THEN 0 ELSE 1 END AS liked 
  FROM
        Videos v
        CROSS JOIN Users u
        LEFT JOIN Likes l 
          ON v.video_id = l.video_id
          AND u.user_id = l.user_id
),

-- table for like vector of X
Liked_x AS (
  SELECT
        liked,
        v.video_id 
  FROM
        Vectors v
    JOIN Users u
      ON v.user_id = u.user_id
  WHERE u.user_name = 'X'
),

-- table for calculating the lc for X and every other user
lcXandOthers AS        (
  SELECT
        vec.user_id,
        LOG(1 + SUM(v_x.liked * vec.liked)) AS lc
  FROM
        Vectors vec
        LEFT JOIN Liked_x v_x
          ON v_x.video_id = vec.video_id
  GROUP BY vec.user_id
  ORDER BY lc DESC
)
SELECT
  l.video_id,
  SUM(lc.lc) AS Weighted_Like
FROM
  Likes l
  JOIN lcXandOthers lc 
    ON lc.user_id = l.user_id
WHERE NOT EXISTS (SELECT *
                  FROM 
                    LikedOrWatched_x lw
                  WHERE lw.video_id = l.video_id)
GROUP BY l.video_id
ORDER BY Weighted_Like DESC
LIMIT 10
; 
