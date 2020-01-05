-- phpMyAdmin SQL Dump
-- version 4.6.6
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 05 Sty 2020, 23:14
-- Wersja serwera: 10.3.18-MariaDB-50+deb10u1.cba
-- Wersja PHP: 7.1.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `bestbank`
--
CREATE DATABASE IF NOT EXISTS `bestbank` DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci;
USE `bestbank`;

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`bestbank`@`%` PROCEDURE `printA` ()  begin
  declare variable int;
  set variable = 3;
  
  select variable;
end$$

CREATE DEFINER=`bestbank`@`%` PROCEDURE `registerTransaction_byCompany` (IN `transactionNumber` VARCHAR(18), IN `payerAccountNumber` VARCHAR(26), IN `companyAccountNumber` VARCHAR(26), IN `companyName` VARCHAR(100), IN `companyStreet` VARCHAR(100), IN `companyStreetNumber` VARCHAR(5), IN `companyHouseOrFlatNo` VARCHAR(10), IN `companyPostalCode` VARCHAR(20), IN `companyCity` VARCHAR(100), IN `transactionTitle` VARCHAR(100), IN `transactionDate` DATE, IN `amount` DECIMAL(15,2))  begin
  declare payerLastName varchar(100);
  declare payerFirstName varchar(100);
  declare payerName varchar(200);

  declare payerEmail varchar(100);
  declare payerAreaCode varchar(20);
  declare payerPhoneNumber varchar(30);

  declare payerStreet varchar(100);
  declare payerStreetNumber varchar(5);
  declare payerHouseOrFlatNo varchar(10);
  declare payerPostalCode varchar(20);
  declare payerCity varchar(100);

  set payerLastName = (
    select
    LastName 
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerFirstName = (
    select
    FirstName
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );

  set payerName = concat(payerLastName, ' ', payerFirstName);
  
  set payerEmail = (
    select
    Email
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerAreaCode = (
    select
    AreaCode
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerPhoneNumber = (
    select
    PhoneNumber 
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  
  set payerStreet = (
    select 
    Street
    from AdrAll_TypeOfAdress_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerStreetNumber = (
    select 
    StreetNumber
    from AdrAll_TypeOfAdress_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerHouseOrFlatNo = (
    select 
    HouseOrFlatNo
    from AdrAll_TypeOfAdress_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerPostalCode = (
    select 
    PostalCode
    from AdrAll_TypeOfAdress_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerCity = (
    select 
    City
    from AdrAll_TypeOfAdress_AccNo
    where AccountNumber = payerAccountNumber
  );

  /*tym razem w ogóle nie przeprowadzamy procesu weryfikacji (w naszym banku nie ma kont firmowych)*/

  update Accounts
  set Balance = Balance - amount
  where AccountNumber = payerAccountNumber;

  insert into Transactions values(
    transactionNumber,
    'Transfer',
    null,
    payerAccountNumber,
    companyAccountNumber,
    payerName,
    payerStreet,
    payerStreetNumber,
    payerHouseOrFlatNo,
    payerPostalCode,
    payerCity,
    companyName,
    companyStreet,
    companyStreetNumber,
    companyHouseOrFlatNo,
    companyPostalCode,
    companyCity,
    transactionTitle,
    transactionDate,
    amount
  );
  insert into JunctionTable values(
    transactionNumber,
    payerAccountNumber
  );
  insert into TransactionHistories values(
    transactionNumber,
    payerEmail,
    payerAreaCode,
    payerPhoneNumber,
    null,
    null,
    null
  );
end$$

CREATE DEFINER=`bestbank`@`%` PROCEDURE `registerTransaction_byFullData` (IN `transactionNumber` CHAR(18), IN `payerAccountNumber` CHAR(26), IN `recipientAccountNumber` CHAR(26), IN `recipientLastName` VARCHAR(100), IN `recipientFirstName` VARCHAR(100), IN `recipientStreet` VARCHAR(100), IN `recipientStreetNumber` VARCHAR(5), IN `recipientHouseOrFlatNo` VARCHAR(10), IN `recipientPostalCode` VARCHAR(20), IN `recipientCity` VARCHAR(100), IN `transactionTitle` VARCHAR(100), IN `transactionDate` DATE, IN `amount` DECIMAL(15,2))  here:begin
  declare payerLastName varchar(100);
  declare payerFirstName varchar(100);
  declare payerName varchar(200);

  declare payerEmail varchar(100);
  declare payerAreaCode varchar(20);
  declare payerPhoneNumber varchar(30);

  declare payerStreet varchar(100);
  declare payerStreetNumber varchar(5);
  declare payerHouseOrFlatNo varchar(10);
  declare payerPostalCode varchar(20);
  declare payerCity varchar(100);

  declare isAdressActual varchar(8);
  declare doesAccountExist varchar(26);
  declare isAccountActual varchar(11);
  declare isDataCompatible varchar(30);
  
  declare recipientName varchar(200);

  declare recipientEmail varchar(100);
  declare recipientAreaCode varchar(20);
  declare recipientPhoneNumber varchar(30);

  set payerLastName = (
    select
    LastName 
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerFirstName = (
    select
    FirstName
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );

  set payerName = concat(payerLastName, ' ', payerFirstName);
  
  set payerEmail = (
    select
    Email
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerAreaCode = (
    select
    AreaCode
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerPhoneNumber = (
    select
    PhoneNumber 
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  
  set payerStreet = (
    select 
    Street
    from AdrAll_TypeOfAdress_AccNo
    where 
      AccountNumber = payerAccountNumber and 
      AdressStatus = 'Actual'
  );
  set payerStreetNumber = (
    select 
    StreetNumber
    from AdrAll_TypeOfAdress_AccNo
    where 
      AccountNumber = payerAccountNumber and 
      AdressStatus = 'Actual'
  );
  set payerHouseOrFlatNo = (
    select 
    HouseOrFlatNo
    from AdrAll_TypeOfAdress_AccNo
    where 
      AccountNumber = payerAccountNumber and 
      AdressStatus = 'Actual'
  );
  set payerPostalCode = (
    select 
    PostalCode
    from AdrAll_TypeOfAdress_AccNo
    where 
      AccountNumber = payerAccountNumber and 
      AdressStatus = 'Actual'
  );
  set payerCity = (
    select 
    City
    from AdrAll_TypeOfAdress_AccNo
    where 
      AccountNumber = payerAccountNumber and 
      AdressStatus = 'Actual'
  );
  
  set recipientName = concat(recipientLastName, ' ', recipientFirstName);
  
  if IBAN(recipientAccountNumber) = '12345678'
  then
    select
    AccountNumber
    into doesAccountExist
    from Accounts
    where AccountNumber = recipientAccountNumber;
    
    if doesAccountExist is null
    then
      select 'Transaction rejected, target account is not listed in the bank';
      leave here;
    end if;

    select
    AccountStatus
    into isAccountActual
    from Accounts
    where AccountNumber = recipientAccountNumber;

    if isAccountActual = 'Inactive'
    then
      select 'Transaction rejected, target account is no longer active in the bank';
      leave here;
    end if;

    select
    C.IdentityNumber
    into isDataCompatible
    from Adresses A join Customers C on A.IdentityNumber = C.IdentityNumber
                      join Accounts ACC on C.IdentityNumber = ACC.IdentityNumber
    where 
      AccountNumber = recipientAccountNumber and
      LastName = recipientLastName and
      FirstName = recipientFirstName and
      /*w tym przypadku sprawdzenie adresu odbiorcy następuje dokładnie w tym miejscu (bez konkretnego komunikatu)*/
      AdressType = 'Adress' and
      AdressStatus = 'Actual' and

      Street = recipientStreet and
      StreetNumber = recipientStreetNumber and
      HouseOrFlatNo = recipientHouseOrFlatNo and
      PostalCode = recipientPostalCode and
      City = recipientCity;
    
    if isDataCompatible is not null
    then
      if isDataCompatible = (
        select 
        IdentityNumber 
        from CustAll_AccNo 
        where AccountNumber = payerAccountNumber
      )
      then
        set recipientEmail = payerEmail;
        set recipientAreaCode = payerAreaCode;
        set recipientPhoneNumber = payerPhoneNumber;
      else
        set recipientEmail = (
          select
          Email
          from CustAll_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientAreaCode = (
          select
          AreaCode
          from CustAll_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientPhoneNumber = (
          select
          PhoneNumber 
          from CustAll_AccNo
          where AccountNumber = recipientAccountNumber
        );
      end if;

      update Accounts
      set Balance = Balance - amount
      where AccountNumber = payerAccountNumber;

      update Accounts
      set Balance = Balance + amount
      where AccountNumber = recipientAccountNumber;

      insert into Transactions values(
        transactionNumber,
        'Transfer',
        null,
        payerAccountNumber,
        recipientAccountNumber,
        payerName,
        payerStreet,
        payerStreetNumber,
        payerHouseOrFlatNo,
        payerPostalCode,
        payerCity,
        recipientName,
        recipientStreet,
        recipientStreetNumber,
        recipientHouseOrFlatNo,
        recipientPostalCode,
        recipientCity,
        transactionTitle,
        transactionDate,
        amount
      );
      
      if recipientEmail = payerEmail
      then
        update Transactions
        set TransactionType = 'Internal transfer'
        where TransactionNumber = transactionNumber;
      end if;

      insert into JunctionTable values(
        transactionNumber,
        payerAccountNumber
      );
      insert into JunctionTable values(
        transactionNumber,
        recipientAccountNumber
      );
      insert into TransactionHistories values(
        transactionNumber,
        payerEmail,
        payerAreaCode,
        payerPhoneNumber,
        recipientEmail,
        recipientAreaCode,
        recipientPhoneNumber
      );
    else
      select 'Transaction rejected, missmatching data for target account';
    end if;
  else
    update Accounts
    set Balance = Balance - amount
    where AccountNumber = payerAccountNumber;

    insert into Transactions values(
      transactionNumber,
      'Transfer',
      null,
      payerAccountNumber,
      recipientAccountNumber,
      payerName,
      payerStreet,
      payerStreetNumber,
      payerHouseOrFlatNo,
      payerPostalCode,
      payerCity,
      recipientName,
      recipientStreet,
      recipientStreetNumber,
      recipientHouseOrFlatNo,
      recipientPostalCode,
      recipientCity,
      transactionTitle,
      transactionDate,
      amount
    );
    insert into JunctionTable values(
      transactionNumber,
      payerAccountNumber
    );
    insert into TransactionHistories values(
      transactionNumber,
      payerEmail,
      payerAreaCode,
      payerPhoneNumber,
      null,
      null,
      null
    );
  end if;
end$$

CREATE DEFINER=`bestbank`@`%` PROCEDURE `registerTransaction_byNameOnly` (IN `transactionNumber` CHAR(18), IN `payerAccountNumber` CHAR(26), IN `recipientAccountNumber` CHAR(26), IN `recipientLastName` VARCHAR(100), IN `recipientFirstName` VARCHAR(100), IN `transactionTitle` VARCHAR(100), IN `transactionDate` DATE, IN `amount` DECIMAL(15,2))  here:begin
  /*reszta danych nadawcy*/
  declare payerLastName varchar(100);
  declare payerFirstName varchar(100);
  declare payerName varchar(200);

  declare payerEmail varchar(100);
  declare payerAreaCode varchar(20);
  declare payerPhoneNumber varchar(30);

  declare payerStreet varchar(100);
  declare payerStreetNumber varchar(5);
  declare payerHouseOrFlatNo varchar(10);
  declare payerPostalCode varchar(20);
  declare payerCity varchar(100);

  /*Kilka procesów weryfikacji - szczegółowe komunikaty:*/
  /*weryfikacja istnienia konta odbiorcy*/
  declare doesAccountExist varchar(26);
  /*weryfikacja aktualności konta odbiorcy*/
  declare isAccountActual varchar(11);
  /*weryfikacja zgodności danych odbiorcy*/
  declare isDataCompatible varchar(30);

  /*reszta danych odbiorcy*/
  declare recipientName varchar(200);

  declare recipientEmail varchar(100);
  declare recipientAreaCode varchar(20);
  declare recipientPhoneNumber varchar(30);

  declare recipientStreet varchar(100);
  declare recipientStreetNumber varchar(5);
  declare recipientHouseOrFlatNo varchar(10);
  declare recipientPostalCode varchar(20);
  declare recipientCity varchar(100);
  /*inicjalizacja zmiennych - uzupełnienie danych nadawcy na podstawie podanego nr konta*/
  set payerLastName = (
    select
    LastName 
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerFirstName = (
    select
    FirstName
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  /*pod format w tabeli transakcji*/
  set payerName = concat(payerLastName, ' ', payerFirstName);
  /*dane kontaktowe*/
  set payerEmail = (
    select
    Email
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerAreaCode = (
    select
    AreaCode
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  set payerPhoneNumber = (
    select
    PhoneNumber 
    from CustAll_AccNo
    where AccountNumber = payerAccountNumber
  );
  /*dane adresowe*/
  set payerStreet = (
    select 
    Street
    from AdrAll_TypeOfAdress_AccNo
    where
      AccountNumber = payerAccountNumber and
      AdressStatus = 'Actual'
  );
  set payerStreetNumber = (
    select 
    StreetNumber
    from AdrAll_TypeOfAdress_AccNo
    where
      AccountNumber = payerAccountNumber and
      AdressStatus = 'Actual'
  );
  set payerHouseOrFlatNo = (
    select 
    HouseOrFlatNo
    from AdrAll_TypeOfAdress_AccNo
    where
      AccountNumber = payerAccountNumber and
      AdressStatus = 'Actual'
  );
  set payerPostalCode = (
    select 
    PostalCode
    from AdrAll_TypeOfAdress_AccNo
    where
      AccountNumber = payerAccountNumber and
      AdressStatus = 'Actual'
  );
  set payerCity = (
    select 
    City
    from AdrAll_TypeOfAdress_AccNo
    where
      AccountNumber = payerAccountNumber and
      AdressStatus = 'Actual'
  );
  /*(dodatkowo)*/
  set recipientName = concat(recipientLastName, ' ', recipientFirstName);


  /*weryfikacja IBAN'u (czy konto należy do naszego banku)*/
  if IBAN(recipientAccountNumber) = '12345678'
  then
    /*weryfikacja istnienia konta odbiorcy*/
    select
    AccountNumber
    into doesAccountExist
    from Accounts
    where AccountNumber = recipientAccountNumber;
    
    if doesAccountExist is null
    then
      select 'Transaction rejected, target account is not listed in the bank';
      leave here;
    end if;
    /*weryfikacja aktualności konta odbiorcy*/
    select
    AccountStatus
    into isAccountActual
    from Accounts
    where AccountNumber = recipientAccountNumber;

    if isAccountActual = 'Inactive'
    then
      select 'Transaction rejected, target account is no longer active in the bank';
      leave here;
    end if;
    /*weryfikacja zgodności danych (czy dla takiego konta isnieje taki klient)*/
    /*zamiast IF EXISTS poniżej, stosujemy instrukcję SELECT INTO (ogarniczenie dostępu do zmiennych):*/
    select
    IdentityNumber
    into isDataCompatible
    from CustAll_AccNo
    where 
      AccountNumber = recipientAccountNumber and /*UNIQUE*/
      LastName = recipientLastName and
      FirstName = recipientFirstName;
    
    if isDataCompatible is not null
    then
      /*dopiero po weryfikacji zgodności podanych informacji sprawdzamy dodatkowo, czy nadawca to jednoczesnie odbiorca*/
      if isDataCompatible = (
        select 
        IdentityNumber 
        from CustAll_AccNo 
        where AccountNumber = payerAccountNumber
      )
      then
        /*uzupełnienie danych odbiorcy*/
        set recipientEmail = payerEmail;
        set recipientAreaCode = payerAreaCode;
        set recipientPhoneNumber = payerPhoneNumber;

        set recipientStreet = payerStreet;
        set recipientStreetNumber = payerStreetNumber;
        set recipientHouseOrFlatNo = payerHouseOrFlatNo;
        set recipientPostalCode = payerPostalCode;
        set recipientCity = payerCity;
      else
        set recipientEmail = (
          select
          Email
          from CustAll_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientAreaCode = (
          select
          AreaCode
          from CustAll_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientPhoneNumber = (
          select
          PhoneNumber 
          from CustAll_AccNo
          where AccountNumber = recipientAccountNumber
        );
        
        set recipientStreet = (
          select 
          Street
          from AdrAll_TypeOfAdress_AccNo
          where 
            AccountNumber = recipientAccountNumber and 
            AdressStatus = 'Actual'
        );
        set recipientStreetNumber = (
          select 
          StreetNumber
          from AdrAll_TypeOfAdress_AccNo
          where 
            AccountNumber = recipientAccountNumber and 
            AdressStatus = 'Actual'
        );
        set recipientHouseOrFlatNo = (
          select 
          HouseOrFlatNo
          from AdrAll_TypeOfAdress_AccNo
          where 
            AccountNumber = recipientAccountNumber and 
            AdressStatus = 'Actual'
        );
        set recipientPostalCode = (
          select 
          PostalCode
          from AdrAll_TypeOfAdress_AccNo
          where 
            AccountNumber = recipientAccountNumber and 
            AdressStatus = 'Actual'
        );
        set recipientCity = (
          select 
          City
          from AdrAll_TypeOfAdress_AccNo
          where 
            AccountNumber = recipientAccountNumber and 
            AdressStatus = 'Actual'
        );
      end if;

      update Accounts
      set Balance = Balance - amount
      where AccountNumber = payerAccountNumber;

      update Accounts
      set Balance = Balance + amount
      where AccountNumber = recipientAccountNumber;

      insert into Transactions values(
        transactionNumber,
        'Transfer',
        null,
        payerAccountNumber,
        recipientAccountNumber,
        payerName,
        payerStreet,
        payerStreetNumber,
        payerHouseOrFlatNo,
        payerPostalCode,
        payerCity,
        recipientName,
        recipientStreet,
        recipientStreetNumber,
        recipientHouseOrFlatNo,
        recipientPostalCode,
        recipientCity,
        transactionTitle,
        transactionDate,
        amount
      );
      /*dla transferu wewn., przeprowadzonego jako zwykłą transakcję*/
      if recipientEmail = payerEmail
      then
        update Transactions
        set TransactionType = 'Internal transfer'
        where TransactionNumber = transactionNumber;
      end if;

      insert into JunctionTable values(
        transactionNumber,
        payerAccountNumber
      );
      insert into JunctionTable values(
        transactionNumber,
        recipientAccountNumber
      );
      insert into TransactionHistories values(
        transactionNumber,
        payerEmail,
        payerAreaCode,
        payerPhoneNumber,
        recipientEmail,
        recipientAreaCode,
        recipientPhoneNumber
      );
    /*jeśli dane nie pasują do konta*/
    else
      /*bez konkretnego komunikatu (np. wrong name/surname match for an existing account)*/
      select 'Transaction rejected, missmatching data for target account';
    end if;
  /*jeśli w naszym banku nie ma takiego konta*/  
  else
    /*(nie ma możliwości uzupełnienia danych)*/

    update Accounts
    set Balance = Balance - amount
    where AccountNumber = payerAccountNumber;

    insert into Transactions values(
      transactionNumber,
      'Transfer',
      null,
      payerAccountNumber,
      recipientAccountNumber,
      payerName,
      payerStreet,
      payerStreetNumber,
      payerHouseOrFlatNo,
      payerPostalCode,
      payerCity,
      recipientName,
      null,
      null,
      null,
      null,
      null,
      transactionTitle,
      transactionDate,
      amount
    );
    insert into JunctionTable values(
      transactionNumber,
      payerAccountNumber
    );
    insert into TransactionHistories values(
      transactionNumber,
      payerEmail,
      payerAreaCode,
      payerPhoneNumber,
      null,
      null,
      null
    );
  end if;
end$$

CREATE DEFINER=`bestbank`@`%` PROCEDURE `registerTransaction_internal` (IN `transactionNumber` VARCHAR(18), IN `sourceAccountNumber` VARCHAR(26), IN `targetAccountNumber` VARCHAR(26), IN `transactionTitle` VARCHAR(100), IN `transactionDate` DATE, IN `amount` DECIMAL(15,2))  begin
  declare customerName varchar(200);

  declare customerEmail varchar(100);
  declare customerAreaCode varchar(20);
  declare customerPhoneNumber varchar(30);

  declare customerStreet varchar(100);
  declare customerStreetNumber varchar(5);
  declare customerHouseOrFlatNo varchar(10);
  declare customerPostalCode varchar(20);
  declare customerCity varchar(100);

  set customerName = concat(
    (select LastName from CustAll_AccNo where AccountNumber like sourceAccountNumber), ' ',
    (select FirstName from CustAll_AccNo where AccountNumber like sourceAccountNumber)
  );

  /*alternatywnie*/

  select
  Email
  into customerEmail
  from CustAll_AccNo
  where AccountNumber like sourceAccountNumber;

  select
  AreaCode
  into customerAreaCode
  from CustAll_AccNo
  where AccountNumber like sourceAccountNumber;

  select
  PhoneNumber
  into customerPhoneNumber
  from CustAll_AccNo
  where AccountNumber like sourceAccountNumber;

  select
  Street
  into customerStreet
  from AdrAll_TypeOfAdress_AccNo
  where 
    AccountNumber like sourceAccountNumber and
    AdressStatus like 'Actual';

  select
  StreetNumber
  into customerStreetNumber
  from AdrAll_TypeOfAdress_AccNo
  where 
    AccountNumber like sourceAccountNumber and
    AdressStatus like 'Actual';

  select
  HouseOrFlatNo
  into customerHouseOrFlatNo
  from AdrAll_TypeOfAdress_AccNo
  where 
    AccountNumber like sourceAccountNumber and
    AdressStatus like 'Actual';

  select
  PostalCode
  into customerPostalCode
  from AdrAll_TypeOfAdress_AccNo
  where 
    AccountNumber like sourceAccountNumber and
    AdressStatus like 'Actual';

  select
  City
  into customerCity
  from AdrAll_TypeOfAdress_AccNo
  where 
    AccountNumber like sourceAccountNumber and
    AdressStatus like 'Actual';

  /*
  Tutaj weryfikacja też jest zbędna, gdyż konto wyświetla się w zakładce kont użytkownika,
  stąd pewność, że jest on jego właścicielem (należy ono do naszego banku).
  
  Wszystkie pozostałe dane traktujemy jak dane nadawcy, które nie są sprawdzane przez procedury.
  */

  update Accounts
  set Balance = Balance - amount
  where AccountNumber like sourceAccountNumber;

  update Accounts
  set Balance = Balance + amount
  where AccountNumber like targetAccountNumber;

  insert into Transactions values(
    transactionNumber,
    'Internal transfer',
    null,
    sourceAccountNumber,
    targetAccountNumber,
    customerName,
    customerStreet,
    customerStreetNumber,
    customerHouseOrFlatNo,
    customerPostalCode,
    customerCity,
    customerName,
    customerStreet,
    customerStreetNumber,
    customerHouseOrFlatNo,
    customerPostalCode,
    customerCity,
    transactionTitle,
    transactionDate,
    amount
  );

  insert into JunctionTable values(
    transactionNumber,
    sourceAccountNumber
  );

  insert into JunctionTable values(
    transactionNumber,
    targetAccountNumber
  );

  insert into TransactionHistories values(
    transactionNumber,
    customerEmail,
    customerAreaCode,
    customerPhoneNumber,
    customerEmail,
    customerAreaCode,
    customerPhoneNumber
  );
end$$

CREATE DEFINER=`bestbank`@`%` PROCEDURE `whatIf` (`variablee` INT)  here:begin
  if variablee not like 1
  then
    select 'is not equal';
    leave here;
  end if;

  select 'is equal';
end$$

--
-- Funkcje
--
CREATE DEFINER=`bestbank`@`%` FUNCTION `IBAN` (`accountNumber` CHAR(26)) RETURNS CHAR(8) CHARSET latin1 COLLATE latin1_general_ci begin
  return substring(accountNumber, 3, 8);
  /*substring w MySQL'u działa inaczej niż w Javie czy C# (nie wg indexow a miejsc poszczególnych liter)*/
end$$

CREATE DEFINER=`bestbank`@`%` FUNCTION `substractionTest` (`a` DECIMAL(4,2), `b` DECIMAL(4,2)) RETURNS DECIMAL(4,2) begin
  return a - b;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Accounts`
--

CREATE TABLE `Accounts` (
  `AccountNumber` char(26) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `Accounts`
--

INSERT INTO `Accounts` VALUES('26123456785647385647382905', 'Personal account', '74062456789', 'My personal account', '5000.00', '2019-11-19', 'Active', NULL);
INSERT INTO `Accounts` VALUES('26123456785647385612341234', 'Savings account', '74062456789', 'My savings', '5000.00', '2019-11-19', 'Active', NULL);
INSERT INTO `Accounts` VALUES('86123456784480249024505678', 'Personal account', '76062809876', 'My personal account', '5000.00', '2019-11-19', 'Active', NULL);
INSERT INTO `Accounts` VALUES('86123456784480249024505679', 'Personal account', '100', 'Official account', '5000.00', '2019-11-21', 'Active', NULL);
INSERT INTO `Accounts` VALUES('95123456781606653336132083', 'Comfort', '101', 'Trump Tower', '5000.00', '2019-12-03', 'Active', NULL);
INSERT INTO `Accounts` VALUES('86123456784480249024505681', 'Personal account', '100', 'My personal account', '5000.00', '2019-11-21', 'Active', NULL);
INSERT INTO `Accounts` VALUES('97123456789691638460799348', 'Comfort', '100', 'White House', '5000.00', '2019-12-02', 'Active', NULL);
INSERT INTO `Accounts` VALUES('86123456784480249024517243', 'Savings account', '100', 'Trump Tower', '5000.00', '2019-12-01', 'Active', NULL);
INSERT INTO `Accounts` VALUES('70123456784963191893366459', 'Personal account', '5555555555', 'PersAcc', '5000.00', '2019-12-18', 'Active', NULL);
INSERT INTO `Accounts` VALUES('38123456786965032100832764', 'Personal account', '68053045678', 'Direct', '5000.00', '2019-12-03', 'Active', NULL);
INSERT INTO `Accounts` VALUES('07123456787809723424004007', 'Comfort', '22', 'Name', '5000.00', '2019-12-15', 'Active', NULL);
INSERT INTO `Accounts` VALUES('75123456785167548074819593', 'Savings account', '5555555555', 'Savings', '5000.00', '2019-12-18', 'Active', NULL);
INSERT INTO `Accounts` VALUES('16123456785605997505461833', 'Comfort', '5555555555', 'Comfort', '5000.00', '2019-12-19', 'Active', NULL);
INSERT INTO `Accounts` VALUES('22123456785333266384724107', 'Comfort', '12345678912', 'Comfort Account', '5000.00', '2019-12-24', 'Active', NULL);
INSERT INTO `Accounts` VALUES('86123456785210352157532332', 'Comfort', '55555555555', 'comfort', '5000.00', '2019-12-21', 'Active', NULL);
INSERT INTO `Accounts` VALUES('43123456785275387631494265', 'Savings account', '12345678912', 'Savings Account', '4850.01', '2019-12-24', 'Active', NULL);
INSERT INTO `Accounts` VALUES('96123456781373788056603850', 'Personal account', '12345678912', 'Personal Account', '5149.99', '2019-12-24', 'Active', NULL);
INSERT INTO `Accounts` VALUES('22123456787480259462996291', 'Personal account', '55555555555', 'Personal', '5000.00', '2020-01-04', 'Active', NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `AccountTypes`
--

CREATE TABLE `AccountTypes` (
  `AccountType` varchar(16) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `AccountTypes`
--

INSERT INTO `AccountTypes` VALUES('Comfort');
INSERT INTO `AccountTypes` VALUES('Personal account');
INSERT INTO `AccountTypes` VALUES('Savings account');

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `AdrAll_TypeOfAdress_AccNo`
-- (See below for the actual view)
--
CREATE TABLE `AdrAll_TypeOfAdress_AccNo` (
`AdressID` smallint(6)
,`IdentityNumber` varchar(30)
,`AdressType` varchar(21)
,`Street` varchar(100)
,`StreetNumber` varchar(5)
,`HouseOrFlatNo` varchar(10)
,`PostalCode` varchar(20)
,`City` varchar(100)
,`Country` varchar(100)
,`AdressEntryDate` date
,`AdressStatus` varchar(11)
,`AdressChangeDate` date
,`AccountNumber` char(26)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Adresses`
--

CREATE TABLE `Adresses` (
  `AdressID` smallint(6) NOT NULL,
  `IdentityNumber` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `AdressType` varchar(21) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `Adresses`
--

INSERT INTO `Adresses` VALUES(1, '74062456789', 'Adress', 'Second', '56', 'a', '94203', 'Beverly Hills', 'United States', '2019-11-19', 'Actual', NULL);
INSERT INTO `Adresses` VALUES(2, '74062456789', 'Correspondence adress', 'Second', '56', 'a', '94203', 'Beverly Hills', 'United States', '2019-11-19', 'Actual', NULL);
INSERT INTO `Adresses` VALUES(3, '74062456789', 'Registered adress', 'Second', '56', 'a', '94203', 'Beverly Hills', 'United States', '2019-11-19', 'Actual', NULL);
INSERT INTO `Adresses` VALUES(4, '76062809876', 'Adress', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'United States', '2019-11-19', 'Actual', NULL);
INSERT INTO `Adresses` VALUES(5, '76062809876', 'Correspondence adress', 'Palm', '12', '6', '90003', 'Los Angeles', 'United States', '2019-11-19', 'Actual', NULL);
INSERT INTO `Adresses` VALUES(6, '76062809876', 'Registered adress', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'United States', '2019-11-19', 'Actual', NULL);
INSERT INTO `Adresses` VALUES(7, '100', 'Adress', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'USA', '2019-12-29', 'Actual', NULL);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `ATM_Payments`
-- (See below for the actual view)
--
CREATE TABLE `ATM_Payments` (
`TransactionNumber` char(18)
,`PayerCardNumber` char(16)
,`PayerName` varchar(200)
,`ATM adress line 1` varchar(100)
,`ATM adress line 2` varchar(5)
,`ATM adress line 3` varchar(100)
,`RecipientAccountNumber` char(26)
,`RecipientName` varchar(200)
,`RecipientStreet` varchar(100)
,`RecipientStreetNumber` varchar(5)
,`RecipientHouseOrFlatNo` varchar(10)
,`RecipientPostalCode` varchar(20)
,`RecipientCity` varchar(100)
,`TransactionTitle` varchar(100)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `CardTypes`
--

CREATE TABLE `CardTypes` (
  `CardType` varchar(12) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `CardTypes`
--

INSERT INTO `CardTypes` VALUES('Debit card');
INSERT INTO `CardTypes` VALUES('Payment card');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `CreditCards`
--

CREATE TABLE `CreditCards` (
  `CardNumber` char(16) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `CreditCards`
--

INSERT INTO `CreditCards` VALUES('4215658072204550', 'Payment card', '26123456785647385647382905', '2023-11-19', '345', '2019-11-19', 'Active', NULL);
INSERT INTO `CreditCards` VALUES('4215654765890767', 'Debit card', '26123456785647385647382905', '2023-11-19', '870', '2019-11-19', 'Active', NULL);
INSERT INTO `CreditCards` VALUES('4215658012341234', 'Debit card', '86123456784480249024505678', '2023-11-19', '210', '2019-11-20', 'Active', NULL);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `CustAll_AccNo`
-- (See below for the actual view)
--
CREATE TABLE `CustAll_AccNo` (
`IdentityNumber` varchar(30)
,`Email` varchar(100)
,`LastName` varchar(100)
,`FirstName` varchar(100)
,`BirthDate` date
,`AreaCode` varchar(20)
,`PhoneNumber` varchar(30)
,`TitleOfCourtesy` varchar(4)
,`UserName` char(10)
,`UserPassword` varchar(72)
,`RegisterDate` date
,`ProfileStatus` varchar(8)
,`AccountNumber` char(26)
);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `CustLNFN_AdrAll`
-- (See below for the actual view)
--
CREATE TABLE `CustLNFN_AdrAll` (
`LastName` varchar(100)
,`FirstName` varchar(100)
,`AdressID` smallint(6)
,`IdentityNumber` varchar(30)
,`AdressType` varchar(21)
,`Street` varchar(100)
,`StreetNumber` varchar(5)
,`HouseOrFlatNo` varchar(10)
,`PostalCode` varchar(20)
,`City` varchar(100)
,`Country` varchar(100)
,`AdressEntryDate` date
,`AdressStatus` varchar(11)
,`AdressChangeDate` date
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Customers`
--

CREATE TABLE `Customers` (
  `IdentityNumber` varchar(30) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `Customers`
--

INSERT INTO `Customers` VALUES('74062456789', 'willsmith20@netpost.com', 'Smith', 'William', '1974-06-24', '+1', '456567678', 'Mr.', 'wilsmi0011', 'peanutButter20', '2019-11-19', 'Active');
INSERT INTO `Customers` VALUES('76062809876', 'annawhite@netpost.com', 'White', 'Anna', '1976-06-28', '+1', '765654543', 'Mrs.', 'annwhi0022', 'mynamesAnna15', '2019-11-19', 'Active');
INSERT INTO `Customers` VALUES('22', 'aa@aa.aa', 'Last', 'First', '0000-00-00', '+0', '000000000', 'Mr.', 'firlas0001', '$2y$10$.IpPdWsiL7MbCsaiL.3V5eYAPko7UDDzXB5rTFQzRPR6e97yW3vje', '2019-12-15', 'Inactive');
INSERT INTO `Customers` VALUES('100', 'president@usa.gov', 'Trump', 'Donald', '1946-06-14', '1', '100', 'Mr.', 'dontru0001', '$2y$10$41pAmQszWxFSZCuU0J3S7.aoEFEydfavWnpEFYw7g6qGBtzk9HwKK', '2019-11-29', 'Active');
INSERT INTO `Customers` VALUES('00000000001', 'asfa@gmail.com', 'Malysz', 'Adam', '1924-02-02', '+1', '765654541', 'Mr.', 'adamal0001', '$2y$10$5LqPDQG8B2SKUnNfaR.c6.yOyQWmrEk5oaIhIfEpO21pOSv3zt1Xi', '2019-11-28', 'Active');
INSERT INTO `Customers` VALUES('101', 'realdonaldtrump@twitter.com', 'Trump', 'Donald', '1111-11-11', '+1', '101', 'Mr.', 'dontru0002', '$2y$10$ixZ5kohI85MRAg3xRVNEhOHPXJAvRTx0Ew49HTMPe7T7oWlnpksma', '2019-12-01', 'Active');
INSERT INTO `Customers` VALUES('68053045678', 'newwillsmith@netpost.com', 'Smith', 'Will', '1969-04-24', '03020', '777666876', 'Mr.', 'wilsmi0002', '$2y$10$oD1wK7DsIFAlSik70isW2eg8jexARzRuLYi8d5Jy4oC42C6wKNDHu', '2019-12-03', 'Active');
INSERT INTO `Customers` VALUES('55555555555', 'hdjzjs@gmail.com', 'Koww', 'Adam', '1998-11-28', '+1', '986532659', 'Mr.', 'adakow0001', '$2y$10$cvvNBr67Xyan9.RhLaKvBuY6H/WjkU27a/To0B5E5lob/KHnEpHXK', '2020-01-04', 'Active');
INSERT INTO `Customers` VALUES('12345678912', 'jankowalski@gmail.com', 'Kowalski', 'Jan', '1998-11-20', '+1', '356298673', 'Mr.', 'jankow0001', '$2y$10$Pi5mA8ybGPCXV//kDXguH.49hs46Yqz.CRoVueTxQX5aoccUIsYom', '2019-12-24', 'Active');

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `CustomersWealth`
-- (See below for the actual view)
--
CREATE TABLE `CustomersWealth` (
`FirstName` varchar(100)
,`LastName` varchar(100)
,`AccountNumber` char(26)
,`Balance` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Devices`
--

CREATE TABLE `Devices` (
  `DeviceID` varchar(200) COLLATE latin1_general_ci NOT NULL,
  `IdentityNumber` varchar(30) COLLATE latin1_general_ci NOT NULL
) ;

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `ForeignTransactions`
-- (See below for the actual view)
--
CREATE TABLE `ForeignTransactions` (
`TransactionNumber` char(18)
,`PayerAccountNumber` char(26)
,`PayerName` varchar(200)
,`RecipientAccountNumber` char(26)
,`RecipientName` varchar(200)
,`RecipientStreet` varchar(100)
,`RecipientStreetNumber` varchar(5)
,`RecipientHouseOrFlatNo` varchar(10)
,`RecipientPostalCode` varchar(20)
,`RecipientCity` varchar(100)
,`TransactionTitle` varchar(100)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `InternalTransactions`
-- (See below for the actual view)
--
CREATE TABLE `InternalTransactions` (
`TransactionNumber` char(18)
,`PayerAccountNumber` char(26)
,`PayerName` varchar(200)
,`PayerStreet` varchar(100)
,`PayerStreetNumber` varchar(5)
,`PayerHouseOrFlatNo` varchar(10)
,`PayerPostalCode` varchar(20)
,`PayerCity` varchar(100)
,`RecipientAccountNumber` char(26)
,`RecipientName` varchar(200)
,`RecipientStreet` varchar(100)
,`RecipientStreetNumber` varchar(5)
,`RecipientHouseOrFlatNo` varchar(10)
,`RecipientPostalCode` varchar(20)
,`RecipientCity` varchar(100)
,`TransactionTitle` varchar(100)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `JunctionTable`
--

CREATE TABLE `JunctionTable` (
  `TransactionNumber` char(18) COLLATE latin1_general_ci NOT NULL,
  `AccountNumber` char(26) COLLATE latin1_general_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Zrzut danych tabeli `JunctionTable`
--

INSERT INTO `JunctionTable` VALUES('201912291406000001', '86123456784480249024517243');
INSERT INTO `JunctionTable` VALUES('201912291406000001', '86123456784480249024505679');
INSERT INTO `JunctionTable` VALUES('202001021756000002', '86123456784480249024505679');
INSERT INTO `JunctionTable` VALUES('202001021756000002', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('202001021825000003', '86123456784480249024505679');
INSERT INTO `JunctionTable` VALUES('202001021825000003', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('202001031524000004', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('20200103212200005', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('20200103212200005', '43123456785275387631494265');
INSERT INTO `JunctionTable` VALUES('202001032122000006', '86123456784480249024505679');
INSERT INTO `JunctionTable` VALUES('202001032122000006', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('202001032122000007', '86123456784480249024505679');
INSERT INTO `JunctionTable` VALUES('202001032122000007', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('202001040000000008', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('202001040000000009', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('202001040000000009', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('202001040000000001', '43123456785275387631494265');
INSERT INTO `JunctionTable` VALUES('2020010400000011', '43123456785275387631494265');
INSERT INTO `JunctionTable` VALUES('2020010400000011', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('2020010400000012', '86123456784480249024505678');
INSERT INTO `JunctionTable` VALUES('2020010400000013', '26123456785647385647382905');
INSERT INTO `JunctionTable` VALUES('2020010400000013', '26123456785647385612341234');
INSERT INTO `JunctionTable` VALUES('2020010400000014', '26123456785647385647382905');
INSERT INTO `JunctionTable` VALUES('2020010400000014', '26123456785647385612341234');
INSERT INTO `JunctionTable` VALUES('2020010500000015', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('2020010500000015', '43123456785275387631494265');
INSERT INTO `JunctionTable` VALUES('2020010500000016', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('2020010500000016', '43123456785275387631494264');
INSERT INTO `JunctionTable` VALUES('202001052211000017', '22123456787480259462996291');
INSERT INTO `JunctionTable` VALUES('202001052211000017', '86123456785210352157532332');
INSERT INTO `JunctionTable` VALUES('202001052211000018', '07123456787809723424004007');
INSERT INTO `JunctionTable` VALUES('202001052211000018', '26123456785647385647382905');
INSERT INTO `JunctionTable` VALUES('202001052211000019', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('202001052211000019', '38123456786965032100832764');
INSERT INTO `JunctionTable` VALUES('202001052211000020', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('202001052211000020', '38123456786965032100832764');
INSERT INTO `JunctionTable` VALUES('202001052211000021', '96123456781373788056603850');
INSERT INTO `JunctionTable` VALUES('202001052211000021', '38123456786965032100832764');
INSERT INTO `JunctionTable` VALUES('202001052301000025', '43123456785275387631494265');
INSERT INTO `JunctionTable` VALUES('202001052301000025', '96123456781373788056603850');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `LoginDates`
--

CREATE TABLE `LoginDates` (
  `IdentityNumber` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `LoginDate` date NOT NULL
) ;

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `Payments`
-- (See below for the actual view)
--
CREATE TABLE `Payments` (
`TransactionNumber` char(18)
,`PayerAccountNumber` char(26)
,`PayerName` varchar(200)
,`PayerStreet` varchar(100)
,`PayerStreetNumber` varchar(5)
,`PayerHouseOrFlatNo` varchar(10)
,`PayerPostalCode` varchar(20)
,`PayerCity` varchar(100)
,`RecipientName` varchar(200)
,`RecipientCity` varchar(100)
,`TransactionTitle` varchar(100)
,`PayerCardNumber` char(16)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `Refunds`
-- (See below for the actual view)
--
CREATE TABLE `Refunds` (
`TransactionNumber` char(18)
,`PayerName` varchar(200)
,`PayerCity` varchar(100)
,`RecipientAccountNumber` char(26)
,`RecipientName` varchar(200)
,`RecipientStreet` varchar(100)
,`RecipientStreetNumber` varchar(5)
,`RecipientHouseOrFlatNo` varchar(10)
,`RecipientPostalCode` varchar(20)
,`RecipientCity` varchar(100)
,`TransactionTitle` varchar(100)
,`RecipientCardNumber` char(16)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `TestTable`
--

CREATE TABLE `TestTable` (
  `val` decimal(15,2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Zrzut danych tabeli `TestTable`
--

INSERT INTO `TestTable` VALUES('14.03');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `TransactionHistories`
--

CREATE TABLE `TransactionHistories` (
  `TransactionNumber` char(18) COLLATE latin1_general_ci NOT NULL,
  `PayerEmail` varchar(100) COLLATE latin1_general_ci DEFAULT NULL
) ;

--
-- Zrzut danych tabeli `TransactionHistories`
--

INSERT INTO `TransactionHistories` VALUES('201912291406000001', 'president@usa.gov', '1', '100', 'president@usa.gov', '1', '100');
INSERT INTO `TransactionHistories` VALUES('202001021756000002', 'president@usa.gov', '1', '100', 'annawhite@netpost.com', '+1', '765654543');
INSERT INTO `TransactionHistories` VALUES('202001021825000003', 'president@usa.gov', '1', '100', 'annawhite@netpost.com', '+1', '765654543');
INSERT INTO `TransactionHistories` VALUES('202001031524000004', 'annawhite@netpost.com', '+1', '765654543', NULL, NULL, NULL);
INSERT INTO `TransactionHistories` VALUES('20200103212200005', 'jankowalski@gmail.com', '+1', '356298673', 'jankowalski@gmail.com', '+1', '356298673');
INSERT INTO `TransactionHistories` VALUES('202001032122000006', 'president@usa.gov', '1', '100', 'annawhite@netpost.com', '+1', '765654543');
INSERT INTO `TransactionHistories` VALUES('202001032122000007', 'president@usa.gov', '1', '100', 'president@usa.gov', '1', '100');
INSERT INTO `TransactionHistories` VALUES('202001040000000008', 'annawhite@netpost.com', '+1', '765654543', NULL, NULL, NULL);
INSERT INTO `TransactionHistories` VALUES('202001040000000009', 'annawhite@netpost.com', '+1', '765654543', 'jankowalski@gmail.com', '+1', '356298673');
INSERT INTO `TransactionHistories` VALUES('202001040000000001', 'jankowalski@gmail.com', '+1', '356298673', NULL, NULL, NULL);
INSERT INTO `TransactionHistories` VALUES('2020010400000011', 'jankowalski@gmail.com', '+1', '356298673', 'annawhite@netpost.com', '+1', '765654543');
INSERT INTO `TransactionHistories` VALUES('2020010400000012', 'annawhite@netpost.com', '+1', '765654543', NULL, NULL, NULL);
INSERT INTO `TransactionHistories` VALUES('2020010400000013', 'willsmith20@netpost.com', '+1', '456567678', 'willsmith20@netpost.com', '+1', '456567678');
INSERT INTO `TransactionHistories` VALUES('2020010400000014', 'willsmith20@netpost.com', '+1', '456567678', 'willsmith20@netpost.com', '+1', '456567678');
INSERT INTO `TransactionHistories` VALUES('2020010500000015', 'jankowalski@gmail.com', '+1', '356298673', 'jankowalski@gmail.com', '+1', '356298673');
INSERT INTO `TransactionHistories` VALUES('2020010500000016', 'jankowalski@gmail.com', '+1', '356298673', 'jankowalski@gmail.com', '+1', '356298673');
INSERT INTO `TransactionHistories` VALUES('202001052211000017', 'hdjzjs@gmail.com', '+1', '986532659', 'hdjzjs@gmail.com', '+1', '986532659');
INSERT INTO `TransactionHistories` VALUES('202001052211000018', 'aa@aa.aa', '+0', '000000000', 'willsmith20@netpost.com', '+1', '456567678');
INSERT INTO `TransactionHistories` VALUES('202001052211000019', 'jankowalski@gmail.com', '+1', '356298673', 'newwillsmith@netpost.com', '03020', '777666876');
INSERT INTO `TransactionHistories` VALUES('202001052211000020', 'jankowalski@gmail.com', '+1', '356298673', 'newwillsmith@netpost.com', '03020', '777666876');
INSERT INTO `TransactionHistories` VALUES('202001052211000021', 'jankowalski@gmail.com', '+1', '356298673', 'newwillsmith@netpost.com', '03020', '777666876');
INSERT INTO `TransactionHistories` VALUES('202001052301000025', 'jankowalski@gmail.com', '+1', '356298673', 'jankowalski@gmail.com', '+1', '356298673');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Transactions`
--

CREATE TABLE `Transactions` (
  `TransactionNumber` char(18) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `Transactions`
--

INSERT INTO `Transactions` VALUES('201912291406000001', 'Internal transfer', NULL, '86123456784480249024517243', '86123456784480249024505679', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'Lemme send myself some cash :O', '2019-12-29', '500.00');
INSERT INTO `Transactions` VALUES('202001021756000002', 'Internal transfer', NULL, '86123456784480249024505679', '86123456784480249024505678', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Lemme give You some POCKET MONEY B*TCH :O', '2020-01-02', '500.00');
INSERT INTO `Transactions` VALUES('202001021825000003', 'Internal transfer', NULL, '86123456784480249024505679', '86123456784480249024505678', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Lemme give You some more moneyy', '2020-01-02', '500.00');
INSERT INTO `Transactions` VALUES('202001031524000004', 'Internal transfer', NULL, '86123456784480249024505678', '12345678987654567899987655', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Zabka S.A.', 'Plac Andersa', '7', NULL, '61-894', 'Poznan', 'Co na kreche bra?am ostatnio ;))', '2020-01-03', '500.00');
INSERT INTO `Transactions` VALUES('20200103212200005', 'Internal transfer', NULL, '96123456781373788056603850', '43123456785275387631494265', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Przelew w?asny z dnia 03.01.2020', '2020-01-03', '500.00');
INSERT INTO `Transactions` VALUES('202001032122000006', 'Transfer', NULL, '86123456784480249024505679', '86123456784480249024505678', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Some cash', '2020-01-03', '500.00');
INSERT INTO `Transactions` VALUES('202001032122000007', 'Internal transfer', NULL, '86123456784480249024505679', '86123456784480249024505678', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'MoneYYYYYYYYYYYYYYY', '2020-01-03', '500.00');
INSERT INTO `Transactions` VALUES('202001040000000008', 'Transfer', NULL, '86123456784480249024505678', '12121212120000000000000000', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Jack Black', NULL, NULL, NULL, NULL, NULL, 'Cash', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('202001040000000009', 'Transfer', NULL, '86123456784480249024505678', '96123456781373788056603850', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Cash', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('202001040000000001', 'Transfer', NULL, '43123456785275387631494265', '39271398172312739182732198', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Trump Donald', 'Pennsylvania Ave NW', '1600', NULL, 'DC 20500', 'Washington', 'Cash for Mr Trump', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('2020010400000011', 'Transfer', NULL, '43123456785275387631494265', '86123456784480249024505678', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'Cash for Mrs Anna', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('2020010400000012', 'Transfer', NULL, '86123456784480249024505678', '12345678998765456898754567', 'White Anna', 'Fifth', '76', 'b', '94207', 'Beverly Hills', 'MC Donalds', 'First', '15', NULL, 'DC 512', 'California', 'Kurczaczki McNuggets', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('2020010400000013', 'Internal transfer', NULL, '26123456785647385647382905', '26123456785647385612341234', 'Smith William', 'Second', '56', 'a', '94203', 'Beverly Hills', 'Smith William', 'Second', '56', 'a', '94203', 'Beverly Hills', 'Kurczaczki McNuggets', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('2020010400000014', 'Internal transfer', NULL, '26123456785647385647382905', '26123456785647385612341234', 'Smith William', 'Second', '56', 'a', '94203', 'Beverly Hills', 'Smith William', 'Second', '56', 'a', '94203', 'Beverly Hills', 'Moj transfer', '2020-01-04', '500.00');
INSERT INTO `Transactions` VALUES('2020010500000015', 'Internal transfer', NULL, '96123456781373788056603850', '43123456785275387631494265', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Moj transfer', '2020-01-05', '500.00');
INSERT INTO `Transactions` VALUES('2020010500000016', 'Internal transfer', NULL, '96123456781373788056603850', '43123456785275387631494264', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Moj transfer', '2020-01-05', '500.00');
INSERT INTO `Transactions` VALUES('202001052211000017', 'Internal transfer', NULL, '22123456787480259462996291', '86123456785210352157532332', 'Koww Adam', NULL, NULL, NULL, NULL, NULL, 'Koww Adam', NULL, NULL, NULL, NULL, NULL, 'My own transaction', '2020-01-05', '200.00');
INSERT INTO `Transactions` VALUES('202001052211000018', 'Transfer', NULL, '07123456787809723424004007', '26123456785647385647382905', 'Last First', NULL, NULL, NULL, NULL, NULL, 'Smith William', 'Second', '56', 'a', '94203', 'Beverly Hills', 'My own transaction', '2020-01-05', '100.00');
INSERT INTO `Transactions` VALUES('202001052211000019', 'Transfer', NULL, '96123456781373788056603850', '38123456786965032100832764', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Smith Will', NULL, NULL, NULL, NULL, NULL, 'Here comes the money', '2020-01-05', '49.00');
INSERT INTO `Transactions` VALUES('202001052211000020', 'Transfer', NULL, '96123456781373788056603850', '38123456786965032100832764', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Smith Will', NULL, NULL, NULL, NULL, NULL, 'Here comes the money 2', '2020-01-05', '50.00');
INSERT INTO `Transactions` VALUES('202001052211000021', 'Transfer', NULL, '96123456781373788056603850', '38123456786965032100832764', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Smith Will', NULL, NULL, NULL, NULL, NULL, 'Here comes the money 3', '2020-01-05', '50.00');
INSERT INTO `Transactions` VALUES('202001052301000025', 'Internal transfer', NULL, '43123456785275387631494265', '96123456781373788056603850', 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Kowalski Jan', NULL, NULL, NULL, NULL, NULL, 'Cash', '2020-01-05', '149.99');

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `Transactions_FullData`
-- (See below for the actual view)
--
CREATE TABLE `Transactions_FullData` (
`TransactionNumber` char(18)
,`PayerAccountNumber` char(26)
,`PayerName` varchar(200)
,`PayerStreet` varchar(100)
,`PayerStreetNumber` varchar(5)
,`PayerHouseOrFlatNo` varchar(10)
,`PayerPostalCode` varchar(20)
,`PayerCity` varchar(100)
,`RecipientAccountNumber` char(26)
,`RecipientName` varchar(200)
,`RecipientStreet` varchar(100)
,`RecipientStreetNumber` varchar(5)
,`RecipientHouseOrFlatNo` varchar(10)
,`RecipientPostalCode` varchar(20)
,`RecipientCity` varchar(100)
,`TransactionTitle` varchar(100)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `Transactions_OnlyName`
-- (See below for the actual view)
--
CREATE TABLE `Transactions_OnlyName` (
`TransactionNumber` char(18)
,`PayerAccountNumber` char(26)
,`PayerName` varchar(200)
,`PayerStreet` varchar(100)
,`PayerStreetNumber` varchar(5)
,`PayerHouseOrFlatNo` varchar(10)
,`PayerPostalCode` varchar(20)
,`PayerCity` varchar(100)
,`RecipientAccountNumber` char(26)
,`RecipientName` varchar(200)
,`TransactionTitle` varchar(100)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `TransactionTypes`
--

CREATE TABLE `TransactionTypes` (
  `TransactionType` varchar(17) COLLATE latin1_general_ci NOT NULL
) ;

--
-- Zrzut danych tabeli `TransactionTypes`
--

INSERT INTO `TransactionTypes` VALUES('ATM');
INSERT INTO `TransactionTypes` VALUES('Internal transfer');
INSERT INTO `TransactionTypes` VALUES('Payment');
INSERT INTO `TransactionTypes` VALUES('Transfer');

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `Withdrawals`
-- (See below for the actual view)
--
CREATE TABLE `Withdrawals` (
`TransactionNumber` char(18)
,`PayerAccountNumber` char(26)
,`PayerName` varchar(200)
,`PayerStreet` varchar(100)
,`PayerStreetNumber` varchar(5)
,`PayerHouseOrFlatNo` varchar(10)
,`PayerPostalCode` varchar(20)
,`PayerCity` varchar(100)
,`RecipientCardNumber` char(16)
,`RecipientName` varchar(200)
,`ATM adress line 1` varchar(100)
,`ATM adress line 2` varchar(5)
,`ATM adress line 3` varchar(100)
,`TransactionTitle` varchar(100)
,`TransactionDate` date
,`Amount` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Struktura widoku `AdrAll_TypeOfAdress_AccNo`
--
DROP TABLE IF EXISTS `AdrAll_TypeOfAdress_AccNo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `AdrAll_TypeOfAdress_AccNo`  AS  select `A`.`AdressID` AS `AdressID`,`A`.`IdentityNumber` AS `IdentityNumber`,`A`.`AdressType` AS `AdressType`,`A`.`Street` AS `Street`,`A`.`StreetNumber` AS `StreetNumber`,`A`.`HouseOrFlatNo` AS `HouseOrFlatNo`,`A`.`PostalCode` AS `PostalCode`,`A`.`City` AS `City`,`A`.`Country` AS `Country`,`A`.`AdressEntryDate` AS `AdressEntryDate`,`A`.`AdressStatus` AS `AdressStatus`,`A`.`AdressChangeDate` AS `AdressChangeDate`,`ACC`.`AccountNumber` AS `AccountNumber` from ((`Adresses` `A` join `Customers` `C` on(`A`.`IdentityNumber` = `C`.`IdentityNumber`)) join `Accounts` `ACC` on(`C`.`IdentityNumber` = `ACC`.`IdentityNumber`)) where `A`.`AdressType` like 'Adress' ;

-- --------------------------------------------------------

--
-- Struktura widoku `ATM_Payments`
--
DROP TABLE IF EXISTS `ATM_Payments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `ATM_Payments`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerCardNumber` AS `PayerCardNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerStreet` AS `ATM adress line 1`,`Transactions`.`PayerStreetNumber` AS `ATM adress line 2`,`Transactions`.`PayerCity` AS `ATM adress line 3`,`Transactions`.`RecipientAccountNumber` AS `RecipientAccountNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientStreet` AS `RecipientStreet`,`Transactions`.`RecipientStreetNumber` AS `RecipientStreetNumber`,`Transactions`.`RecipientHouseOrFlatNo` AS `RecipientHouseOrFlatNo`,`Transactions`.`RecipientPostalCode` AS `RecipientPostalCode`,`Transactions`.`RecipientCity` AS `RecipientCity`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` = 'ATM' and `Transactions`.`RecipientAccountNumber` is not null ;

-- --------------------------------------------------------

--
-- Struktura widoku `CustAll_AccNo`
--
DROP TABLE IF EXISTS `CustAll_AccNo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `CustAll_AccNo`  AS  select `C`.`IdentityNumber` AS `IdentityNumber`,`C`.`Email` AS `Email`,`C`.`LastName` AS `LastName`,`C`.`FirstName` AS `FirstName`,`C`.`BirthDate` AS `BirthDate`,`C`.`AreaCode` AS `AreaCode`,`C`.`PhoneNumber` AS `PhoneNumber`,`C`.`TitleOfCourtesy` AS `TitleOfCourtesy`,`C`.`UserName` AS `UserName`,`C`.`UserPassword` AS `UserPassword`,`C`.`RegisterDate` AS `RegisterDate`,`C`.`ProfileStatus` AS `ProfileStatus`,`A`.`AccountNumber` AS `AccountNumber` from (`Customers` `C` join `Accounts` `A` on(`C`.`IdentityNumber` = `A`.`IdentityNumber`)) ;

-- --------------------------------------------------------

--
-- Struktura widoku `CustLNFN_AdrAll`
--
DROP TABLE IF EXISTS `CustLNFN_AdrAll`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `CustLNFN_AdrAll`  AS  select `C`.`LastName` AS `LastName`,`C`.`FirstName` AS `FirstName`,`A`.`AdressID` AS `AdressID`,`A`.`IdentityNumber` AS `IdentityNumber`,`A`.`AdressType` AS `AdressType`,`A`.`Street` AS `Street`,`A`.`StreetNumber` AS `StreetNumber`,`A`.`HouseOrFlatNo` AS `HouseOrFlatNo`,`A`.`PostalCode` AS `PostalCode`,`A`.`City` AS `City`,`A`.`Country` AS `Country`,`A`.`AdressEntryDate` AS `AdressEntryDate`,`A`.`AdressStatus` AS `AdressStatus`,`A`.`AdressChangeDate` AS `AdressChangeDate` from (`Customers` `C` join `Adresses` `A` on(`C`.`IdentityNumber` = `A`.`IdentityNumber`)) ;

-- --------------------------------------------------------

--
-- Struktura widoku `CustomersWealth`
--
DROP TABLE IF EXISTS `CustomersWealth`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `CustomersWealth`  AS  select `C`.`FirstName` AS `FirstName`,`C`.`LastName` AS `LastName`,`A`.`AccountNumber` AS `AccountNumber`,`A`.`Balance` AS `Balance` from (`Customers` `C` join `Accounts` `A` on(`C`.`IdentityNumber` = `A`.`IdentityNumber`)) ;

-- --------------------------------------------------------

--
-- Struktura widoku `ForeignTransactions`
--
DROP TABLE IF EXISTS `ForeignTransactions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `ForeignTransactions`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerAccountNumber` AS `PayerAccountNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`RecipientAccountNumber` AS `RecipientAccountNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientStreet` AS `RecipientStreet`,`Transactions`.`RecipientStreetNumber` AS `RecipientStreetNumber`,`Transactions`.`RecipientHouseOrFlatNo` AS `RecipientHouseOrFlatNo`,`Transactions`.`RecipientPostalCode` AS `RecipientPostalCode`,`Transactions`.`RecipientCity` AS `RecipientCity`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` = 'Transfer' and `Transactions`.`PayerCity` is null and `Transactions`.`RecipientCity` is not null ;

-- --------------------------------------------------------

--
-- Struktura widoku `InternalTransactions`
--
DROP TABLE IF EXISTS `InternalTransactions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `InternalTransactions`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerAccountNumber` AS `PayerAccountNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerStreet` AS `PayerStreet`,`Transactions`.`PayerStreetNumber` AS `PayerStreetNumber`,`Transactions`.`PayerHouseOrFlatNo` AS `PayerHouseOrFlatNo`,`Transactions`.`PayerPostalCode` AS `PayerPostalCode`,`Transactions`.`PayerCity` AS `PayerCity`,`Transactions`.`RecipientAccountNumber` AS `RecipientAccountNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientStreet` AS `RecipientStreet`,`Transactions`.`RecipientStreetNumber` AS `RecipientStreetNumber`,`Transactions`.`RecipientHouseOrFlatNo` AS `RecipientHouseOrFlatNo`,`Transactions`.`RecipientPostalCode` AS `RecipientPostalCode`,`Transactions`.`RecipientCity` AS `RecipientCity`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` like 'Internal transfer' ;

-- --------------------------------------------------------

--
-- Struktura widoku `Payments`
--
DROP TABLE IF EXISTS `Payments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `Payments`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerAccountNumber` AS `PayerAccountNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerStreet` AS `PayerStreet`,`Transactions`.`PayerStreetNumber` AS `PayerStreetNumber`,`Transactions`.`PayerHouseOrFlatNo` AS `PayerHouseOrFlatNo`,`Transactions`.`PayerPostalCode` AS `PayerPostalCode`,`Transactions`.`PayerCity` AS `PayerCity`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientCity` AS `RecipientCity`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`PayerCardNumber` AS `PayerCardNumber`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` like 'Payment' and `Transactions`.`PayerAccountNumber` is not null ;

-- --------------------------------------------------------

--
-- Struktura widoku `Refunds`
--
DROP TABLE IF EXISTS `Refunds`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `Refunds`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerCity` AS `PayerCity`,`Transactions`.`RecipientAccountNumber` AS `RecipientAccountNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientStreet` AS `RecipientStreet`,`Transactions`.`RecipientStreetNumber` AS `RecipientStreetNumber`,`Transactions`.`RecipientHouseOrFlatNo` AS `RecipientHouseOrFlatNo`,`Transactions`.`RecipientPostalCode` AS `RecipientPostalCode`,`Transactions`.`RecipientCity` AS `RecipientCity`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`PayerCardNumber` AS `RecipientCardNumber`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` = 'Payment' and `Transactions`.`RecipientAccountNumber` is not null ;

-- --------------------------------------------------------

--
-- Struktura widoku `Transactions_FullData`
--
DROP TABLE IF EXISTS `Transactions_FullData`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `Transactions_FullData`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerAccountNumber` AS `PayerAccountNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerStreet` AS `PayerStreet`,`Transactions`.`PayerStreetNumber` AS `PayerStreetNumber`,`Transactions`.`PayerHouseOrFlatNo` AS `PayerHouseOrFlatNo`,`Transactions`.`PayerPostalCode` AS `PayerPostalCode`,`Transactions`.`PayerCity` AS `PayerCity`,`Transactions`.`RecipientAccountNumber` AS `RecipientAccountNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientStreet` AS `RecipientStreet`,`Transactions`.`RecipientStreetNumber` AS `RecipientStreetNumber`,`Transactions`.`RecipientHouseOrFlatNo` AS `RecipientHouseOrFlatNo`,`Transactions`.`RecipientPostalCode` AS `RecipientPostalCode`,`Transactions`.`RecipientCity` AS `RecipientCity`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` = 'Transfer' and `Transactions`.`PayerCity` is not null and `Transactions`.`RecipientCity` is not null ;

-- --------------------------------------------------------

--
-- Struktura widoku `Transactions_OnlyName`
--
DROP TABLE IF EXISTS `Transactions_OnlyName`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `Transactions_OnlyName`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerAccountNumber` AS `PayerAccountNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerStreet` AS `PayerStreet`,`Transactions`.`PayerStreetNumber` AS `PayerStreetNumber`,`Transactions`.`PayerHouseOrFlatNo` AS `PayerHouseOrFlatNo`,`Transactions`.`PayerPostalCode` AS `PayerPostalCode`,`Transactions`.`PayerCity` AS `PayerCity`,`Transactions`.`RecipientAccountNumber` AS `RecipientAccountNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` = 'Transfer' and `Transactions`.`PayerCity` is not null and `Transactions`.`RecipientCity` is null ;

-- --------------------------------------------------------

--
-- Struktura widoku `Withdrawals`
--
DROP TABLE IF EXISTS `Withdrawals`;

CREATE ALGORITHM=UNDEFINED DEFINER=`bestbank`@`%` SQL SECURITY DEFINER VIEW `Withdrawals`  AS  select `Transactions`.`TransactionNumber` AS `TransactionNumber`,`Transactions`.`PayerAccountNumber` AS `PayerAccountNumber`,`Transactions`.`PayerName` AS `PayerName`,`Transactions`.`PayerStreet` AS `PayerStreet`,`Transactions`.`PayerStreetNumber` AS `PayerStreetNumber`,`Transactions`.`PayerHouseOrFlatNo` AS `PayerHouseOrFlatNo`,`Transactions`.`PayerPostalCode` AS `PayerPostalCode`,`Transactions`.`PayerCity` AS `PayerCity`,`Transactions`.`PayerCardNumber` AS `RecipientCardNumber`,`Transactions`.`RecipientName` AS `RecipientName`,`Transactions`.`RecipientStreet` AS `ATM adress line 1`,`Transactions`.`RecipientStreetNumber` AS `ATM adress line 2`,`Transactions`.`RecipientCity` AS `ATM adress line 3`,`Transactions`.`TransactionTitle` AS `TransactionTitle`,`Transactions`.`TransactionDate` AS `TransactionDate`,`Transactions`.`Amount` AS `Amount` from `Transactions` where `Transactions`.`TransactionType` = 'ATM' and `Transactions`.`PayerAccountNumber` is not null ;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indexes for table `JunctionTable`
--
ALTER TABLE `JunctionTable`
  ADD KEY `fk_jt_TransactionNumber` (`TransactionNumber`),
  ADD KEY `fk_jt_AccountNumber` (`AccountNumber`);

--
-- Indexes for table `TestTable`
--
ALTER TABLE `TestTable`
  ADD PRIMARY KEY (`val`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `Adresses`
--
ALTER TABLE `Adresses`
  MODIFY `AdressID` smallint(6) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
