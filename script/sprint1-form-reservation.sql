-- Database Postgres 15
\c postgres
DROP DATABASE IF EXIST controltower;
CREATE DATABASE IF NOT EXIST controltower;
\c controltower
-- Table des sexe
CREATE TABLE IF NOT EXIST `sexe`(
    id SERIAL PRIMARY KEY,
    sexe VARCHAR(20),
    description VARCHAR(100)
);

-- Table Types de clients
CREATE TABLE IF NOT EXIST `type_client`(
    id SERIAL PRIMARY KEY,
    type VARCHAR(20),
    description VARCHAR(100)
);

-- Table des hotel 
CREATE TABLE IF NOT EXIST `hotel`(
    id SERIAL PRIMARY KEY,
    hotel VARCHAR(50),
    adress VARCHAR(50),
    contact VARCHAR(20)  
); 

-- Table des clients
CREATE TABLE IF NOT EXIST `client`(
    id SERIAL PRIMARY KEY,
    denomination VARCHAR(50), 
    sexe_id TINYINT(1) FOREIGN KEY REFERENCES sexe(id), 
    type_id TINYINT(2) -- Client divers ou ayant une souscription (ex: client ayant une carte de fidelité)
);

-- Table des reservations
CREATE TABLE IF NOT EXIST `reservation`(
    id SERIAL PRIMARY KEY, 
    numero VARCHAR(20),
    contact VARCHAR(50)
    client_id INT FOREIGN KEY REFERENCES client(id),
    hotel_id INT FOREIGN KEY REFERENCES hotel(id),
    passager TINYINT(2), -- nombre de passager pour le vehicule 
    date_arrival DATETIME 
);

