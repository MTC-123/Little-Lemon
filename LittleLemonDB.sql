-- =====================================================================
-- Little Lemon Restaurant Booking System
-- Meta Database Engineer Capstone Project
-- Database Schema + Stored Procedures
-- Generated from the MySQL Workbench data model (LittleLemonDM.mwb)
-- =====================================================================

DROP DATABASE IF EXISTS LittleLemonDB;
CREATE DATABASE LittleLemonDB;
USE LittleLemonDB;

-- =====================================================================
-- TABLES
-- =====================================================================

-- Customers: stores customer details
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100)
);

-- Staff: stores staff information including role and salary
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL
);

-- Bookings: stores table booking information
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    TableNumber INT NOT NULL,
    NumberOfGuests INT DEFAULT 2,
    CustomerID INT NOT NULL,
    StaffID INT,
    CONSTRAINT fk_bookings_customer FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bookings_staff FOREIGN KEY (StaffID)
        REFERENCES Staff (StaffID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Menus: stores menu information (cuisine categories)
CREATE TABLE Menus (
    MenuID INT AUTO_INCREMENT PRIMARY KEY,
    MenuName VARCHAR(100) NOT NULL,
    Cuisine VARCHAR(100) NOT NULL
);

-- MenuItems: stores individual dishes belonging to a menu
CREATE TABLE MenuItems (
    ItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    ItemType VARCHAR(50) NOT NULL,   -- Starter, Course, Dessert, Drink, Side
    Price DECIMAL(10,2) NOT NULL,
    MenuID INT NOT NULL,
    CONSTRAINT fk_items_menu FOREIGN KEY (MenuID)
        REFERENCES Menus (MenuID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Orders: stores order information linked to bookings and menus
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    Quantity INT NOT NULL,
    TotalCost DECIMAL(10,2) NOT NULL,
    CustomerID INT NOT NULL,
    BookingID INT,
    MenuID INT,
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orders_booking FOREIGN KEY (BookingID)
        REFERENCES Bookings (BookingID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_orders_menu FOREIGN KEY (MenuID)
        REFERENCES Menus (MenuID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- OrderDeliveryStatus: tracks delivery date and status of each order
CREATE TABLE OrderDeliveryStatus (
    DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    DeliveryDate DATE,
    Status VARCHAR(50) DEFAULT 'In Progress',
    CONSTRAINT fk_delivery_order FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================================
-- SAMPLE DATA
-- =====================================================================

INSERT INTO Customers (FullName, PhoneNumber, Email) VALUES
('Anna Iversen',  '351258074', 'anna.iversen@email.com'),
('Joakim Iversen','351258075', 'joakim.iversen@email.com'),
('Vanessa McCarthy','351258076','vanessa.mccarthy@email.com'),
('Marcos Romero', '351258077', 'marcos.romero@email.com'),
('Hiroki Yamane', '351258078', 'hiroki.yamane@email.com'),
('Diana Pinto',   '351258079', 'diana.pinto@email.com');

INSERT INTO Staff (FullName, Role, Salary) VALUES
('Mario Gollini',   'Manager',        70000.00),
('Adrian Gollini',  'Assistant Manager', 65000.00),
('Giorgos Dioudis', 'Head Chef',      50000.00),
('Fatma Kaya',      'Assistant Chef', 45000.00),
('Elena Salvai',    'Head Waiter',    40000.00),
('John Millar',     'Receptionist',   35000.00);

INSERT INTO Bookings (BookingDate, TableNumber, NumberOfGuests, CustomerID, StaffID) VALUES
('2022-10-10', 5, 2, 1, 5),
('2022-11-12', 3, 4, 3, 5),
('2022-10-11', 2, 2, 2, 6),
('2022-10-13', 2, 3, 1, 6);

INSERT INTO Menus (MenuName, Cuisine) VALUES
('Greek Classics',   'Greek'),
('Italian Favourites','Italian'),
('Turkish Delights', 'Turkish');

INSERT INTO MenuItems (ItemName, ItemType, Price, MenuID) VALUES
('Olives',        'Starter', 5.00, 1),
('Greek Salad',   'Course', 15.00, 1),
('Baklava',       'Dessert', 7.00, 1),
('Athens White Wine','Drink',25.00, 1),
('Flatbread',     'Starter', 5.00, 2),
('Pizza',         'Course', 15.00, 2),
('Cheesecake',    'Dessert', 8.00, 2),
('Corfu Red Wine','Drink',  30.00, 2),
('Hummus',        'Starter', 5.00, 3),
('Kabasa',        'Course', 17.00, 3),
('Turkish Coffee','Drink',  10.00, 3),
('Kunefe',        'Dessert', 8.00, 3);

INSERT INTO Orders (OrderDate, Quantity, TotalCost, CustomerID, BookingID, MenuID) VALUES
('2022-10-10', 2,  86.00, 1, 1, 2),
('2022-11-12', 1,  37.00, 3, 2, 1),
('2022-10-11', 3, 120.00, 2, 3, 3),
('2022-10-13', 2,  43.00, 1, 4, 1),
('2022-10-14', 1,  43.00, 4, NULL, 1),
('2022-10-15', 5, 260.00, 5, NULL, 2),
('2022-11-20', 4, 172.00, 6, NULL, 3);

INSERT INTO OrderDeliveryStatus (OrderID, DeliveryDate, Status) VALUES
(1, '2022-10-10', 'Delivered'),
(2, '2022-11-12', 'Delivered'),
(3, '2022-10-11', 'Delivered'),
(4, '2022-10-13', 'In Progress'),
(5, NULL,         'Preparing'),
(6, '2022-10-15', 'Delivered'),
(7, '2022-11-20', 'Delivered');

-- =====================================================================
-- STORED PROCEDURES
-- =====================================================================

-- ---------------------------------------------------------------------
-- GetMaxQuantity(): displays the maximum ordered quantity in Orders
-- Call: CALL GetMaxQuantity();
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS 'Max Quantity in Order'
    FROM Orders;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- ManageBooking(): checks whether a table is already booked on a
-- given date and returns its availability status.
-- Call: CALL ManageBooking('2022-11-12', 3);
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ManageBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE bookedCount INT;

    SELECT COUNT(*) INTO bookedCount
    FROM Bookings
    WHERE BookingDate = booking_date
      AND TableNumber = table_number;

    IF bookedCount > 0 THEN
        SELECT CONCAT('Table ', table_number,
                      ' is already booked on ', booking_date,
                      ' - booking cancelled') AS 'Booking Status';
    ELSE
        SELECT CONCAT('Table ', table_number,
                      ' is available on ', booking_date) AS 'Booking Status';
    END IF;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- AddBooking(): adds a new booking record.
-- Call: CALL AddBooking(9, 3, 4, '2022-12-30');
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE AddBooking(
    IN booking_id INT,
    IN customer_id INT,
    IN table_number INT,
    IN booking_date DATE)
BEGIN
    INSERT INTO Bookings (BookingID, BookingDate, TableNumber, CustomerID)
    VALUES (booking_id, booking_date, table_number, customer_id);

    SELECT 'New booking added' AS 'Confirmation';
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- UpdateBooking(): updates the date of an existing booking.
-- Call: CALL UpdateBooking(9, '2022-12-17');
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE UpdateBooking(IN booking_id INT, IN booking_date DATE)
BEGIN
    UPDATE Bookings
    SET BookingDate = booking_date
    WHERE BookingID = booking_id;

    SELECT CONCAT('Booking ', booking_id, ' updated') AS 'Confirmation';
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- CancelBooking(): cancels (deletes) an existing booking.
-- Call: CALL CancelBooking(9);
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE CancelBooking(IN booking_id INT)
BEGIN
    DELETE FROM Bookings
    WHERE BookingID = booking_id;

    SELECT CONCAT('Booking ', booking_id, ' cancelled') AS 'Confirmation';
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- AddValidBooking(): verifies a booking with a transaction; commits it
-- if the table is free, rolls back if the table is already booked.
-- Call: CALL AddValidBooking('2022-12-17', 6);
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE AddValidBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE bookedCount INT;

    START TRANSACTION;

    INSERT INTO Bookings (BookingDate, TableNumber, CustomerID)
    VALUES (booking_date, table_number, 1);

    SELECT COUNT(*) INTO bookedCount
    FROM Bookings
    WHERE BookingDate = booking_date
      AND TableNumber = table_number;

    IF bookedCount > 1 THEN
        ROLLBACK;
        SELECT CONCAT('Table ', table_number,
                      ' is already booked - booking cancelled') AS 'Booking Status';
    ELSE
        COMMIT;
        SELECT CONCAT('Table ', table_number,
                      ' booked for ', booking_date) AS 'Booking Status';
    END IF;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- CheckBooking(): reports the booking status of a table on a date.
-- Call: CALL CheckBooking('2022-11-12', 3);
-- ---------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE CheckBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE bookedCount INT;

    SELECT COUNT(*) INTO bookedCount
    FROM Bookings
    WHERE BookingDate = booking_date
      AND TableNumber = table_number;

    IF bookedCount > 0 THEN
        SELECT CONCAT('Table ', table_number, ' is already booked') AS 'Booking Status';
    ELSE
        SELECT CONCAT('Table ', table_number, ' is available') AS 'Booking Status';
    END IF;
END //
DELIMITER ;

-- =====================================================================
-- VIRTUAL TABLE (VIEW) AND ANALYSIS QUERIES
-- =====================================================================

-- OrdersView: orders with a quantity greater than 2
CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost AS Cost
FROM Orders
WHERE Quantity > 2;

-- =====================================================================
-- END OF FILE
-- =====================================================================
