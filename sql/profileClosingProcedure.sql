use bestbank;
/*
alter table Customers
add column ProfileClosingDate date check(ProfileClosingDate > RegisterDate);
*/

/*Dominik - tak jak poprzednio, potrzebuję od Ciebie poprawności gramatycznej wprowadzanych argumentów*/

create procedure closeProfile(
  in customerIdentityNumber varchar(30),
  in closeDate date
)
begin
  /*Dane będą wprowadzane "ze środka" aplikacji, więc jakakolwiek
  weryfikacja jest tutaj zbędna*/

  update Adresses
  set AdressStatus = 'Outdated'
  where 
    (AdressStatus = 'Actual') and
    (IdentityNumber = customerIdentityNumber);

  update Adresses
  set AdressChangeDate = closeDate
  where
    (AdressChangeDate is null) and 
    (IdentityNumber = customerIdentityNumber);

  update Accounts
  set AccountStatus = 'Inactive'
  where 
    (AccountStatus = 'Active') and
    (IdentityNumber = customerIdentityNumber);

  update Accounts
  set ClosingDate = closeDate
  where
    (ClosingDate is null) and 
    (IdentityNumber = customerIdentityNumber);

  update CreditCards
  set CardStatus = 'Inactive'
  where 
    (CardStatus = 'Active') and
    (AssociatedAccount in (
      select 
      AccountNumber 
      from Accounts 
      where IdentityNumber = customerIdentityNumber
    ));

  update CreditCards
  set CancellationDate = closeDate
  where
    (CancellationDate is null) and
    (AssociatedAccount in (
      select 
      AccountNumber 
      from Accounts 
      where IdentityNumber = customerIdentityNumber
    ));

  update Customers
  set ProfileStatus = 'Inactive'
  where
    (ProfileStatus = 'Active') and 
    (IdentityNumber = customerIdentityNumber);

  update Customers
  set ProfileClosingDate = closeDate
  where
    (ProfileClosingDate is null) and 
    (IdentityNumber = customerIdentityNumber);
end;

/*
Dla mnie:

WAŻNE: W where nie może być dwóch takich samych
nazw (ci) po obydwu stronach równania
*/