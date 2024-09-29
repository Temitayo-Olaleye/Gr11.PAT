# Gr11.PAT
Library Management system I created for my Grade 11 PAT. This was my introduction to database manipulation.


Project notes:

LibraryAdmin password: Go@tinelli#

This program is for the use of the library staff. The only time a customer should be allowed to enter information would be when theyâ€™re inputting their information and passwords, otherwise, the customer must communicate verbally with the employee. This is done to keep customer information safe.

On running this program you are greeted with the login form. Here, the employee/admin is required to enter the Library Admin password: Go@tinelli#. 
You will be stuck on this screen until you successfully enter this password.

Now, you will be on the Menu form. From here, the user has multiple options. By clicking on the respective buttons, they can open the BookInventory, Customer, CheckOut or TransactionHistory form. There is also a button to close the program.

In the BookInventory Form, the employee can add, edit and delete books, by clicking the respective buttons. dbgBooks shows the books in the database. They can also click btnFindPopularBooks to determine the book that has been taken out the most. (this button makes use of parallel arrays). There is also a button to close the form.

In the Customer Form, dbgCustomers shows all the customers in the database.
The employee can delete an account from the database (only on the authorisation of the customer). They can add a customer, this also creates a textfile for the customer (procedure AddCustomerTextFile). Customers are required to enter their passwords before they can edit their information.

Current User Passwords:
*See Screeenshot in Task 10* (or view table in Customers Form)

btnDisplayCustomerInfo displays the customerâ€™s textfile in a richedit.

Additionally, a summary is used to determine the total amount of fines that customers owe. (uses procedure GetTotalFines). A bitbutton closes the form.

In the CheckOut Form, employees can enter when a book is being taken out and when a book is returned.

When a book is taken out,  a customer must put in their ID and password. The employee will be able to see the bookID printed on the spine of the book and complete this step.
The customerâ€™s information is now changed, IsBookOut field is now true, meaning that they canâ€™t take out another book until this one is returned. Additionally, the book information is edited. The AvailabilityStatus field now becomes false. Meaning, this bookID canâ€™t be used in another transaction until the book is returned. A textfile containing the details of the transaction is also made.

A book can be returned, there are procedures in the code that determine whether the book has been taken out by a specific customer (see CheckOut_U). The textfile of the transaction is also updated.

Currently, because all the transactions entered have been very recent, no transactions have had overdue books. However, theoretically, if time moves forward, (or if one changes their system time) transactions would become overdue. Therefore in the setting of working for the library, THE EMPLOYEE MUST NOT CHANGE THE SYSTEM DATE. 
However, This can be changed to test funtionality, if desired.
To limit any extremities, the DateTimePicker has a maximum date of the current date and a minimum of 30 days before the current date.

TransactionHistory Form has the dbgTransactions, which shows the table of all the transactions.
The FindTransaction button also locates the transactions text file and displays it in a rich edit.
On activating this form, a procedure checks the date of books that are still out, to the current date, and if a book is overdue, the field IsBookOverdue becomes true, and a fine begins to grow. (50c per day late).

Small Bug:
When a customer is deleted from the database, any transactions with said customer is supposed to be deleted, this does happen, but this is only shown in the dbgTransactions AFTER closing and re-opening the program
