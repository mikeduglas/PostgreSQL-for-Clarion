# PostgreSQL-for-Clarion

This is the Clarion application programmer's interface to PostgreSQL.

## Requirements  
- C6.3 and newer.
- PostgreSQL 9.4 and newer.

## How to install
Hit the 'Clone or Download' button and select 'Download Zip'.  
Now unzip zip file into a temporary folder somewhere.

Copy the contents of bin, lib and libsrc folders into %ClarionRoot%\Accessory folder.

## How to use
See examples folder.

## Contacts
- <mikeduglas@yandex.ru>
- <mikeduglas66@gmail.com>


[Buy now](https://www.clarionshop.com/checkout.cfm?pid=1653&q=1&)


## Version history
v1.03 (26.06.2023)
- NEW: TPostgreConn.GetPID method returns the process ID (PID) of the backend process handling this connection.
- NEW: TPostgreConn.Notify method sends a notification event together with an optional “payload” string to each client application that has previously executed LISTEN channel for the specified channel name in the current database. Notifications are visible to all users.
- NEW: TPostgreConn.Listen method registers the current session as a listener on the notification channel named channel.
- NEW: TPostgreConn.Unlisten method stops listening for a notification.
- NEW: TPostgreConn.TakeNotifications method returns a list of notification messages received from the server.
- NEW: Test8.clw: Test of the asynchronous notification interface.

v1.02 (25.04.2020)
- NEW: SetEncodings methods for Unicode support.
- NEW: TPostgreViewer class to display query results in virtual listbox.
- NEW: Test6 example (query viewer).

v1.01 (07.03.2020)
- NEW: ExecF method: allows to call Exec with up to 10 formatted parameters, like [printf function](https://github.com/mikeduglas/printf).
- NEW: Methods supporting prepared statements: Prepare, ExecPrepared.
- FIX: a typo in ConsumeInput method name.
- CHG: more examples.

v1.00 (09.01.2020)
- minor chamges.

v0.99b (02.12.2018)
- NEW: Asynchronous commands.

v0.99a (30.11.2018)
- NEW: ability to return server response as JSON string.

v0.99 (29.11.2018)
- NEW: Reset, Ping, transactions, connection properties, events.

v0.98 (27.11.2018)
- Initial version.