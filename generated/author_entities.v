module main

import time

struct Author {

    id int [primary; sql: serial]
    full_name string 
    username string [unique]
    password string 
    salt string 
    email string 
    avatar string 
    created_at time.Time [sql_type: 'DATETIME']
    updated_at time.Time [sql_type: 'DATETIME']
    is_registered bool 
    is_blocked bool 
    is_admin bool 
}
