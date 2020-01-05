create function IBAN(accountNumber char(26))
returns char(8)
begin
  return substring(accountNumber, 3, 8);
  /*substring w MySQL'u działa inaczej niż w Javie czy C# (nie wg indexow a miejsc poszczególnych liter)*/
end;

/*Widoki pomocnicze*/
---------------------

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

/*do testowania*/
create view CustLNFN_AdrAll as
select 
LastName, 
FirstName, 
A.*
from Customers C join Adresses A on
  C.IdentityNumber = A.IdentityNumber;

/*Procedury rejestru transakcji*/
---------------------------------

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
here:begin
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
  in amount decimal
)
here:begin
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
end;

/*3. Nazwa firmy, adres*/

create procedure registerTransaction_byCompany(
  in transactionNumber varchar(18),
  in payerAccountNumber varchar(26),
  in companyAccountNumber varchar(26),

  in companyName varchar(100),
  in companyStreet varchar(100),
  in companyStreetNumber varchar(5),
  in companyHouseOrFlatNo varchar(10),
  in companyPostalCode varchar(20),
  in companyCity varchar(100),

  in transactionTitle varchar(100),
  in transactionDate date,
  in amount decimal /*(10, 0) to wartość domyślna dla typu decimal*/
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
end;

/*4. Procedura dla transferu wewnętrznego (osobna zakładka w aplikacji)*/

create procedure registerTransaction_internal(
  in transactionNumber varchar(18),
  in sourceAccountNumber varchar(26),
  in targetAccountNumber varchar(26),

  in transactionTitle varchar(100),
  in transactionDate date,
  in amount decimal
)
begin
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
end;