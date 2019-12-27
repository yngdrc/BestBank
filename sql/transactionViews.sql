/*Widoki są po to, by dla konkretnej tablicy obiektów w backendzie aplikacji, z tabeli w bazie nie zostały pobrane puste wartosci (nulle).
(W tabeli Transactions niektórych danych nie ma dla konkretnych typów transakcji, np. dla wpłaty nullem będzie pole PayerAccountNumber)*/

/*1. Dwa widoki dla wpłat/wypłat*/
create view ATM_Payments as
  select
    TransactionNumber,
    /*karta*/
    PayerCardNumber,
    PayerName,
    /*adres wpłatomatu*/
    PayerStreet as 'ATM adress line 1',
    PayerStreetNumber as 'ATM adress line 2',
    PayerCity as 'ATM adress line 3',
    /*dane docelowe*/
    RecipientAccountNumber,    
    RecipientName,
    RecipientStreet,
    RecipientStreetNumber,
    RecipientHouseOrFlatNo,
    RecipientPostalCode,
    RecipientCity,

    TransactionTitle,
    TransactionDate,
    Amount
  from Transactions
  where (TransactionType = 'ATM') and (RecipientAccountNumber is not null);

create view Withdrawals as
  select
    TransactionNumber,
    /*dane źródłowe*/
    PayerAccountNumber,
    PayerName,
    PayerStreet,
    PayerStreetNumber,
    PayerHouseOrFlatNo,
    PayerPostalCode,
    PayerCity,
    /*karta*/
    PayerCardNumber as 'RecipientCardNumber',
    RecipientName,
    /*adres bankomatu*/
    RecipientStreet as 'ATM adress line 1', 
    RecipientStreetNumber as 'ATM adress line 2', 
    RecipientCity as 'ATM adress line 3', 

    TransactionTitle,
    TransactionDate,
    Amount
  from Transactions
  where (TransactionType = 'ATM') and (PayerAccountNumber is not null);

/*2. Dwa widoki dla płatności/zwrotów z użyciem karty (będę je wrzucać ręcznie)*/

create view Payments as
  select
  TransactionNumber,
  /*Dane płatnika*/
  PayerAccountNumber,
  PayerName,
  PayerStreet,
  PayerStreetNumber,
  PayerHouseOrFlatNo,
  PayerPostalCode,
  PayerCity,
  /*Dane sprzedawcy (np. PBMETRO CZELADŹ)*/
  RecipientName,
  RecipientCity,

  TransactionTitle,
  /*karta (może być w tytule)*/
  PayerCardNumber,

  TransactionDate,
  Amount
from Transactions
where (TransactionType like 'Payment') and (PayerAccountNumber is not null);

create view Refunds as
  select
  TransactionNumber,
  /*j.w.*/
  PayerName,
  PayerCity,

  RecipientAccountNumber,
  RecipientName,
  RecipientStreet,
  RecipientStreetNumber,
  RecipientHouseOrFlatNo,
  RecipientPostalCode,
  RecipientCity,

  TransactionTitle,
  /*j.w.*/
  PayerCardNumber as 'RecipientCardNumber',

  TransactionDate,
  Amount
from Transactions
where (TransactionType = 'Payment') and (RecipientAccountNumber is not null);

/*3. Trzy widoki dla przelewów, które wysyłają klienci naszego banku (kierunek ustalacie sami)

/*(lepiej niech a i b będą jako jeden typ, a przelew wewnętrzny osobno)

a) Przelewy zwykłe - wszystkie dane odbiorcy (adresat jest w naszym banku lub nie ma go, ale podane zostały jego dane adresowe)*/

create view Transactions_FullData as
  select
    TransactionNumber,

    PayerAccountNumber,
    PayerName,
    PayerStreet,
    PayerStreetNumber,
    PayerHouseOrFlatNo,
    PayerPostalCode,
    PayerCity,

    RecipientAccountNumber,
    RecipientName,
    RecipientStreet,
    RecipientStreetNumber,
    RecipientHouseOrFlatNo,
    RecipientPostalCode,
    RecipientCity,
    
    TransactionTitle,
    TransactionDate,
    Amount
from Transactions 
where (TransactionType = 'Transfer') and (PayerCity is not null) and (RecipientCity is not null);

/*b) Przelewy zwykłe - bez adresu odbiorcy (adresat spoza banku, nie podano danych adresowych)*/

create view Transactions_OnlyName as
  select
  TransactionNumber,

  PayerAccountNumber,
  PayerName,
  PayerStreet,
  PayerStreetNumber,
  PayerHouseOrFlatNo,
  PayerPostalCode,
  PayerCity,

  RecipientAccountNumber,
  RecipientName,

  TransactionTitle,
  TransactionDate,
  Amount
from Transactions 
where (TransactionType = 'Transfer') and (PayerCity is not null) and (RecipientCity is null);

/*c) Przelewy wewnętrzne - do ogarnięcia

create view InternalTransactions as
  ..*/

/*
Dla przelewów nie ma kierunku, gdyż wszystkie inne transakcje możemy podzielić a te nie.
Przykładowo, ATM'y mozemy podzielic na interakcje kasa-konto/konto-kasa, wtedy zmieniaja
sie pola Payer i Recipient i są to zupełnie inne transakcje. Tak samo dla płatnosci
(karta-terminal/terminal-karta).

Przelew natomiast dziala na zasadzie konto-konto, więc tutaj nie ma mowy o podziale transakcji.
Możecie je jedynie zinterpretować w programie np. na podstawie tego, czy konto osoby zalogowanej
jest kontem Recipienta z Transakcji.

(Wyjątkiem jest poniższy przypadek:)
/*

/*4. Widok dla przelewów przychodzących z innych banków (te też będę wklepywać ręcznie)*/

create view ForeignTransactions as
  select
  TransactionNumber,

  PayerAccountNumber,
  PayerName,

  RecipientAccountNumber,
  RecipientName,
  RecipientStreet,
  RecipientStreetNumber,
  RecipientHouseOrFlatNo,
  RecipientPostalCode,
  RecipientCity,

  TransactionTitle,
  TransactionDate,
  Amount
from Transactions
where (TransactionType = 'Transfer') and (PayerCity is null) and (RecipientCity is not null);