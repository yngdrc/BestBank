create function IBAN(accountNumber char(26))
returns char(8)
begin
  return substring(accountNumber, 3, 8);
  /*substring w MySQL'u działa inaczej niż w Javie czy C# (nie wg indexow a miejsc poszczególnych liter)*/
end;

/*Widoki pomocnicze*/

create view CustAll_AccNo as
  select
  C.*,
  AccountNumber
  from Customers C join Accounts A on C.IdentityNumber = A.IdentityNumber;

create view AdrAll_TypeOfAdress_AccNo as
  select
  A.*,
  ACC.AccountNumber
  from Adresses A join Customers C on A.IdentityNumber = C.IdentityNumber
                    join Accounts ACC on C.IdentityNumber = ACC.IdentityNumber
  where AdressType like 'Adress';

/*Procedury rejestru transakcji*/

/*1. Imię i nazwisko odbiorcy*/

create procedure registerTransaction_byNameOnly(
  in transactionNumber char(18),
  in payerAccountNumber char(26),
  in recipientAccountNumber char(26),

  in recipientLastName varchar(100),
  in recipientFirstName varchar(100),

  in transactionTitle varchar(100),
  in transactionDate date,
  in amount decimal(10, 0)
)
begin
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
  /*weryfikacja odbiorcy*/
  declare verificationResult varchar(30);
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
  /*(dodatkowo)*/
  set recipientName = concat(recipientLastName, ' ', recipientFirstName);

  /*weryfikacja odbiorcy - na początku sprawdzamy, czy konto odbiorcy jest zarejestrowane w naszym banku*/
  if IBAN(recipientAccountNumber) = '12345678'
  then
    /*weryfikacja zgodności danych (czy dla takiego konta isnieje taki klient)*/
    /*zamiast IF EXISTS poniżej, stosujemy instrukcję SELECT INTO (ogarniczenie dostępu do zmiennych):*/
    select
    IdentityNumber
    into verificationResult
    from CustAll_AccNo
    where 
      AccountNumber = recipientAccountNumber and /*UNIQUE*/
      LastName = recipientLastName and
      FirstName = recipientFirstName;
    
    if verificationResult is not null
    then
      /*dopiero po weryfikacji zgodności podanych informacji sprawdzamy dodatkowo, czy nadawca to jednoczesnie odbiorca*/
      if verificationResult = (
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
          where AccountNumber = recipientAccountNumber
        );
        set recipientStreetNumber = (
          select 
          StreetNumber
          from AdrAll_TypeOfAdress_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientHouseOrFlatNo = (
          select 
          HouseOrFlatNo
          from AdrAll_TypeOfAdress_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientPostalCode = (
          select 
          PostalCode
          from AdrAll_TypeOfAdress_AccNo
          where AccountNumber = recipientAccountNumber
        );
        set recipientCity = (
          select 
          City
          from AdrAll_TypeOfAdress_AccNo
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
      select 'Missmatching data for existing account!' as 'ERR communicate';
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
end;

/*2. Imię, nazwisko i adres*/

create procedure registerTransaction_byFullData(
  in transactionNumber char(18),
  in payerAccountNumber char(26),
  in recipientAccountNumber char(26),
  
  in recipientLastName varchar(100),
  in recipientFirstName varchar(100),
  in recipientStreet varchar(100),
  in recipientStreetNumber varchar(5),
  in recipientHouseOrFlatNo varchar(10),
  in recipientPostalCode varchar(20),
  in recipientCity varchar(100),

  in transactionTitle varchar(100),
  in transactionDate date,
  in amount decimal(10, 0)
)
begin
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
  
  declare verificationResult varchar(30);
  
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
  
  set recipientName = concat(recipientLastName, ' ', recipientFirstName);
  
  if IBAN(recipientAccountNumber) = '12345678'
  then
    select
    C.IdentityNumber
    into verificationResult
    from Adresses A join Customers C on A.IdentityNumber = C.IdentityNumber
                      join Accounts ACC on C.IdentityNumber = ACC.IdentityNumber
    where 
      AccountNumber = recipientAccountNumber and
      LastName = recipientLastName and
      FirstName = recipientFirstName and

      AdressType = 'Adress' and

      Street = recipientStreet and
      StreetNumber = recipientStreetNumber and
      HouseOrFlatNo = recipientHouseOrFlatNo and
      PostalCode = recipientPostalCode and
      City = recipientCity;
    
    if verificationResult is not null
    then
      if verificationResult = (
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
      select 'Missmatching data for existing account!' as 'ERR communicate';
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
end;

/*3. Nazwa firmy, adres*/

/*..*/

/*4. Procedura dla transferu wewnętrznego (osobna zakładka w aplikacji)*/

/*..*/