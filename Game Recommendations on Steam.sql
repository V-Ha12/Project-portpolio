-- Xóa bảng
DROP TABLE GAMES

-- Tạo bảng GAMES
CREATE TABLE GAMES (
    app_id INT NOT NULL PRIMARY KEY,
    title NVARCHAR(255),
    date_release DATE,
    win BIT,
    mac BIT,
    linux BIT,
    rating CHAR(50),
    positive_ratio INT,
    user_reviews INT,
    price_final DECIMAL(7, 2),
    price_original DECIMAL(7, 2),
    discount DECIMAL(5, 1),
    steam_deck BIT
);

-- Tạo bảng USERS
CREATE TABLE USERS (
    user_id INT NOT NULL PRIMARY KEY,
    products INT,
    reviews INT
);

-- Tạo bảng RECOMMENDATIONS
CREATE TABLE RECOMMENDATIONS (
    app_id INT,
    helpful INT,
    funny INT,
    date DATE,
    is_recommended BIT,
    hours DECIMAL(7, 1),
    user_id INT,
    review_id INT,
    PRIMARY KEY (app_id, review_id),
    FOREIGN KEY (user_id) REFERENCES USERS (user_id),
    FOREIGN KEY (app_id) REFERENCES GAMES (app_id)
);

-- xóa dữ liệu trong bảng GAMES
DELETE FROM GAMES
DELETE FROM RECOMMENDATIONS
DELETE FROM USERS

-- INSERT bảng GAMES

