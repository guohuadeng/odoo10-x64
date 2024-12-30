title init db GreenOdoo10 x64 fast - www.odooai.cn
rd /s/q .\odoofile
md odoofile
echo odooai.cn > .\odoofile\odooai.cn
cd runtime\pgsql\bin
rd /s/q ..\data
initdb.exe -D ..\data -E UTF8
pg_ctl -D ..\data -l logfile start
echo create user: all input 'odoo'
createuser --createdb --no-createrole --no-superuser --pwprompt odoo
cd ..\..\..