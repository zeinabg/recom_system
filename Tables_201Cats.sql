-- Users
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL,
    fb_login VARCHAR(255) NOT NULL UNIQUE
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
    watch_time TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id)
);

-- Likes
CREATE TABLE Likes (
    like_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    like_time TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id),
	UNIQUE (user_id, video_id)
);

-- Logins
CREATE TABLE Logins (
    login_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    login_time TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Suggested Videos
CREATE TABLE SuggestedVideos (
    suggestion_id INTEGER PRIMARY KEY,
    login_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    FOREIGN KEY (login_id) REFERENCES Logins(login_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id),
	UNIQUE (login_id, video_id)
);

-- Friends
CREATE TABLE Friends (
    friends_id INTEGER PRIMARY KEY,
    user_id1 INTEGER NOT NULL,
    user_id2 INTEGER NOT NULL,
    FOREIGN KEY (user_id1) REFERENCES Users(user_id),
    FOREIGN KEY (user_id2) REFERENCES Users(user_id),
	UNIQUE (user_id1, user_id2)
);
