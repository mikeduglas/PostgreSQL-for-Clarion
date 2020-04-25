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
See examples/test.clw.

## Contacts
- <mikeduglas@yandex.ru>
- <mikeduglas66@gmail.com>

## Price
- $200 (PayPal)

## Version history
v1.02 (25.04.2020)
- NEW: TPostgreViewer class to display query results in virtual listbox
- NEW: Test6 example (query viewer)

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