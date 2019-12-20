/*Widoki są po to, by dla konkretnej tablicy obiektów w backendzie aplikacji, z tabeli w bazie nie zostały pobrane puste wartosci (nulle).
(W tabeli Transactions niektórych danych nie ma dla konkretnych typów transakcji, np. dla wpłaty nullem będzie pole PayerAccountNumber)*/

/*1. Dwa widoki dla wpłat/wypłat*/

create view Transactions_ATM_in as
  select
    TransactionNumber,
    /*karta*/
    PayerCardNumber,
    PayerName,
    /*adres wpłatomatu*/
    PayerStreet,
    PayerStreetNumber,
    PayerCity,
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
  from Transactions;

create view Transactions_ATM_out as
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
    PayerCardNumber, /*błąd nazewnictwa (powinno byc samo CardNumber)*/
    RecipientName
    /*adres bankomatu*/
    RecipientStreet,
    RecipientStreetNumber,
    RecipientCity,

    TransactionTitle,
    TransactionDate,
    Amount
  from Transactions;
/*wdrożone*/
/*2. Dwa widoki dla płatności/zwrotów z użyciem karty*/

/*..*/

/*3. Pięć widoków dla przelewów, które wysyłają klienci naszego banku (bez kierunku - to musi być już po waszej stronie) 
(adn. do procedur - nie będzie nulli):

1. Imię i nazwisko - adresat jest w bazie
2. Imię i nazwisko - adresata nie ma w bazie
3. Imię, nazwisko, adres - adresat jest w bazie
4. Imię, nazwisko, adres - adresata nie ma w bazie
5. Nazwa firmy, adres - adresata nie ma w bazie*/

/*..*/

/*4. Widok dla przelewów przychodzących z innych banków (te będę wklepywać ręcznie)
  1. PayerAccountNumber,
     PayerName,
     [pełne dane odbiorcy]*/

/*..*/

/*Dodatkowo:

Dla przelewów nie ma kierunku, gdyż wszystkie inne transakcje możemy podzielić a te nie.
Przykładowo, ATM'y mozemy podzielic na interakcje kasa-konto/konto-kasa, wtedy zmieniaja
sie pola Payer i Recipient i są to zupełnie inne transakcje. Tak samo dla płatnosci
(karta-terminal/terminal-karta).

Przelew natomiast dziala na zasadzie konto-konto, więc tutaj nie ma mowy o podziale transakcji.
Możecie je jedynie zinterpretować w programie np. na podstawie tego, czy konto osoby zalogowanej
jest kontem Recipienta z Transakcji./*